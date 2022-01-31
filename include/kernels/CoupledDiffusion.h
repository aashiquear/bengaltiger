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
#include "Material.h"
#include "DerivativeMaterialInterface.h"

class CoupledDiffusion : public Kernel
{
public:
  static InputParameters validParams();

  CoupledDiffusion(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

private:
  const MaterialProperty<Real> & _D;
  const MaterialProperty<Real> & _chi;
  const MaterialProperty<Real> & _omega;

  const unsigned int _v_var;

  const VariableValue & _v;

  const VariableGradient & _grad_v;
};
