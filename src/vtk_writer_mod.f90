module vtk_writer_mod
  use iso_fortran_env, only: real64
  use config_mod, only: simulation_config
  implicit none
  private

  public :: write_pvd_first_lines, write_pvd_line, write_pvd_end_lines, write_vti_structured_points

contains

  subroutine write_vti_structured_points(path, field, cfg)
    character(len=*), intent(in) :: path
    real(real64), intent(in) :: field(:, :)
    type(simulation_config), intent(in) :: cfg

    integer :: ios, unit
    integer :: i, j

    open(newunit=unit, file=(path), status="replace", action="write", iostat=ios)
    if (ios /= 0) error stop "Could not open VTI output file"

    write(unit, "(A)") '<?xml version="1.0"?>'
    write(unit, "(A)") '<VTKFile type="ImageData" version="0.1" byte_order="LittleEndian">'
    write(unit, "(A)") '  <ImageData WholeExtent="0 24 0 16 0 0" Origin="0.0 0.0 0.0" Spacing="1.0 1.0 1.0">'
    write(unit, "(A)") '    <Piece Extent="0 24 0 16 0 0">'
    write(unit, "(A)") '      <PointData Scalars="temperature">'
    write(unit, "(A)") '        <DataArray type="Float64" Name="temperature" format="ascii">'

    do j = 1, cfg%ny
      do i = 1, cfg%nx
        write(unit, "(A,ES16.8)") '          ', field(i, j)
      end do
    end do

    write(unit, "(A)") '        </DataArray>'
    write(unit, "(A)") '      </PointData>'
    write(unit, "(A)") '      <CellData>'
    write(unit, "(A)") '      </CellData>'
    write(unit, "(A)") '    </Piece>'
    write(unit, "(A)") '  </ImageData>'
    write(unit, "(A)") '</VTKFile>'

    close(unit)
  end subroutine write_vti_structured_points

  subroutine write_pvd_first_lines(path)
    character(len=*), intent(in) :: path
    integer :: ios, unit

    open(newunit=unit, file=(path), status="replace", action="write", iostat=ios)
    if (ios /= 0) error stop "Could not open PVD output file"

    write(unit, "(A)") '<?xml version="1.0"?>'
    write(unit, "(A)") '<VTKFile type="Collection" version="0.1" byte_order="LittleEndian" compressor="vtkZLibDataCompressor">'
    write(unit, "(A)") '  <Collection>'

    close(unit)
  end subroutine write_pvd_first_lines

  subroutine write_pvd_line(pvd_path, vti_path, step)
    character(len=*), intent(in) :: pvd_path, vti_path, step

    integer :: unit, ios

    open(newunit=unit, file=(pvd_path), status="old", action="write", position="append",iostat=ios)
    if (ios /= 0) error stop "Could not write in PVD output file"

    write(unit, "(A)") '    <DataSet timestep="' // step // '" group="" part="0" file="' // vti_path // '"/>'

    close(unit)
  end subroutine write_pvd_line

  subroutine write_pvd_end_lines(path)
    character(len=*), intent(in) :: path
    integer :: ios, unit

    open(newunit=unit, file=(path), status="old", action="write", position="append",iostat=ios)
    if (ios /= 0) error stop "Could not write last lines in PVD output file"

    write(unit, "(A)") '  </Collection>'
    write(unit, "(A)") '</VTKFile>'

    close(unit)
  end subroutine write_pvd_end_lines

end module vtk_writer_mod
