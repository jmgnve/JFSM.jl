!-----------------------------------------------------------------------
! Factorial Snow Model
!
! Richard Essery
! School of GeoSciences
! University of Edinburgh
!-----------------------------------------------------------------------


!real, intent(in):: g
!real, intent(out):: o

!o=g

!return


subroutine FSM(year_in, month_in, day_in, hour_in, &
			   SW_in, LW_in, Rf_in, Sf_in, Ta_in, RH_in, Ua_in, Ps_in, &
			   albs_in, Ds_in, Nsnow_in, Sice_in, Sliq_in, theta_in, Tsnow_in, Tsoil_in, Tsurf_in)
  
! Input variables

use DRIVING, only:   &
  year,              &! Year
  month,             &! Month of year
  day,               &! Day of month
  hour,              &! Hour of day
  SW,                &! Incoming shortwave radiation (W/m2)
  LW,                &! Incoming longwave radiation (W/m2)
  Rf,                &! Rainfall rate (kg/m2/s)
  Sf,                &! Snowfall rate (kg/m2/s)
  Ta,                &! Air temperature (K)
  Ua,                &! Wind speed (m/s)
  Ps                  ! Surface pressure (Pa)
  
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
  
implicit none

! Input variables

real, intent(in) :: year_in, month_in, day_in, hour_in, SW_in, LW_in, Rf_in, Sf_in, Ta_in, RH_in, Ua_in, Ps_in

real :: RH  ! Relative humidity (%)

! State variables

integer, intent(out) :: Nsnow_in

real, intent(out) :: albs_in, Tsurf_in

real, intent(out) :: Ds_in(Nsmax), Sice_in(Nsmax), Sliq_in(Nsmax), Tsnow_in(Nsmax)

real, intent(out) :: theta_in(Nsoil), Tsoil_in(Nsoil)

! Input variables

year  = year_in
month = month_in
day   = day_in
hour  = hour_in
SW    = SW_in
LW    = LW_in
Rf    = Rf_in
Sf    = Sf_in
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

call SET_PARAMETERS

!call INITIALIZE

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
