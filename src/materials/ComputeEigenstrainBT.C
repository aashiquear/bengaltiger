//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ComputeEigenstrainBT.h"

registerMooseObject("bengaltigerApp", ComputeEigenstrainBT);

template <>
InputParameters
validParams<ComputeEigenstrainBT>()
{
  InputParameters params = validParams<ComputeEigenstrainBase>();
  params.addClassDescription("Computes a constant Eigenstrain");
  params.addRequiredParam<std::vector<Real>>(
      "eigen_base", "Vector of values defining the constant base tensor for the Eigenstrain");
  params.addParam<MaterialPropertyName>(
      "prefactor", 1.0, "Name of material defining the variable dependence");
  params.addCoupledVar("temperature", "Coupled temperature");
  return params;
}

ComputeEigenstrainBT::ComputeEigenstrainBT(const InputParameters & parameters)
  : DerivativeMaterialInterface<ComputeEigenstrainBase>(parameters),
    _prefactor(getMaterialProperty<Real>("prefactor")),
    _temperature(coupledValue("temperature")),
    _deigenstrain_dT(declarePropertyDerivative<RankTwoTensor>(_eigenstrain_name,
                                                              getVar("temperature", 0)->name()))
{
  _eigen_base_tensor.fillFromInputVector(getParam<std::vector<Real>>("eigen_base"));
}

void
ComputeEigenstrainBT::computeQpEigenstrain()
{
  // Define Eigenstrain
  _eigenstrain[_qp] = _eigen_base_tensor * _prefactor[_qp];
  _deigenstrain_dT[_qp] = _eigen_base_tensor;
}
