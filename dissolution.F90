#include "fabm_driver.h"

module rbins_dissolution
   use fabm_types

   implicit none

   private

   type, extends(type_base_model), public :: type_rbins_dissolution
      type (type_state_variable_id) :: id_p, id_d
      type (type_dependency_id) :: id_temp ! add external dependency for temperature
      real(rk) :: k_d 
   contains
      procedure :: initialize
      procedure :: do
   end type

contains

  subroutine initialize(self, configunit)
    class (type_rbins_dissolution), intent(inout), target :: self
    integer,                  intent(in)            :: configunit

    call self%register_implemented_routines((/source_do/))

    call self%get_parameter(self%k_d, 'k_d', 'day-1', 'dissolution rate', default=0.3_rk, scale_factor=1.0_rk/86400.0_rk)
    
    ! we create a dependency for a coupling in fabm.yaml with the "base_model"
    call self%register_state_dependency(self%id_p, 'p', 'mmolC m-3', 'particulate concentration') ! no need for vertical_movement, minimum_value or other things because it is register_state_DEPENDENCY (see base_model for the difference and the fabm.yaml file)
    call self%register_state_dependency(self%id_d, 'd', 'mmolC m-3', 'dissolved concentration')
   
    ! add external forcing
    call self%register_dependency(self%id_temp, standard_variables%temperature) ! With this form, we enable implicit coupling (see wiki for more explanations) 
 
  end subroutine initialize

  subroutine do(self, _ARGUMENTS_DO_)
    class (type_rbins_dissolution), intent(in) :: self
    _DECLARE_ARGUMENTS_DO_

    real(rk) :: p
    real(rk) :: temp

    _LOOP_BEGIN_
        ! Obtain concentration of nutrients
        _GET_(self%id_p, p)

        ! access to registered dependencies
        _GET_(self%id_temp, temp)

        ! Send rates of change to FABM.
        _ADD_SOURCE_(self%id_p, -self%k_d*p)
        _ADD_SOURCE_(self%id_d, self%k_d*p)

        _LOOP_END_
  end subroutine do

end module
