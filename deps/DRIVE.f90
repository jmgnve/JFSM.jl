!-----------------------------------------------------------------------
! Read point driving data
!-----------------------------------------------------------------------
subroutine DRIVE(RH)

use DRIVING, only: &
  year,              &! Year
  month,             &! Month of year
  day,               &! Day of month
  hour,              &! Hour of day
  LW,                &! Incoming longwave radiation (W/m2)
  Ps,                &! Surface pressure (Pa)
  Qa,                &! Specific humidity (kg/kg)
  Rf,                &! Rainfall rate (kg/m2/s)
  Sf,                &! Snowfall rate (kg/m2/s)
  SW,                &! Incoming shortwave radiation (W/m2)
  Ta,                &! Air temperature (K)
  Ua                  ! Wind speed (m/s)

implicit none

real*8 :: &
  Qs,                &! Saturation specific humidity
  RH                  ! Relative humidity (%)

Ua = max(Ua, 0.1)
call QSAT(.TRUE.,Ps,Ta,Qs)
Qa = (RH/100)*Qs
return

end subroutine DRIVE
