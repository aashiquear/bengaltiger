//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "CTEUSingleCrystal.h"
#include "RankTwoTensor.h"
#include "EulerAngleProvider.h"
#include "RotationTensor.h"

registerMooseObject("bengaltigerApp", CTEUSingleCrystal);

template <>
InputParameters
validParams<CTEUSingleCrystal>()
{
  InputParameters params = validParams<ComputeEigenstrainBase>();
  params.addClassDescription(
      "Compute spatially and temporally dependent thermal expansion eigenstrain");
  params.addCoupledVar("temperature", "Coupled temperature");
  params.addRequiredCoupledVar("stress_free_temperature",
                               "Reference temperature at which there is no "
                               "thermal expansion for thermal eigenstrain "
                               "calculation");
  return params;
}

CTEUSingleCrystal::CTEUSingleCrystal(const InputParameters & parameters)
  : DerivativeMaterialInterface<ComputeEigenstrainBase>(parameters),
    _temperature(coupledValue("temperature")),
    _deigenstrain_dT(declarePropertyDerivative<RankTwoTensor>(_eigenstrain_name,
                                                              getVar("temperature", 0)->name())),
    _stress_free_temperature(coupledValue("stress_free_temperature"))
{
}

void
CTEUSingleCrystal::computeQpEigenstrain()
{
  // Lloyd, L. T., & Barrett, C. S. (1966). Thermal expansion of alpha Uranium. Journal of Nuclear
  // Materials, 18, 55-59.

  Real cte1 = 24.22e-6 - 9.83e-9 * _temperature[_qp] +
              46.02e-12 * (_temperature[_qp]) * (_temperature[_qp]);
  Real cte2 =
      3.07e-6 + 3.47e-9 * _temperature[_qp] - 38.45e-12 * (_temperature[_qp]) * (_temperature[_qp]);
  Real cte3 =
      8.72e-6 + 37.04e-9 * _temperature[_qp] + 9.08e-12 * (_temperature[_qp]) * (_temperature[_qp]);

  Real theta1 = cte1 * (_temperature[_qp] - _stress_free_temperature[_qp]);
  Real theta2 = cte2 * (_temperature[_qp] - _stress_free_temperature[_qp]);
  Real theta3 = cte3 * (_temperature[_qp] - _stress_free_temperature[_qp]);

  RankTwoTensor I1(1, 0, 0, 0, 0, 0);
  RankTwoTensor I2(0, 1, 0, 0, 0, 0);
  RankTwoTensor I3(0, 0, 1, 0, 0, 0);

  RankTwoTensor theta0 = theta1 * I1 + theta2 * I2 + theta3 * I3; // theta0

  Real dtheta1_dt = 24.22e-6 - 9.83e-9 * (2 * _temperature[_qp] - 1) +
                    46.02e-12 * _temperature[_qp] * (3 * _temperature[_qp] - 2);
  Real dtheta2_dt = 3.07e-6 + 3.47e-9 * (2 * _temperature[_qp] - 1) -
                    38.45e-12 * _temperature[_qp] * (3 * _temperature[_qp] - 2);
  Real dtheta3_dt = 8.72e-6 + 37.04e-9 * (2 * _temperature[_qp] - 1) +
                    9.08e-12 * _temperature[_qp] * (3 * _temperature[_qp] - 2);

  RankTwoTensor dtheta_dt0 = dtheta1_dt * I1 + dtheta2_dt * I2 + dtheta3_dt * I3;

  _eigenstrain[_qp].zero();
  _deigenstrain_dT[_qp].zero();

  _eigenstrain[_qp] = theta0;
  _deigenstrain_dT[_qp] = dtheta_dt0;
}
