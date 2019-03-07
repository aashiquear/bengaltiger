//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef COMPUTEEIGENSTRAINBT_H
#define COMPUTEEIGENSTRAINBT_H

#include "ComputeEigenstrainBase.h"
#include "DerivativeMaterialInterface.h"
#include "RankTwoTensor.h"

class ComputeEigenstrainBT;

template <typename>
class RankTwoTensorTempl;
typedef RankTwoTensorTempl<Real> RankTwoTensor;

template <>
InputParameters validParams<ComputeEigenstrainBT>();

/**
 * ComputeEigenstrainBT computes an Eigenstrain that is a function of a single variable defined by a
 * base tensor and a scalar function defined in a Derivative Material.
 */
class ComputeEigenstrainBT : public DerivativeMaterialInterface<ComputeEigenstrainBase>
{
public:
  ComputeEigenstrainBT(const InputParameters & parameters);

protected:
  virtual void computeQpEigenstrain() override;

  const MaterialProperty<Real> & _prefactor;
  const VariableValue & _temperature;
  MaterialProperty<RankTwoTensor> & _deigenstrain_dT;

  RankTwoTensor _eigen_base_tensor;
};

#endif // COMPUTEEIGENSTRAINBT_H
