//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ThermalExpansionU2D.h"
#include "RankTwoTensor.h"
#include "EulerAngleProvider.h"
#include "RotationTensor.h"

registerMooseObject("bengaltigerApp", ThermalExpansionU2D);

template <>
InputParameters
validParams<ThermalExpansionU2D>()
{
  InputParameters params = validParams<ComputeEigenstrainBase>();
  params.addClassDescription(
      "Compute spatially and temporally dependent thermal expansion eigstrain");
  params.addCoupledVar("displacements",
                       "The string of displacements suitable for the problem statement");
  params.addRequiredRangeCheckedParam<unsigned int>(
      "index_i",
      "index_i >= 0 & index_i <= 2",
      "The index i of ij for the tensor to output (0, 1, 2)");
  params.addRequiredRangeCheckedParam<unsigned int>(
      "index_j",
      "index_j >= 0 & index_j <= 2",
      "The index j of ij for the tensor to output (0, 1, 2)");
  params.addCoupledVar("temperature", "Coupled temperature");
  params.addRequiredCoupledVar("stress_free_temperature",
                               "Reference temperature at which there is no "
                               "thermal expansion for thermal eigenstrain "
                               "calculation");
  params.addRequiredCoupledVarWithAutoBuild(
      "v", "var_name_base", "op_num", "Array of coupled variables");
  params.addRequiredParam<UserObjectName>("euler_angle_provider",
                                          "Name of Euler angle provider user object");
  params.addRequiredParam<UserObjectName>("grain_tracker",
                                          "the GrainTracker UserObject to get values from");

  return params;
}

ThermalExpansionU2D::ThermalExpansionU2D(const InputParameters & parameters)
  : DerivativeMaterialInterface<ComputeEigenstrainBase>(parameters),
    _disp_coupled(isCoupled("displacements")),
    _ndisp(_disp_coupled ? coupledComponents("displacements") : 0),
    _i(getParam<unsigned int>("index_i")),
    _j(getParam<unsigned int>("index_j")),
    _temperature(coupledValue("temperature")),
    _deigenstrain_dT(declarePropertyDerivative<RankTwoTensor>(_eigenstrain_name,
                                                              getVar("temperature", 0)->name())),
    _stress_free_temperature(coupledValue("stress_free_temperature")),
    _op_num(coupledComponents("v")),
    _vals(_op_num),
    _euler(getUserObject<EulerAngleProvider>("euler_angle_provider")),
    _grain_tracker(getUserObject<GrainTrackerInterface>("grain_tracker"))
{
  // Loop over variables (ops)
  for (auto op_index = decltype(_op_num)(0); op_index < _op_num; ++op_index)
  {
    // Initialize variables
    _vals[op_index] = &coupledValue("v", op_index);
  }
}

