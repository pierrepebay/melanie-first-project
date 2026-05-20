module config_mod
  use iso_fortran_env, only: real64
  implicit none
  private

  type, public :: simulation_config
    character(len=128) :: case_name = "melanie_demo"
    character(len=256) :: output_dir = "output"
    integer :: nx = 25
    integer :: ny = 17
    integer :: steps = 24
    integer :: output_every = 6
    real(real64) :: alpha = 0.20_real64
    real(real64) :: dt = 0.20_real64
    real(real64) :: dx = 1.0_real64
    real(real64) :: source_strength = 1.0_real64
    real(real64) :: t_amb = 0.0_real64
  end type simulation_config

  public :: read_config
  public :: validate_config

contains

  subroutine read_config(path, cfg)
    character(len=*), intent(in) :: path
    type(simulation_config), intent(inout) :: cfg

    character(len=512) :: line
    character(len=128) :: key
    character(len=384) :: value
    integer :: equals_at
    integer :: ios
    integer :: unit

    open(newunit=unit, file=trim(path), status="old", action="read", iostat=ios)
    if (ios /= 0) then
      error stop "Could not open configuration file"
    end if

    do
      read(unit, "(A)", iostat=ios) line
      if (ios /= 0) exit

      call remove_comment(line)
      if (len_trim(line) == 0) cycle

      equals_at = index(line, "=")
      if (equals_at <= 1) then
        error stop "Configuration lines must use key = value"
      end if

      key = lower_string(trim(adjustl(line(:equals_at - 1))))
      value = clean_value(trim(adjustl(line(equals_at + 1:))))
      call apply_config_value(trim(key), trim(value), cfg)
    end do

    close(unit)
  end subroutine read_config

  subroutine validate_config(cfg)
    type(simulation_config), intent(in) :: cfg
    real(real64) :: stability

    if (len_trim(cfg%case_name) == 0) error stop "case_name must not be empty"
    if (len_trim(cfg%output_dir) == 0) error stop "output_dir must not be empty"
    if (cfg%nx < 3) error stop "nx must be at least 3"
    if (cfg%ny < 3) error stop "ny must be at least 3"
    if (cfg%steps < 0) error stop "steps must be zero or positive"
    if (cfg%output_every < 1) error stop "output_every must be at least 1"
    if (cfg%alpha <= 0.0_real64) error stop "alpha must be positive"
    if (cfg%dt <= 0.0_real64) error stop "dt must be positive"
    if (cfg%dx <= 0.0_real64) error stop "dx must be positive"
    if (cfg%source_strength <= 0.0_real64) then
      error stop "source_strength must be positive"
    end if
    if (cfg%t_amb <= 0.0_real64) error stop "t_amb must be positive"

    stability = cfg%alpha * cfg%dt / (cfg%dx * cfg%dx)
    if (stability > 0.25_real64) then
      error stop "The explicit diffusion update is unstable; reduce alpha or dt"
    end if
  end subroutine validate_config

  subroutine apply_config_value(key, value, cfg)
    character(len=*), intent(in) :: key
    character(len=*), intent(in) :: value
    type(simulation_config), intent(inout) :: cfg

    select case (key)
    case ("case_name")
      cfg%case_name = value
    case ("output_dir")
      cfg%output_dir = value
    case ("nx")
      read(value, *) cfg%nx
    case ("ny")
      read(value, *) cfg%ny
    case ("steps")
      read(value, *) cfg%steps
    case ("output_every")
      read(value, *) cfg%output_every
    case ("alpha")
      read(value, *) cfg%alpha
    case ("dt")
      read(value, *) cfg%dt
    case ("dx")
      read(value, *) cfg%dx
    case ("source_strength")
      read(value, *) cfg%source_strength
    case ("t_amb")
      read(value, *) cfg%t_amb
    case default
      error stop "Unknown configuration key"
    end select
  end subroutine apply_config_value

  subroutine remove_comment(line)
    character(len=*), intent(inout) :: line
    integer :: hash_at
    integer :: semicolon_at
    integer :: cut_at

    hash_at = index(line, "#")
    semicolon_at = index(line, ";")
    cut_at = len(line) + 1

    if (hash_at > 0) cut_at = min(cut_at, hash_at)
    if (semicolon_at > 0) cut_at = min(cut_at, semicolon_at)
    if (cut_at <= len(line)) line(cut_at:) = " "
  end subroutine remove_comment

  pure function lower_string(text) result(lowered)
    character(len=*), intent(in) :: text
    character(len=len(text)) :: lowered
    integer :: i
    integer :: code

    lowered = text
    do i = 1, len(text)
      code = iachar(lowered(i:i))
      if (code >= iachar("A") .and. code <= iachar("Z")) then
        lowered(i:i) = achar(code + 32)
      end if
    end do
  end function lower_string

  pure function clean_value(text) result(value)
    character(len=*), intent(in) :: text
    character(len=len(text)) :: value
    integer :: n

    value = adjustl(text)
    n = len_trim(value)
    if (n >= 2) then
      if ((value(1:1) == '"' .and. value(n:n) == '"') .or. &
          (value(1:1) == "'" .and. value(n:n) == "'")) then
        value = value(2:n - 1)
      end if
    end if
  end function clean_value

end module config_mod
