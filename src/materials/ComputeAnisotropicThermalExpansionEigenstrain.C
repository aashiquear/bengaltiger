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
  params.addCoupledVar("temperature", "Coupled temperature");
  params.addRequiredCoupledVar("stress_free_temperature",
                               "Reference temperature at which there is no "
                               "thermal expansion for thermal eigenstrain "
                               "calculation");
  params.addRequiredParam<Real>("thermal_expansion_coeff1", "Thermal expansion coefficient 1");
  params.addRequiredParam<Real>("thermal_expansion_coeff2", "Thermal expansion coefficient 2");
  params.addRequiredParam<Real>("thermal_expansion_coeff3", "Thermal expansion coefficient 3");
  params.addRequiredParam<UserObjectName>("euler_angle_provider",
                                          "Name of Euler angle provider user object");

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
    _euler(getUserObject<EulerAngleProvider>("euler_angle_provider"))
{
}

void
ComputeAnisotropicThermalExpansionEigenstrain::computeQpEigenstrain()
{
  // Real thermal_strain = 0.0;
  // Real instantaneous_cte = 0.0;

  // computeThermalStrain(thermal_strain, instantaneous_cte);

  Real theta1 = _thermal_expansion_coeff1 * (_temperature[_qp] - _stress_free_temperature[_qp]);
  Real theta2 = _thermal_expansion_coeff2 * (_temperature[_qp] - _stress_free_temperature[_qp]);
  Real theta3 = _thermal_expansion_coeff3 * (_temperature[_qp] - _stress_free_temperature[_qp]);

  RankTwoTensor I1(1, 0, 0, 0, 0, 0);
  RankTwoTensor I2(0, 1, 0, 0, 0, 0);
  RankTwoTensor I3(0, 0, 1, 0, 0, 0);

  RankTwoTensor theta = theta1 * I1 + theta2 * I2 + theta3 * I3;
  Real instantaneous_cte =
      (_thermal_expansion_coeff1 + _thermal_expansion_coeff2 + _thermal_expansion_coeff3) * (1 / 3);

  EulerAngles angles;

  angles.random();

  theta.rotate(RotationTensor(RealVectorValue(angles)));

  _eigenstrain[_qp].zero();
  //_eigenstrain[_qp].addIa(thermal_strain);
  _eigenstrain[_qp] = theta;

  _deigenstrain_dT[_qp].zero();
  _deigenstrain_dT[_qp].addIa(instantaneous_cte);
}
