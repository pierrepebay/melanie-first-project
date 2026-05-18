module path_mod
  implicit none
  private

  public :: ensure_directory
  public :: join_path

contains

  subroutine ensure_directory(path)
    character(len=*), intent(in) :: path
    integer :: exit_status

    if (len_trim(path) == 0) return

    call execute_command_line('mkdir -p "' // trim(path) // '"', &
      exitstat=exit_status)
    if (exit_status /= 0) error stop "Could not create output directory"
  end subroutine ensure_directory

  function join_path(directory, name) result(path)
    character(len=*), intent(in) :: directory
    character(len=*), intent(in) :: name
    character(len=512) :: path
    integer :: n

    n = len_trim(directory)
    if (n == 0) then
      path = trim(name)
    elseif (directory(n:n) == "/") then
      path = trim(directory) // trim(name)
    else
      path = trim(directory) // "/" // trim(name)
    end if
  end function join_path

end module path_mod
