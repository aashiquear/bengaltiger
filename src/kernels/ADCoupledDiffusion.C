//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ADCoupledDiffusion.h"

registerADMooseObject("bengaltigerApp", ADCoupledDiffusion);

InputParameters
ADCoupledDiffusion::validParams()
{
  InputParameters params = ADKernelGrad::validParams();
  params.addClassDescription(
      "Computes residual/Jacobian contribution for $(D * \\chi * u * \\nabla v, \\nabla \\psi)$ term.");
  params.addParam<MaterialPropertyName>(
      "diffusivity",
      "The name of the diffusivity",
      "Property name of the diffusivity");
  params.addParam<MaterialPropertyName>(
      "chi",
      "chi function",
      "Property name that account for the difference between chemical potential gradient");
  params.addParam<MaterialPropertyName>(
      "omega",
      "omega function",
      "Property name for atom volume");
  params.addRequiredCoupledVar(
      "v",
      "Variable defining the solid atomic fraction");
  params.set<bool>("use_displaced_mesh") = true;
  return params;
}

ADCoupledDiffusion::ADCoupledDiffusion(const InputParameters & parameters)
  : ADKernelGrad(parameters),
    _D(getMaterialProperty<Real>("diffusivity")),
    _chi(getMaterialProperty<Real>("chi")),
    _omega(getMaterialProperty<Real>("omega")),
    _v_var(coupled("v")),
    _v(coupledValue("v")),
    _grad_v(coupledGradient("v"))
{
}

ADRealVectorValue
ADCoupledDiffusion::precomputeQpResidual()
{
  return _D[_qp] * _chi[_qp] * _omega[_qp] * _u[_qp] * _grad_v[_qp];
}
