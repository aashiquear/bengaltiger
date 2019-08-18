/****************************************************************/
/*                  DO NOT MODIFY THIS HEADER                   */
/*                           Marmot                             */
/*                                                              */
/*            (c) 2017 Battelle Energy Alliance, LLC            */
/*                     ALL RIGHTS RESERVED                      */
/*                                                              */
/*          Prepared by Battelle Energy Alliance, LLC           */
/*             Under Contract No. DE-AC07-05ID14517             */
/*             With the U. S. Department of Energy              */
/*                                                              */
/*             See COPYRIGHT for full restrictions              */
/****************************************************************/

#include "PolycrystalBurnupEigenstrain.h"
#include "EulerAngleProvider.h"
#include "RotationTensor.h"
#include "RankTwoScalarTools.h"

registerMooseObject("bengaltigerApp", PolycrystalBurnupEigenstrain);

template <>
InputParameters
validParams<PolycrystalBurnupEigenstrain>()
{
  InputParameters params = validParams<ComputeEigenstrainBase>();
  params.addClassDescription(
      "Compute spatially and temporally dependent eigstrain coupled to auxvars");
  params.addRequiredCoupledVarWithAutoBuild(
      "v", "var_name_base", "op_num", "Array of coupled variables");
  params.addRequiredParam<UserObjectName>("euler_angle_provider",
                                          "Name of Euler angle provider user object");
  params.addRequiredParam<std::vector<Real>>("eigen_base",
                                             "Vector of values defining the starting eigenstrain");
  params.addRequiredParam<std::vector<Real>>(
      "eigen_rate", "Vector of values defining the eigenstrain rate of change as fxn of burnup");
  params.addRequiredCoupledVar("burnup", "name of the coupled burnup variable");
  params.addRequiredParam<UserObjectName>("grain_tracker",
                                          "the GrainTracker UserObject to get values from");

  return params;
}

PolycrystalBurnupEigenstrain::PolycrystalBurnupEigenstrain(const InputParameters & parameters)
  : ComputeEigenstrainBase(parameters),
    _euler(getUserObject<EulerAngleProvider>("euler_angle_provider")),
    _op_num(coupledComponents("v")),
    _vals(_op_num),
    _b(coupledValue("burnup")),
    _grain_tracker(getUserObject<GrainTrackerInterface>("grain_tracker"))
{
  _eigen_base = getParam<std::vector<Real>>("eigen_base");
  _eigen_rate = getParam<std::vector<Real>>("eigen_rate");

  _eigen_base_tensor.fillFromInputVector(getParam<std::vector<Real>>("eigen_base"));
  _eigen_rate_tensor.fillFromInputVector(getParam<std::vector<Real>>("eigen_rate"));

  // Loop over variables (ops)
  for (auto op_index = decltype(_op_num)(0); op_index < _op_num; ++op_index)
  {
    // Initialize variables
    _vals[op_index] = &coupledValue("v", op_index);
  }
}

void
PolycrystalBurnupEigenstrain::computeQpEigenstrain()
{
  _eigenstrain[_qp].zero();

  EulerAngles angles;

  Real sum_h = 0.0;

  // get the vector that maps active order parameters to grain ids
  const auto & op_to_grains = _grain_tracker.getVarToFeatureVector(_current_elem->id());

  // loop over the active OPs
  for (auto op_index = beginIndex(op_to_grains); op_index < op_to_grains.size(); ++op_index)
  {
    if (op_to_grains[op_index] == FeatureFloodCount::invalid_id)
      continue;

    auto grain_id = op_to_grains[op_index];

    // make sure you have enough Euler angles in the file and grab the right one
    if (grain_id < _euler.getGrainNum())
      angles = _euler.getEulerAngles(grain_id);
    else
      mooseError("PolycrystalBurnupEigenstrain has run out of grain rotation data.");

    // Interpolation factor for the eigenstrain tensors - this goes between 0 and 1 if eta is 0 or 1
    // Using standard PF interpolation function.
    Real n = (*_vals[op_index])[_qp];
    Real h = n * n * n * (6 * n * n - 15 * n + 10);

    RankTwoTensor local_eigenstrain;

    // local_eigenstrain = (_eigen_base_tensor + _eigen_rate_tensor * _b[_qp]) * h;

    // modifying this so that it actually captures Gi instead of causing a varying Gi
    // due to engineering strain vs true strain
    // local_eigenstrain = (_eigen_base_tensor +
    // _eigen_rate_tensor*std::exp(_eigen_rate_tensor*_b[_qp]) ) * h;
    std::vector<Real> component(_eigen_base.size());

    for (int i(0); i < component.size(); ++i)
    {
      Real engineering_strain_component = std::exp(_b[_qp] * _eigen_rate[i]) - 1;

      component[i] = (_eigen_base[i] + engineering_strain_component) * h;
    }

    local_eigenstrain.fillFromInputVector(component);

    local_eigenstrain.rotate(RotationTensor(RealVectorValue(angles)));

    _eigenstrain[_qp] += local_eigenstrain;

    sum_h += h;
  }

  // Normalize the tensor to a sum of order parameters = 1...
  // anything divided by near-zero is going to explode
  const Real tol = 1.0e-10;
  sum_h = std::max(sum_h, tol);
  _eigenstrain[_qp] /= sum_h;
}
