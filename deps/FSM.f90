!-----------------------------------------------------------------------
! Factorial Snow Model
!
! Richard Essery
! School of GeoSciences
! University of Edinburgh
!
! Adapted for Julia by Jan Magnusson
! Norwegian Energy and Water Resources Directorate
!-----------------------------------------------------------------------

subroutine FSM(year_in, month_in, day_in, hour_in, &
			   SW_in, LW_in, Sf_in, Rf_in, Ta_in, RH_in, Ua_in, Ps_in, &
			   albs_in, Ds_in, Nsnow_in, Sice_in, Sliq_in, theta_in, Tsnow_in, Tsoil_in, Tsurf_in, &
			   am_in, cm_in, dm_in, em_in, hm_in, dt_in)
  
! Input variables

use DRIVING, only:   &
  year,              &! Year
  month,             &! Month of year
  day,               &! Day of month
  hour,              &! Hour of day
  SW,                &! Incoming shortwave radiation (W/m2)
  LW,                &! Incoming longwave radiation (W/m2)
  Sf,                &! Snowfall rate (kg/m2/s)
  Rf,                &! Rainfall rate (kg/m2/s)
  Ta,                &! Air temperature (K)
  Ua,                &! Wind speed (m/s)
  Ps,                &! Surface pressure (Pa)
  dt                  ! Timestep (s)
  
! State variables

use STATE_VARIABLES, only : &
  albs,              &! Snow albedo
  Ds,                &! Snow layer thicknesses (m)
  Nsnow,             &! Number of snow layers 
  Sice,              &! Ice content of snow layers (kg/m^2)
  Sliq,              &! Liquid content of snow layers (kg/m^2)
  theta,             &! Volumetric moisture content of soil layers
  Tsnow,             &! Snow layer temperatures (K)
  Tsoil,             &! Soil layer temperatures (K)
  Tsurf               ! Surface skin temperature (K)

use GRID, only : &
  Nsoil,             &! Number of soil layers
  Nsmax               ! Maximum number of snow layers

! Model combinations
  
use MODELS, only: &
  am,                &! Snow albedo model        0 - diagnostic
                      !                          1 - prognostic
  cm,                &! Snow conductivity model  0 - fixed
                      !                          1 - density function
  dm,                &! Snow density model       0 - fixed
                      !                          1 - prognostic
  em,                &! Surface exchange model   0 - fixed
                      !                          1 - stability correction
  hm                  ! Snow hydraulics model    0 - free draining 
                      !                          1 - bucket storage

implicit none

! Input variables

real*8, intent(in) :: year_in, month_in, day_in, hour_in, SW_in, LW_in, Sf_in, Rf_in, Ta_in, RH_in, Ua_in, Ps_in

real*8 :: RH  ! Relative humidity (%)

! State variables

integer*8, intent(out) :: Nsnow_in

real*8, intent(out) :: albs_in, Tsurf_in

real*8, intent(out) :: Ds_in(Nsmax), Sice_in(Nsmax), Sliq_in(Nsmax), Tsnow_in(Nsmax)

real*8, intent(out) :: theta_in(Nsoil), Tsoil_in(Nsoil)

! Model combinations

integer*8, intent(in) :: am_in, cm_in, dm_in, em_in, hm_in

! Model timestep

integer*8, intent(in) :: dt_in

! Input variables

year  = year_in
month = month_in
day   = day_in
hour  = hour_in
SW    = SW_in
LW    = LW_in
Sf    = Sf_in
Rf    = Rf_in
Ta    = Ta_in
RH    = RH_in
Ua    = Ua_in
Ps    = Ps_in

! State variables

albs  = albs_in
Ds    = Ds_in
Nsnow = Nsnow_in
Sice  = Sice_in
Sliq  = Sliq_in
theta = theta_in
Tsnow = Tsnow_in
Tsoil = Tsoil_in
Tsurf = Tsurf_in

! Model combinations

am = am_in
cm = cm_in
dm = dm_in
em = em_in
hm = hm_in

! Timestep

dt = dt_in

! Call subroutines

call SET_PARAMETERS

call DRIVE(RH)

call PHYSICS

! State variables

albs_in  = albs
Ds_in    = Ds
Nsnow_in = Nsnow
Sice_in  = Sice
Sliq_in  = Sliq
theta_in = theta
Tsnow_in = Tsnow
Tsoil_in = Tsoil
Tsurf_in = Tsurf

end subroutine
