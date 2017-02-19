!-----------------------------------------------------------------------
! Initialize state variables and cumulated diagnostics
!-----------------------------------------------------------------------
subroutine INITIALIZE

use CONSTANTS, only : &
  rho_wat,           &! Density of water (kg/m^3)
  Tm                  ! Melting point (K)

use GRID, only : &
  Nsoil,             &! Number of soil layers
  Dzsoil              ! Soil layer thicknesses (m)

use SOIL_PARAMS, only : &
  Vsat                ! Volumetric soil moisture content at saturation

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

implicit none

integer :: &
  k                   ! Level counter

real :: &
  fsat(Nsoil)         ! Initial moisture content of soil layers as fractions of saturation

! No snow in initial state
albs = 0.8
Ds(:) = 0
Nsnow = 0
Sice(:) = 0
Sliq(:) = 0
Tsnow(:) = Tm

! Initial soil profiles from namelist
fsat(:) = 0.5
Tsoil(:) = 285.
Tsurf = Tsoil(1)
do k = 1, Nsoil
  theta(k) = fsat(k)*Vsat
end do

end subroutine INITIALIZE
