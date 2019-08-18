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

#ifndef POLYCRYSTALBURNUPEIGENSTRAIN4_H
#define POLYCRYSTALBURNUPEIGENSTRAIN4_H

#include "ComputeEigenstrainBase.h"
#include "RankTwoTensor.h"

class PolycrystalBurnupEigenstrain4;
class EulerAngleProvider;
class GrainTrackerInterface;

template <>
InputParameters validParams<PolycrystalBurnupEigenstrain4>();

/**
 * Compute spatially and temporally dependent eigenstrain tensor of a
 * polycrystalline material.  In this case, each grain is denoted by an
 * auxiliary variable that is equal to 1 in the grain and 0 everywhere else.
 * Also, none of the derivatives are specified.  This class is only intended
 * for use with static order parameters designated by auxvariables, not
 * evolving nonlinear variables.
 */

class PolycrystalBurnupEigenstrain4 : public ComputeEigenstrainBase
{
public:
  PolycrystalBurnupEigenstrain4(const InputParameters & parameters);

protected:
  virtual void computeQpEigenstrain();

private:
  /// unrotated eigenstrain base tensor
  RankTwoTensor _eigen_base_tensor;

  /// unrotated eigenstrain change rate tensor
  RankTwoTensor _eigen_rate_tensor;

  /// object providing the Euler angles
  const EulerAngleProvider & _euler;

  /// Number of order parameters
  const unsigned int _op_num;

  /// Order parameters
  std::vector<const VariableValue *> _vals;

  /// Eigen base vector
  std::vector<Real> _eigen_base;

  /// Eigen rate vector
  std::vector<Real> _eigen_rate;

  /// Burnup
  const VariableValue & _b;

  /// Grain tracker used to get unique grain IDs
  const GrainTrackerInterface & _grain_tracker;
};

#endif // POLYCRYSTALBURNUPEIGENSTRAIN4_H
