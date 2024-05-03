#include "fabm_driver.h"

module rbins_base_model
   use fabm_types

   implicit none

   private

   type, extends(type_base_model), public :: type_rbins_base_model ! it is a coincidence that I chose the same base_model as the type_base_model but it's not at all related...
      type (type_state_variable_id) :: id_p, id_d, id_o2
      type (type_bottom_state_variable_id) :: id_pbenthos
      type (type_dependency_id) :: id_temp
      type (type_surface_dependency_id) :: id_I_0, id_wind
      real(rk) :: k_f, k_b
   contains      
      procedure :: initialize
      procedure :: do
      procedure :: do_surface
      procedure :: do_bottom
   end type

contains

  subroutine initialize(self, configunit)
    class (type_rbins_base_model), intent(inout), target :: self
    integer,                  intent(in)            :: configunit

    real(rk), parameter :: d_per_s = 1.0_rk/86400.0_rk ! example taken from https://github.com/fabm-model/fabm/blob/master/src/models/examples/npzd/phy.F90 (note: better declare it before the call to self%register_implemented_routine((/source_do/))
    real(rk) :: w_p ! sinking speed

    call self%register_implemented_routines((/source_do/))
 
    ! parameters
    call self%get_parameter(self%k_f, 'k_f', 'day-1', 'fixation rate', default=0.2_rk, scale_factor=d_per_s)
    call self%get_parameter(w_p, 'w_p', 'm day-1', 'vertical velocity (<0 for sinking)', default=-1.0_rk, scale_factor=d_per_s)
    call self%get_parameter(self%k_b, 'k_b', 'day-1', 'benthic dissolution rate', scale_factor=d_per_s) 

    ! state variables 
    call self%register_state_variable(self%id_p, 'p', 'mmolC m-3', 'particulate concentration', initial_value=200.0_rk, minimum=0.0_rk, vertical_movement=w_p) 
    call self%register_state_variable(self%id_d, 'd', 'mmolC m-3', 'dissolved concentration', minimum=0.0_rk)
    call self%register_state_variable(self%id_pbenthos, 'pbenthos', 'mmolC m-3', 'benthic particulate concentration')
    call self%register_state_variable(self%id_o2, 'oxy', 'mmol O2/m3', 'oxygen', initial_value=350.0_rk)
    
    ! dependencies
    call self%register_dependency(self%id_temp, standard_variables%temperature)
    call self%register_dependency(self%id_I_0,  standard_variables%surface_downwelling_photosynthetic_radiative_flux)
    call self%register_dependency(self%id_wind, standard_variables%wind_speed)    
  end subroutine initialize

  subroutine do(self, _ARGUMENTS_DO_)
    class (type_rbins_base_model), intent(in) :: self
    _DECLARE_ARGUMENTS_DO_

    real(rk) :: d
    real(rk) :: temp

    _LOOP_BEGIN_
        _GET_(self%id_d, d)
        _GET_(self%id_temp, temp)

        ! Send rates of change to FABM.
        _ADD_SOURCE_(self%id_p, self%k_f*d)
        _ADD_SOURCE_(self%id_d, -self%k_f*d)
        ! Uncomment below to check that we do read the temperature variable (note that you need to comment the _ADD_SOURCE_ in dissolution.F90
        !_ADD_SOURCE_(self%id_d, temp)

    _LOOP_END_
  end subroutine do

! add air-sea flux routine to "base-model" (really should have thought this through before calling it that way)
  subroutine do_surface(self, _ARGUMENTS_DO_SURFACE_)
     class (type_rbins_base_model), intent(in) :: self
     _DECLARE_ARGUMENTS_DO_SURFACE_

     real(rk) :: wind, o2

     _SURFACE_LOOP_BEGIN_
        _GET_HORIZONTAL_(self%id_wind, wind)
        _GET_(self%id_o2, o2)

        _ADD_SURFACE_FLUX_(self%id_o2, 5)	

     _SURFACE_LOOP_END_
  end subroutine do_surface

! add bottom flux routine
  subroutine do_bottom(self, _ARGUMENTS_DO_BOTTOM_)
     class (type_rbins_base_model), intent(in) :: self
     _DECLARE_ARGUMENTS_DO_BOTTOM_

     real(rk) :: pbenthos
 
     _BOTTOM_LOOP_BEGIN_
         !_GET_BOTTOM_(self%id_pbenthos, pbenthos)
         _GET_HORIZONTAL_(self%id_pbenthos, pbenthos)

         ! send rates of change to FABM
         _ADD_BOTTOM_SOURCE_(self%id_pbenthos, -2*pbenthos)
        !_ADD_BOTTOM_FLUX_(self%id_p, 5) ! just to check something, might be used later on
     _BOTTOM_LOOP_END_

  end subroutine do_bottom

end module
