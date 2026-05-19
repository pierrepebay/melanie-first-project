module field_mod
  use iso_fortran_env, only: real64
  use config_mod, only: simulation_config
  implicit none
  private

  public :: initialize_field
  public :: diffuse_step
  public :: field_stats
  public :: write_csv_field

contains

  subroutine initialize_field(field, cfg)
    real(real64), intent(out) :: field(:, :)
    type(simulation_config), intent(in) :: cfg
    integer :: i
    integer :: j
    real(real64) :: x
    real(real64) :: y
    real(real64) :: radius_squared

    do j = 1, cfg%ny
      do i = 1, cfg%nx
        field(i, j) = 25._real64
      end do
    end do

    do j = 1, cfg%ny
      y = real(j - 1, real64) / real(cfg%ny - 1, real64)
      do i = 1, cfg%nx
        x = real(i - 1, real64) / real(cfg%nx - 1, real64)
        radius_squared = (x - 0.5_real64)**2 + (y - 0.5_real64)**2
        field(i, j) = field(i, j) + cfg%source_strength * exp(-30.0_real64 * radius_squared)
      end do
    end do
  end subroutine initialize_field

  subroutine diffuse_step(field, next_field, cfg)
    real(real64), intent(in) :: field(:, :)
    real(real64), intent(out) :: next_field(:, :)
    type(simulation_config), intent(in) :: cfg
    integer :: i
    integer :: j
    real(real64) :: coefficient

    coefficient = cfg%alpha * cfg%dt / (cfg%dx * cfg%dx)
    next_field = field

    do j = 2, cfg%ny - 1
      do i = 2, cfg%nx - 1
        next_field(i, j) = field(i, j) + coefficient * ( &
          field(i - 1, j) + field(i + 1, j) + &
          field(i, j - 1) + field(i, j + 1) - &
          4.0_real64 * field(i, j) &
        )
      end do
    end do
  end subroutine diffuse_step

  subroutine field_stats(field, minimum, maximum, mean)
    real(real64), intent(in) :: field(:, :)
    real(real64), intent(out) :: minimum
    real(real64), intent(out) :: maximum
    real(real64), intent(out) :: mean

    minimum = minval(field)
    maximum = maxval(field)
    mean = sum(field) / real(size(field), real64)
  end subroutine field_stats

  subroutine write_csv_field(path, field, cfg)
    character(len=*), intent(in) :: path
    real(real64), intent(in) :: field(:, :)
    type(simulation_config), intent(in) :: cfg
    integer :: i
    integer :: ios
    integer :: j
    integer :: unit
    real(real64) :: x
    real(real64) :: y

    open(newunit=unit, file=trim(path), status="replace", action="write", iostat=ios)
    if (ios /= 0) error stop "Could not open CSV output file"

    write(unit, "(A)") "i,j,x,y,temperature"
    do j = 1, cfg%ny
      y = cfg%dx * real(j - 1, real64)
      do i = 1, cfg%nx
        x = cfg%dx * real(i - 1, real64)
        write(unit, "(I0,A,I0,A,F12.6,A,F12.6,A,ES16.8)") &
          i, ",", j, ",", x, ",", y, ",", field(i, j)
      end do
    end do

    close(unit)
  end subroutine write_csv_field

end module field_mod
