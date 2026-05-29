program test_config
  use iso_fortran_env, only: real64
  use config_mod, only: read_config, simulation_config, validate_config
  implicit none

  type(simulation_config) :: cfg
  character(len=256) :: config_path

  if (command_argument_count() /= 1) then
    error stop "test_config expects the path to simulation.ini"
  end if

  call get_command_argument(1, config_path)
  call read_config(trim(config_path), cfg)
  call validate_config(cfg)

  call assert_equal_text(trim(cfg%case_name), "melanie_demo", "case_name")
  call assert_equal_int(cfg%nx, 25, "nx")
  call assert_equal_int(cfg%ny, 17, "ny")
  call assert_equal_int(cfg%steps, 120, "steps")
  call assert_close(cfg%alpha, 0.10_real64, "alpha")
  call assert_close(cfg%dt, 1.0_real64, "dt")
  call assert_close(cfg%dx, 1.0_real64, "dx")
  call assert_equal_text(trim(cfg%top), "D", "top")
  call assert_equal_text(trim(cfg%bottom), "D", "bottom")
  call assert_equal_text(trim(cfg%left), "D", "left")
  call assert_equal_text(trim(cfg%right), "D", "right")

contains

  subroutine assert_equal_text(actual, expected, name)
    character(len=*), intent(in) :: actual
    character(len=*), intent(in) :: expected
    character(len=*), intent(in) :: name

    if (actual /= expected) then
      write(*, "(A,A,A,A,A)") "Expected ", trim(name), " = ", expected, &
        ", got " // actual
      error stop "text assertion failed"
    end if
  end subroutine assert_equal_text

  subroutine assert_equal_int(actual, expected, name)
    integer, intent(in) :: actual
    integer, intent(in) :: expected
    character(len=*), intent(in) :: name

    if (actual /= expected) then
      write(*, "(A,A,A,I0,A,I0)") "Expected ", trim(name), " = ", expected, &
        ", got ", actual
      error stop "integer assertion failed"
    end if
  end subroutine assert_equal_int

  subroutine assert_close(actual, expected, name)
    real(real64), intent(in) :: actual
    real(real64), intent(in) :: expected
    character(len=*), intent(in) :: name

    if (abs(actual - expected) > 1.0e-12_real64) then
      write(*, "(A,A,A,ES16.8,A,ES16.8)") "Expected ", trim(name), " = ", &
        expected, ", got ", actual
      error stop "real assertion failed"
    end if
  end subroutine assert_close

end program test_config
