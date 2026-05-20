program test_field
  use, intrinsic :: ieee_arithmetic, only: ieee_is_nan
  use iso_fortran_env, only: real64
  use config_mod, only: simulation_config, validate_config
  use field_mod, only: diffuse_step, field_stats, initialize_field
  implicit none

  type(simulation_config) :: cfg
  real(real64), allocatable :: field(:, :)
  real(real64), allocatable :: next_field(:, :)
  real(real64) :: initial_max
  real(real64) :: initial_mean
  real(real64) :: initial_min
  real(real64) :: next_max
  real(real64) :: next_mean
  real(real64) :: next_min

  cfg%nx = 9
  cfg%ny = 7
  cfg%steps = 1
  cfg%alpha = 0.20_real64
  cfg%dt = 0.20_real64
  cfg%dx = 1.0_real64
  cfg%t_amb = 25.0_real64
  call validate_config(cfg)

  allocate(field(cfg%nx, cfg%ny))
  allocate(next_field(cfg%nx, cfg%ny))

  call initialize_field(field, cfg)
  call field_stats(field, initial_min, initial_max, initial_mean)
  call diffuse_step(field, next_field, cfg)
  call field_stats(next_field, next_min, next_max, next_mean)

  if (any(ieee_is_nan(next_field))) error stop "field contains NaN"
  if (initial_max <= initial_mean) error stop "initial field should have a peak"
  if (next_max > initial_max) error stop "diffusion should not create a larger peak"
  if (abs(next_mean - initial_mean) > 5.0e-3_real64) then
    error stop "mean changed more than expected for one tiny diffusion step"
  end if
  if (next_min < -1.0e-12_real64) error stop "diffusion created negative values"
end program test_field
