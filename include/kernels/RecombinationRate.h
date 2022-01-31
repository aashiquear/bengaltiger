//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "ADKernelValue.h"

class Function;

// declareADValidParams(RecombinationRate);

// template <ComputeStage compute_stage>
class RecombinationRate : public ADKernelValue
{
public:
  static InputParameters validParams();

  RecombinationRate(const InputParameters & parameters);

protected:
  virtual ADReal precomputeQpResidual() override;

  /// Scale factor
  const Real & _scale;

  /// Material Properties
  const MaterialProperty<Real> & _K;

  const MaterialProperty<Real> & _omega;

  /// Coupled Variable
  const unsigned int _v_var;

  const VariableValue & _v;

  /// Optional function value
  const Function & _function;

  /// Optional Postprocessor value
  const PostprocessorValue & _postprocessor;

  // usingKernelValueMembers;
  // using KernelBase::_q_point;
};
