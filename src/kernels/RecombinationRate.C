//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "RecombinationRate.h"

// MOOSE
#include "Function.h"

registerMooseObject("bengaltigerApp", RecombinationRate);

defineLegacyParams(RecombinationRate);

InputParameters
RecombinationRate::validParams()
{
  InputParameters params = Kernel::validParams();
  params.addClassDescription("Demonstrates the multiple ways that scalar values can be introduced "
                             "into kernels, e.g. (controllable) constants, functions, and "
                             "postprocessors. Implements the weak form $(\\psi_i, -f)$.");
  params.addParam<Real>("value", 1.0, "Coefficient to multiply by the body force term");
  params.addParam<MaterialPropertyName>(
      "K1",
      "Rate Coefficient 1",
      "Property name for first rate coefficient");
  params.addParam<MaterialPropertyName>(
      "K2",
      "Rate Coefficient 2",
      "Property name for second rate coefficient");
  params.addParam<MaterialPropertyName>(
      "omega",
      "omega function",
      "Property name for atom volume");
  params.addParam<MaterialPropertyName>(
      "S",
      "Sink Density",
      "Property name for sink density");
  params.addRequiredCoupledVar(
      "v",
      "Variable defining the coupled variable");
  params.addParam<FunctionName>("function", "1", "A function that describes the body force");
  params.addParam<PostprocessorName>(
      "postprocessor", 1, "A postprocessor whose value is multiplied by the body force");
  params.declareControllable("value");
  return params;
}

RecombinationRate::RecombinationRate(const InputParameters & parameters)
  : Kernel(parameters),
    _scale(getParam<Real>("value")),
    _K1(getMaterialProperty<Real>("K1")),
    _K2(getMaterialProperty<Real>("K2")),
    _omega(getMaterialProperty<Real>("omega")),
    _S(getMaterialProperty<Real>("S")),
    _v_var(coupled("v")),
    _v(coupledValue("v")),
    _function(getFunction("function")),
    _postprocessor(getPostprocessorValue("postprocessor"))
{
}

Real
RecombinationRate::computeQpResidual()
{
  Real rate = _K1[_qp] * _omega[_qp] * _omega[_qp] * _u[_qp] * _v[_qp] + _K2[_qp] * _omega[_qp] * _u[_qp] * _S[_qp];
  Real factor = _scale * _postprocessor * _function.value(_t, _q_point[_qp]) * rate;
  return _test[_i][_qp] * -factor;
}
