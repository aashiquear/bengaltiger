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

#ifndef POLYCRYSTALELASTICITYTENSOR_H
#define POLYCRYSTALELASTICITYTENSOR_H

#include "ComputeElasticityTensorBase.h"

class PolycrystalElasticityTensor;
class EulerAngleProvider;

template <>
InputParameters validParams<PolycrystalElasticityTensor>();

/**
 * Compute spatially dependent elasticity tensor of a polycrystalline material.
 * In this case, each grain is denoted via an auxiliary variable that is equal to 1
 * in the grain and 0 everywhere else.  This is simpler than
 * ComputePolycrystalElasticityTensor because that actually links up to the grain
 * tracker.  This class is only intended to be used for static order parameters
 * designated by auxvariables, not evolving nonlinear variables.
 */

class PolycrystalElasticityTensor : public ComputeElasticityTensorBase
{
public:
  PolycrystalElasticityTensor(const InputParameters & parameters);

protected:
  virtual void computeQpElasticityTensor();

private:
  /// unrotated elasticity tensor
  RankFourTensor _C_ijkl;

  /// object providing the Euler angles
  const EulerAngleProvider & _euler;

  /// Number of order parameters
  const unsigned int _op_num;

  /// Order parameters
  std::vector<const VariableValue *> _vals;

  /// Grain tracker used to get unique grain IDs
  const GrainTrackerInterface & _grain_tracker;
};

#endif // POLYCRYSTALELASTICITYTENSOR_H
