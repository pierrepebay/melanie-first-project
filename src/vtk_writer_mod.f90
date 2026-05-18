module vtk_writer_mod
  use iso_fortran_env, only: real64
  use config_mod, only: simulation_config
  implicit none
  private

  public :: write_vtk_structured_points

contains

  subroutine write_vtk_structured_points(path, field, cfg)
    character(len=*), intent(in) :: path
    real(real64), intent(in) :: field(:, :)
    type(simulation_config), intent(in) :: cfg
    integer :: i
    integer :: ios
    integer :: j
    integer :: unit

    open(newunit=unit, file=trim(path), status="replace", action="write", iostat=ios)
    if (ios /= 0) error stop "Could not open VTK output file"

    write(unit, "(A)") "# vtk DataFile Version 3.0"
    write(unit, "(A)") "Diffusion playground output"
    write(unit, "(A)") "ASCII"
    write(unit, "(A)") "DATASET STRUCTURED_POINTS"
    write(unit, "(A,3(1X,I0))") "DIMENSIONS", cfg%nx, cfg%ny, 1
    write(unit, "(A)") "ORIGIN 0.0 0.0 0.0"
    write(unit, "(A,3(1X,F12.6))") "SPACING", cfg%dx, cfg%dx, 1.0_real64
    write(unit, "(A,1X,I0)") "POINT_DATA", cfg%nx * cfg%ny
    write(unit, "(A)") "SCALARS temperature double 1"
    write(unit, "(A)") "LOOKUP_TABLE default"

    do j = 1, cfg%ny
      do i = 1, cfg%nx
        write(unit, "(ES16.8)") field(i, j)
      end do
    end do

    close(unit)
  end subroutine write_vtk_structured_points

end module vtk_writer_mod
