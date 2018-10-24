//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef COMPUTEANISOTROPICTHERMALEXPANSIONEIGENSTRAIN_H
#define COMPUTEANISOTROPICTHERMALEXPANSIONEIGENSTRAIN_H

#include "ComputeEigenstrainBase.h"
#include "DerivativeMaterialInterface.h"

class ComputeAnisotropicThermalExpansionEigenstrain;
class RankTwoTensor;
class EulerAngleProvider;
class RotationTensor;

template <>
InputParameters validParams<ComputeAnisotropicThermalExpansionEigenstrain>();

/**
 * ComputeAnisotropicThermalExpansionEigenstrain is a class for models that
 * compute eigenstrains due to thermal expansion of an anisotropic material.
 */
class ComputeAnisotropicThermalExpansionEigenstrain
    : public DerivativeMaterialInterface<ComputeEigenstrainBase>
{
public:
  ComputeAnisotropicThermalExpansionEigenstrain(const InputParameters & parameters);

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
  //virtual void computeThermalStrain(Real & thermal_strain, Real & instantaneous_cte) = 0;

  const VariableValue & _temperature;
  MaterialProperty<RankTwoTensor> & _deigenstrain_dT;
  const VariableValue & _stress_free_temperature;

  const Real & _thermal_expansion_coeff1;
  const Real & _thermal_expansion_coeff2;
  const Real & _thermal_expansion_coeff3;

  const EulerAngleProvider & _euler;
};

#endif // COMPUTETHERMALEXPANSIONEIGENSTRAINBASE_H
