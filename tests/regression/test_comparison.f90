program test_comparison
  use iso_fortran_env, only: real64
  use config_mod, only: simulation_config, read_config, validate_config
  use field_mod, only: diffuse_step, initialize_field
  use path_mod, only: join_path
  use vtk_writer_mod, only: write_vti_structured_points
  implicit none

  integer :: argc, i
  character(len=256) :: path_1, path_2
  character(len=512) :: line_1, line_2, char_1, char_2
  integer :: unit_1, unit_2, ios_1, ios_2
  real(real64) :: elt_1, elt_2


  ! On recupere les deux fichiers vtk

  argc = command_argument_count()
  if (argc < 1) then
    write(*, "(A)") "Usage: test_comparison <reference.vtk> <fichier.vtk>"
    stop 2
  end if

  call get_command_argument(1, path_1)
  call get_command_argument(2, path_2)

  ! On compare les deux fichiers vtk

  open(newunit=unit_1, file=trim(path_1), status="old", action="read", iostat=ios_1)
  if (ios_1 /= 0) then
    error stop "Could not open reference file"
  end if
  open(newunit=unit_2, file=trim(path_2), status="old", action="read", iostat=ios_2)
  if (ios_2 /= 0) then
    error stop "Could not open compared file"
  end if

  do i = 1, 10
    read(unit_1, "(A)", iostat=ios_1) line_1
    if (ios_1 /= 0) exit
    read(unit_2, "(A)", iostat=ios_2) line_2
    if (ios_2 /= 0) exit
  end do

  do
    read(unit_1, "(A)", iostat=ios_1) line_1
    if (ios_1 /= 0) exit
    read(unit_2, "(A)", iostat=ios_2) line_2
    if (ios_2 /= 0) exit

    char_1 = trim(adjustl(line_1))
    char_2 = trim(adjustl(line_2))

    read(char_1, *) elt_1
    read(char_2, *) elt_2

    if (abs(elt_1 - elt_2) >= 1.0e-12_real64) then
        error stop "The results are different"
    end if
  end do


  close(unit_1)
  close(unit_2)


end program