void
ThermalExpansionU2D::computeQpEigenstrain()
{
  if (_ndisp > 2)
    mooseError("ThermalExpansionU2D is only to be used for 2 dimensional problems.");

  // Lloyd, L. T., & Barrett, C. S. (1966). Thermal expansion of alpha Uranium. Journal of Nuclear
  // Materials, 18, 55-59.

  Real cte1 = 24.22e-6 - 9.83e-9 * _temperature[_qp] +
              46.02e-12 * (_temperature[_qp]) * (_temperature[_qp]);
  Real cte2 =
      3.07e-6 + 3.47e-9 * _temperature[_qp] - 38.45e-12 * (_temperature[_qp]) * (_temperature[_qp]);
  Real cte3 = 8.72e-6 + 37.04e-9 * _temperature[_qp] +
              9.08e-12 * (_temperature[_qp]) * (_temperature[_qp]); // Swiping values

  Real theta1 = cte1 * (_temperature[_qp] - _stress_free_temperature[_qp]);
  Real theta2 = cte2 * (_temperature[_qp] - _stress_free_temperature[_qp]);
  Real theta3 = cte3 * (_temperature[_qp] - _stress_free_temperature[_qp]);

  RankTwoTensor I1(1, 0, 0, 0, 0, 0);
  RankTwoTensor I2(0, 1, 0, 0, 0, 0);
  RankTwoTensor I3(0, 0, 1, 0, 0, 0);

  RankTwoTensor theta;

  // RankTwoTensor theta = theta1 * I1 + theta2 * I2 + theta3 * I3;

  if (_i == 0)
  {
    if (_j == 0)
      theta = theta1 * I1 + theta1 * I2;
    else if (_j == 1)
      theta = theta1 * I1 + theta2 * I2;
    else
      theta = theta1 * I1 + theta3 * I2;
  }
  else if (_i == 1)
  {
    if (_j == 0)
      theta = theta2 * I1 + theta1 * I2;
    else if (_j == 1)
      theta = theta2 * I1 + theta2 * I2;
    else
      theta = theta2 * I1 + theta3 * I2;
  }
  else
  {
    if (_j == 0)
      theta = theta3 * I1 + theta1 * I2;
    else if (_j == 1)
      theta = theta3 * I1 + theta2 * I2;
    else
      theta = theta3 * I1 + theta3 * I2;
  }

  Real dtheta1_dt = 24.22e-6 - 9.83e-9 * (2 * _temperature[_qp] - 1) +
                    46.02e-12 * _temperature[_qp] * (3 * _temperature[_qp] - 2);
  Real dtheta2_dt = 3.07e-6 + 3.47e-9 * (2 * _temperature[_qp] - 1) -
                    38.45e-12 * _temperature[_qp] * (3 * _temperature[_qp] - 2);
  Real dtheta3_dt = 8.72e-6 + 37.04e-9 * (2 * _temperature[_qp] - 1) +
                    9.08e-12 * _temperature[_qp] * (3 * _temperature[_qp] - 2);

  RankTwoTensor dtheta_dt;
  // RankTwoTensor dtheta_dt = dtheta1_dt * I1 + dtheta2_dt * I2 + dtheta3_dt * I3;

  if (_i == 0)
  {
    if (_j == 0)
      dtheta_dt = dtheta1_dt * I1 + dtheta1_dt * I2;
    else if (_j == 1)
      dtheta_dt = dtheta1_dt * I1 + dtheta2_dt * I2;
    else
      dtheta_dt = dtheta1_dt * I1 + dtheta3_dt * I2;
  }
  else if (_i == 1)
  {
    if (_j == 0)
      dtheta_dt = dtheta2_dt * I1 + dtheta1_dt * I2;
    else if (_j == 1)
      dtheta_dt = dtheta2_dt * I1 + dtheta2_dt * I2;
    else
      dtheta_dt = dtheta2_dt * I1 + dtheta3_dt * I2;
  }
  else
  {
    if (_j == 0)
      dtheta_dt = dtheta3_dt * I1 + dtheta1_dt * I2;
    else if (_j == 1)
      dtheta_dt = dtheta3_dt * I1 + dtheta2_dt * I2;
    else
      dtheta_dt = dtheta3_dt * I1 + dtheta3_dt * I2;
  }

  _eigenstrain[_qp].zero();
  _deigenstrain_dT[_qp].zero();

  EulerAngles angles;

  Real sum_h = 0.0;

  // get the vector that maps active order parameters to grain ids
  const auto & op_to_grains = _grain_tracker.getVarToFeatureVector(_current_elem->id());

  // loop over the active OPs
  for (auto op_index = beginIndex(op_to_grains); op_index < op_to_grains.size(); ++op_index)
  {

    auto grain_id = op_to_grains[op_index];
    if (op_to_grains[op_index] == FeatureFloodCount::invalid_id)
      continue;

    // make sure you have enough Euler angles in the file and grab the right one
    if (grain_id < _euler.getGrainNum())
      angles = _euler.getEulerAngles(grain_id);
    else
      mooseError("ThermalExpansionU2D has run out of grain rotation data.");

    // Interpolation factor for the eigenstrain tensors - this goes between 0 and 1 if eta is 0 or 1
    // Using standard PF interpolation function.
    // Real n = (*_vals[op_index])[_qp];
    // Real h = n*n*n*(6*n*n - 15*n + 10);

    theta.rotate(RotationTensor(RealVectorValue(angles)));
    dtheta_dt.rotate(RotationTensor(RealVectorValue(angles)));

    // Interpolation factor for elasticity tensors
    Real h = (1.0 + std::sin(libMesh::pi * ((*_vals[op_index])[_qp] - 0.5))) / 2.0;

    RankTwoTensor local_eigenstrain;
    RankTwoTensor local_deigenstrain_dT;

    local_eigenstrain = theta * h;
    local_deigenstrain_dT = dtheta_dt * h;

    // local_eigenstrain.rotate(RotationTensor(RealVectorValue(angles)));
    // local_deigenstrain_dT.rotate(RotationTensor(RealVectorValue(angles)));     // Incorrect way of interpolation function

    _eigenstrain[_qp] += local_eigenstrain;
    _deigenstrain_dT[_qp] += local_deigenstrain_dT;

    sum_h += h;
  }

  // Normalize the tensor to a sum of order parameters = 1...
  // anything divided by near-zero is going to explode
  const Real tol = 1.0e-10;
  sum_h = std::max(sum_h, tol);

  _eigenstrain[_qp] /= sum_h;
  _deigenstrain_dT[_qp] /= sum_h;
}
