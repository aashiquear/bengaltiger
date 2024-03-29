//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef aUThermalExpansionEigenstrain_H
#define aUThermalExpansionEigenstrain_H

#include "ComputeEigenstrainBase.h"
#include "DerivativeMaterialInterface.h"
#include "RankTwoTensor.h"
#include "GrainTrackerInterface.h"

class aUThermalExpansionEigenstrain;
template <typename>
class RankTwoTensorTempl;
typedef RankTwoTensorTempl<Real> RankTwoTensor;
class EulerAngleProvider;
class RotationTensor;
class GrainTrackerInterface;

template <>
InputParameters validParams<aUThermalExpansionEigenstrain>();

/**
 * aUThermalExpansionEigenstrain is a class for models that
 * compute eigenstrains due to thermal expansion of an alpha Uranium material
   swiping its [010] and [001] material properties.
 */
class aUThermalExpansionEigenstrain : public DerivativeMaterialInterface<ComputeEigenstrainBase>
{
public:
  aUThermalExpansionEigenstrain(const InputParameters & parameters);

protected:
  virtual void computeQpEigenstrain() override;
  /*
   * Compute the total thermal strain relative to the stress-free temperature at
   * the current temperature, as well as the current instantaneous thermal
   * expansion coefficient.
   * param thermal_strain    The current total linear thermal strain
   *                         (\delta L / L)
   * param instantaneous_cte The current instantaneous coefficient of thermal
   *                         expansion (derivative of thermal_strain wrt
   *                         temperature
   */
  // virtual void computeThermalStrain(Real & thermal_strain, Real & instantaneous_cte) = 0;

  const bool _disp_coupled;
  unsigned int _ndisp;

  const unsigned int _i;
  const unsigned int _j;

  const VariableValue & _temperature;
  MaterialProperty<RankTwoTensor> & _deigenstrain_dT;
  const VariableValue & _stress_free_temperature;

  /// Anisotropic thermal expansion coefficient
  // const Real & _thermal_expansion_coeff1;
  // const Real & _thermal_expansion_coeff2;
  // const Real & _thermal_expansion_coeff3;

  /// Number of order parameters
  const unsigned int _op_num;

  /// Order parameters
  std::vector<const VariableValue *> _vals;

  /// object providing the Euler angles
  const EulerAngleProvider & _euler;

  /// Grain tracker used to get unique grain IDs
  const GrainTrackerInterface & _grain_tracker;
};

#endif // COMPUTETHERMALEXPANSIONEIGENSTRAINBASE_H
