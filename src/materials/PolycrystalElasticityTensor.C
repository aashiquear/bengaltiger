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

#include "PolycrystalElasticityTensor.h"
#include "EulerAngleProvider.h"
#include "RotationTensor.h"

registerMooseObject("bengaltigerApp", PolycrystalElasticityTensor);

template <>
InputParameters
validParams<PolycrystalElasticityTensor>()
{
  InputParameters params = validParams<ComputeElasticityTensorBase>();
  params.addClassDescription(
      "Compute spatially dependent elasticity tensor coupled to auxiliary variables");
  params.addRequiredCoupledVarWithAutoBuild(
      "v", "var_name_base", "op_num", "Array of coupled variables");
  params.addRequiredParam<UserObjectName>("euler_angle_provider",
                                          "Name of Euler angle provider user object");
  params.addRequiredParam<std::vector<Real>>("C_ijkl", "Unrotated stiffness tensor");
  params.addParam<MooseEnum>(
      "fill_method", RankFourTensor::fillMethodEnum() = "symmetric9", "The fill method");
  params.addRequiredParam<UserObjectName>("grain_tracker",
                                          "the GrainTracker UserObject to get values from");

  return params;
}

PolycrystalElasticityTensor::PolycrystalElasticityTensor(const InputParameters & parameters)
  : ComputeElasticityTensorBase(parameters),
    _C_ijkl(getParam<std::vector<Real>>("C_ijkl"),
            getParam<MooseEnum>("fill_method").getEnum<RankFourTensor::FillMethod>()),
    _euler(getUserObject<EulerAngleProvider>("euler_angle_provider")),
    _op_num(coupledComponents("v")),
    _vals(_op_num),
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
PolycrystalElasticityTensor::computeQpElasticityTensor()
{
  _elasticity_tensor[_qp].zero();

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
      mooseError("PolycrystalElasticityTensor has run out of grain rotation data.");

    // Interpolation factor for the eigenstrain tensors - this goes between 0 and 1 if eta is 0 or 1
    // Using standard PF interpolation function.
    Real n = (*_vals[op_index])[_qp];
    Real h = n * n * n * (6 * n * n - 15 * n + 10);

    // rotate the tensor for each grain orientation
    RankFourTensor C_ijkl = _C_ijkl;
    C_ijkl.rotate(RotationTensor(RealVectorValue(angles)));

    _elasticity_tensor[_qp] += C_ijkl * h;

    sum_h += h;
  }

  // Normalize the tensor to a sum of order parameters = 1
  const Real tol = 1.0e-10;
  sum_h = std::max(sum_h, tol);
  _elasticity_tensor[_qp] /= sum_h;
}
