//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ElectricConvection.h"

registerMooseObject("bengaltigerApp", ElectricConvection);

template <>
InputParameters
validParams<ElectricConvection>()
{
  InputParameters params = Kernel::validParams();
  params.addClassDescription("Transport function for electric migration.");
  params.addRequiredCoupledVar("potential", "Potential change over the system");
  params.addParam<MaterialPropertyName>("diffusivity", "The diffusivity used with the kernel");
  params.addRequiredParam<Real>("z", "Effective charge number");
  params.addParam<Real>("R", 8.314, "Gas constant in SI unit");
  params.addParam<Real>("F", 96485.33, "Faraday's constant in C/mol");
  params.addParam<Real>("T", 300.0, "Temperature in K");
  params.addParam<Real>("V_a", 0.5, "Applied potential in Volts");
  params.addParam<Real>("nabla_phi_OM", 0.001, "Metal-oxide potential drops in Volts");
  params.addParam<Real>("e_r", 1.5, "Dielectric constant ratio");
  params.addParam<Real>("L", 10e-9, "Oxide film thickness in m");

  return params;
}

ElectricConvection::ElectricConvection(const InputParameters & parameters)
  : DerivativeMaterialInterface<JvarMapKernelInterface<Kernel>>(parameters),
    _V(coupledValue("potential")),
    _grad_V(coupledGradient("potential")),
    _D(getMaterialProperty<Real>("diffusivity")),
    _z(getParam<Real>("z")),
    _R(getParam<Real>("R")),
    _F(getParam<Real>("F")),
    _T(getParam<Real>("T")),
    _V_a(getParam<Real>("V_a")),
    _nabla_phi_OM(getParam<Real>("nabla_phi_OM")),
    _e_r(getParam<Real>("e_r")),
    _L(getParam<Real>("L"))
{
}

Real
ElectricConvection::computeQpResidual()
{
  // RealGradient grad_phi_O = -( _V_a - _nabla_phi_OM) / ( _e_r + _L);
  // RealVectorValue grad_phi_O = -(_grad_V[_qp]) * ( _V_a - _nabla_phi_OM) / ( _e_r + _L);
  // Real electrical_velocity = -_D[_qp] * _grad_u[_qp] * (_z * _F * grad_phi_O / ( _R * _T));

  return _D[_qp] * _grad_u[_qp] * _z * _F * _grad_V[_qp] / (_R * _T) * _test[_i][_qp];
}

Real
ElectricConvection::computeQpJacobian()
{
  // RealGradient grad_phi_O = -( _V_a - _nabla_phi_OM) / ( _e_r + _L);
  // RealVectorValue grad_phi_O = -(_grad_V[_qp]) * ( _V_a - _nabla_phi_OM) / ( _e_r + _L);
  // Real electrical_velocity = -_D[_qp] * _grad_phi[_j][_qp] * (_z * _F * grad_phi_O / ( _R * _T));

  return _D[_qp] * _grad_phi[_j][_qp] * _z * _F * _grad_V[_qp] / (_R * _T) * _test[_i][_qp];
}
