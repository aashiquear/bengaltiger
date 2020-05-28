//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "RecombinationRate.h"

#include "Function.h"

registerADMooseObject("bengaltigerApp", RecombinationRate);

defineADLegacyParams(RecombinationRate);

template <ComputeStage compute_stage>
InputParameters
RecombinationRate<compute_stage>::validParams()
{
  InputParameters params = ADKernelValue<compute_stage>::validParams();
  params.addClassDescription("Recombination rate for the radiation induced segregation");
  params.addParam<Real>("value", 1.0, "Coefficient to multiply by the body force term");
  params.addParam<MaterialPropertyName>("K", "K_iv", "Property name for rate coefficient");
  params.addParam<MaterialPropertyName>("omega", 1.0, "Property name for atom volume");
  params.addRequiredCoupledVar("v", "Variable defining the coupled variable");
  params.addParam<FunctionName>("function", "1", "A function that describes the body force");
  params.addParam<PostprocessorName>(
      "postprocessor", 1, "A postprocessor whose value is multiplied by the body force");
  params.declareControllable("value");
  return params;
}

template <ComputeStage compute_stage>
RecombinationRate<compute_stage>::RecombinationRate(const InputParameters & parameters)
  : ADKernelValue<compute_stage>(parameters),
    _scale(getParam<Real>("value")),
    _K(getMaterialProperty<Real>("K")),
    _omega(getMaterialProperty<Real>("omega")),
    _v_var(coupled("v")),
    _v(coupledValue("v")),
    _function(getFunction("function")),
    _postprocessor(getPostprocessorValue("postprocessor"))
{
}

template <ComputeStage compute_stage>
ADReal
RecombinationRate<compute_stage>::precomputeQpResidual()
{
  ADReal rate = _K[_qp] * _omega[_qp] * _u[_qp] * _v[_qp];
  return -_scale * _postprocessor * _function.value(_t, _q_point[_qp]) * rate;
}
