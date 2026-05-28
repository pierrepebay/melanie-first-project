program diffusion_playground
  use OMP_LIB
  use iso_fortran_env, only: real64
  use config_mod, only: read_config, simulation_config, validate_config
  use field_mod, only: diffuse_step, field_stats, initialize_field, write_csv_field
  use logger_mod, only: run_logger
  use path_mod, only: ensure_directory, join_path
  use vtk_writer_mod, only: write_pvd_first_lines, write_pvd_line, write_pvd_end_lines, write_vti_structured_points

  type(simulation_config) :: cfg
  type(run_logger) :: log
  character(len=256) :: config_path
  character(len=256) :: output_override
  character(len=512) :: log_path, pvd_path
  integer :: argc
  integer :: step
  real(real64), allocatable :: field(:, :)
  real(real64), allocatable :: next_field(:, :)
  real(real64) :: start, end, time, start_2, end_2, time_2

  start = omp_get_wtime()

  argc = command_argument_count()
  if (argc < 1) then
    write(*, "(A)") "Usage: diffusion_playground <config.ini> [output-directory]"
    stop 2
  end if

  call get_command_argument(1, config_path)
  call read_config(trim(config_path), cfg)
  if (argc >= 2) then
    call get_command_argument(2, output_override)
    cfg%output_dir = trim(output_override)
  end if
  call validate_config(cfg)

  call ensure_directory(trim(cfg%output_dir))
  log_path = join_path(trim(cfg%output_dir), trim(cfg%case_name) // ".log")
  call log%open(trim(log_path))
  call log_configuration(log, cfg, trim(config_path))

  call ensure_directory(trim(cfg%output_dir) // "/vti_files")
  pvd_path = join_path(trim(cfg%output_dir) // "/vti_files", trim(cfg%case_name) // ".pvd")
  call write_pvd_first_lines(trim(pvd_path))

  allocate(field(cfg%nx, cfg%ny))
  allocate(next_field(cfg%nx, cfg%ny))

  call initialize_field(field, cfg)
  call write_snapshot(0, field, cfg, log, pvd_path)

  start_2 = omp_get_wtime()

  do step = 1, cfg%steps
    call diffuse_step(field, next_field, cfg)
    field = next_field

    if (mod(step, cfg%output_every) == 0 .or. step == cfg%steps) then
      call write_snapshot(step, field, cfg, log, pvd_path)
    end if
  end do

  end_2 = omp_get_wtime()
  time_2 = end_2 - start_2
  write(*, *) "Boucle sur diffuse_step : ", time_2

  call write_summary(field, cfg, log)
  call write_pvd_end_lines(trim(pvd_path))
  call log%info("Run finished successfully")
  call log%close()

  end = omp_get_wtime()
  time = end-start

  write(*, *) "time = ", time

contains

  subroutine log_configuration(log, cfg, config_path)
    type(run_logger), intent(inout) :: log
    type(simulation_config), intent(in) :: cfg
    character(len=*), intent(in) :: config_path
    character(len=256) :: message
    real(real64) :: stability

    stability = cfg%alpha * cfg%dt / (cfg%dx * cfg%dx)
    call log%info("Configuration file: " // trim(config_path))
    call log%info("Case name: " // trim(cfg%case_name))
    write(message, "(A,I0,A,I0)") "Grid: ", cfg%nx, " x ", cfg%ny
    call log%info(trim(message))
    write(message, "(A,I0,A,I0)") "Steps: ", cfg%steps, ", output every ", &
      cfg%output_every
    call log%info(trim(message))
    write(message, "(A,F8.4)") "Stability coefficient: ", stability
    call log%info(trim(message))
  end subroutine log_configuration

  subroutine write_snapshot(step, field, cfg, log, pvd_path)
    integer, intent(in) :: step
    real(real64), intent(in) :: field(:, :)
    type(simulation_config), intent(in) :: cfg
    type(run_logger), intent(inout) :: log
    character(len=512), intent(in) :: pvd_path
    character(len=512) :: csv_path
    character(len=256) :: message
    character(len=128) :: stem
    character(len=512) :: vti_path
    real(real64) :: maximum
    real(real64) :: mean
    real(real64) :: minimum

    stem = trim(cfg%case_name) // "_step_" // step_label(step)
    csv_path = join_path(trim(cfg%output_dir), trim(stem) // ".csv")
    vti_path = join_path(trim(cfg%output_dir) // "/vti_files", trim(stem) // ".vti")

    call write_csv_field(trim(csv_path), field, cfg)
    call write_vti_structured_points(trim(vti_path), field, cfg)
    call write_pvd_line(trim(pvd_path), trim(stem) // ".vti", step_label(step))
    call field_stats(field, minimum, maximum, mean)

    write(message, "(A,I0,A,ES10.3,A,ES10.3,A,ES10.3)") &
      "Step ", step, ": min=", minimum, ", max=", maximum, ", mean=", mean
    call log%info(trim(message))
    call log%info("Wrote CSV: " // trim(csv_path))
    call log%info("Wrote VTI: " // trim(vti_path))
  end subroutine write_snapshot

  subroutine write_summary(field, cfg, log)
    real(real64), intent(in) :: field(:, :)
    type(simulation_config), intent(in) :: cfg
    type(run_logger), intent(inout) :: log
    character(len=512) :: path
    integer :: ios
    integer :: unit
    real(real64) :: maximum
    real(real64) :: mean
    real(real64) :: minimum

    path = join_path(trim(cfg%output_dir), trim(cfg%case_name) // "_summary.txt")
    call field_stats(field, minimum, maximum, mean)

    open(newunit=unit, file=trim(path), status="replace", action="write", iostat=ios)
    if (ios /= 0) error stop "Could not open summary output file"

    write(unit, "(A)") "Diffusion playground summary"
    write(unit, "(A)") "============================"
    write(unit, "(A,A)") "case_name = ", trim(cfg%case_name)
    write(unit, "(A,I0)") "nx = ", cfg%nx
    write(unit, "(A,I0)") "ny = ", cfg%ny
    write(unit, "(A,I0)") "steps = ", cfg%steps
    write(unit, "(A,ES16.8)") "minimum = ", minimum
    write(unit, "(A,ES16.8)") "maximum = ", maximum
    write(unit, "(A,ES16.8)") "mean = ", mean
    close(unit)

    call log%info("Wrote summary: " // trim(path))
  end subroutine write_summary

  function step_label(step) result(label)
    integer, intent(in) :: step
    character(len=4) :: label

    write(label, "(I4.4)") step
  end function step_label

end program diffusion_playground
