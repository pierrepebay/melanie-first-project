module logger_mod
  implicit none
  private

  type, public :: run_logger
    integer :: unit = -1
    logical :: is_open = .false.
  contains
    procedure :: open => open_logger
    procedure :: info => write_info
    procedure :: close => close_logger
  end type run_logger

contains

  subroutine open_logger(this, path)
    class(run_logger), intent(inout) :: this
    character(len=*), intent(in) :: path
    integer :: ios

    open(newunit=this%unit, file=trim(path), status="replace", action="write", &
      iostat=ios)
    if (ios /= 0) error stop "Could not open log file"

    this%is_open = .true.
    call this%info("Log file: " // trim(path))
  end subroutine open_logger

  subroutine write_info(this, message)
    class(run_logger), intent(inout) :: this
    character(len=*), intent(in) :: message
    character(len=32) :: stamp

    stamp = timestamp()
    write(*, "(A)") trim(message)
    if (this%is_open) then
      write(this%unit, "(A,1X,A)") trim(stamp), trim(message)
    end if
  end subroutine write_info

  subroutine close_logger(this)
    class(run_logger), intent(inout) :: this

    if (this%is_open) then
      close(this%unit)
      this%is_open = .false.
      this%unit = -1
    end if
  end subroutine close_logger

  function timestamp() result(stamp)
    character(len=32) :: stamp
    integer :: values(8)

    call date_and_time(values=values)
    write(stamp, "(I4.4,A,I2.2,A,I2.2,1X,I2.2,A,I2.2,A,I2.2)") &
      values(1), "-", values(2), "-", values(3), &
      values(5), ":", values(6), ":", values(7)
  end function timestamp

end module logger_mod
