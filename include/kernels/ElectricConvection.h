//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "Kernel.h"
#include "JvarMapInterface.h"
#include "DerivativeMaterialInterface.h"

// Forward Declaration
class ElectricConvection;

template <>
InputParameters validParams<ElectricConvection>();

/**

 */
class ElectricConvection : public DerivativeMaterialInterface<JvarMapKernelInterface<Kernel>>
{
public:
  ElectricConvection(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  // virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  const VariableValue & _V;
  const VariableGradient & _grad_V;

  /// Diffusivity material property
  const MaterialProperty<Real> & _D;

  /// Will be set from the input file
  const Real & _z;
  const Real & _R;
  const Real & _F;
  const Real & _T;
  const Real & _V_a;
  const Real & _nabla_phi_OM;
  const Real & _e_r;
  const Real & _L;
};
