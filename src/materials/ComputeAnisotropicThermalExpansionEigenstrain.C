//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ComputeAnisotropicThermalExpansionEigenstrain.h"
#include "RankTwoTensor.h"
#include "EulerAngleProvider.h"
#include "RotationTensor.h"

registerMooseObject("bengaltigerApp", ComputeAnisotropicThermalExpansionEigenstrain);
// registerMaterials(ComputeAnisotropicThermalExpansionEigenstrain);

template <>
InputParameters
validParams<ComputeAnisotropicThermalExpansionEigenstrain>()
{
  InputParameters params = validParams<ComputeEigenstrainBase>();
  params.addClassDescription(
    "Compute spatially and temporally dependent thermal expansion eigstrain");
  params.addCoupledVar("temperature", "Coupled temperature");
  params.addRequiredCoupledVar("stress_free_temperature",
                               "Reference temperature at which there is no "
                               "thermal expansion for thermal eigenstrain "
                               "calculation");
  params.addRequiredParam<Real>("thermal_expansion_coeff1", "Thermal expansion coefficient 1");
  params.addRequiredParam<Real>("thermal_expansion_coeff2", "Thermal expansion coefficient 2");
  params.addRequiredParam<Real>("thermal_expansion_coeff3", "Thermal expansion coefficient 3");
  params.addRequiredCoupledVarWithAutoBuild(
      "v", "var_name_base", "op_num", "Array of coupled variables");
  params.addRequiredParam<UserObjectName>("euler_angle_provider",
                                          "Name of Euler angle provider user object");
  params.addRequiredParam<UserObjectName>("grain_tracker",
                                          "the GrainTracker UserObject to get values from");

  return params;
}

ComputeAnisotropicThermalExpansionEigenstrain::ComputeAnisotropicThermalExpansionEigenstrain(
    const InputParameters & parameters)
  : DerivativeMaterialInterface<ComputeEigenstrainBase>(parameters),
    _temperature(coupledValue("temperature")),
    _deigenstrain_dT(declarePropertyDerivative<RankTwoTensor>(_eigenstrain_name,
                                                              getVar("temperature", 0)->name())),
    _stress_free_temperature(coupledValue("stress_free_temperature")),
    _thermal_expansion_coeff1(getParam<Real>("thermal_expansion_coeff1")),
    _thermal_expansion_coeff2(getParam<Real>("thermal_expansion_coeff2")),
    _thermal_expansion_coeff3(getParam<Real>("thermal_expansion_coeff3")),
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
ComputeAnisotropicThermalExpansionEigenstrain::computeQpEigenstrain()
{
  Real theta1 = _thermal_expansion_coeff1 * (_temperature[_qp] - _stress_free_temperature[_qp]);
  Real theta2 = _thermal_expansion_coeff2 * (_temperature[_qp] - _stress_free_temperature[_qp]);
  Real theta3 = _thermal_expansion_coeff3 * (_temperature[_qp] - _stress_free_temperature[_qp]);

  RankTwoTensor I1(1, 0, 0, 0, 0, 0);
  RankTwoTensor I2(0, 1, 0, 0, 0, 0);
  RankTwoTensor I3(0, 0, 1, 0, 0, 0);

  RankTwoTensor theta0 = theta1 * I1 + theta2 * I2 + theta3 * I3;
  RankTwoTensor dtheta_dt0 = _thermal_expansion_coeff1 * I1 + _thermal_expansion_coeff2 * I2 +
                             _thermal_expansion_coeff3 * I3;

  _eigenstrain[_qp].zero();
  _deigenstrain_dT[_qp].zero();

  Real sum_h = 0.0;

  //get the vector that maps active order parameters to grain ids
  const auto & op_to_grains = _grain_tracker.getVarToFeatureVector(_current_elem->id());

  //loop over the active OPs
  for (auto op_index = beginIndex(op_to_grains); op_index < op_to_grains.size(); ++op_index)
  {

    auto grain_id = op_to_grains[op_index];
    if (op_to_grains[op_index] == FeatureFloodCount::invalid_id)
        continue;

    EulerAngles angles;
    //make sure you have enough Euler angles in the file and grab the right one
    if (grain_id < _euler.getGrainNum())
      angles = _euler.getEulerAngles(grain_id);
    else
      mooseError("ComputeAnisotropicThermalExpansionEigenstrain has run out of grain rotation data.");

    //Interpolation factor for the eigenstrain tensors - this goes between 0 and 1 if eta is 0 or 1
    //Using standard PF interpolation function.
    // Real n = (*_vals[op_index])[_qp];
    // Real h = n*n*n*(6*n*n - 15*n + 10);

    RankTwoTensor theta = theta0;
    RankTwoTensor dtheta_dt = dtheta_dt0;
    theta.rotate(RotationTensor(RealVectorValue(angles)));
    dtheta_dt.rotate(RotationTensor(RealVectorValue(angles)));

    // Interpolation factor for elasticity tensors
    Real h = (1.0 + std::sin(libMesh::pi * ((*_vals[op_index])[_qp] - 0.5))) / 2.0;

    RankTwoTensor local_eigenstrain;
    RankTwoTensor local_deigenstrain_dT;

    local_eigenstrain = theta * h;
    local_deigenstrain_dT = dtheta_dt * h;

    // local_eigenstrain.rotate(RotationTensor(RealVectorValue(angles)));
    // local_deigenstrain_dT.rotate(RotationTensor(RealVectorValue(angles)));

    _eigenstrain[_qp] += local_eigenstrain;
    _deigenstrain_dT[_qp] += local_deigenstrain_dT;

    sum_h += h;
  }

  //Normalize the tensor to a sum of order parameters = 1...
  //anything divided by near-zero is going to explode
  const Real tol = 1.0e-10;
  sum_h = std::max(sum_h, tol);

  _eigenstrain[_qp] /= sum_h;
  _deigenstrain_dT[_qp] /= sum_h;
}
