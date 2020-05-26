//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "Kernel.h"

// Forward Declarations
class RecombinationRate;
class Function;

template <>
InputParameters validParams<RecombinationRate>();

/**
 * This kernel implements a generic functional
 * body force term:
 * $ - c \cdof f \cdot \phi_i $
 *
 * The coefficient and function both have defaults
 * equal to 1.0.
 */
class RecombinationRate : public Kernel
{
public:
  static InputParameters validParams();

  RecombinationRate(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;

  /// Scale factor
  const Real & _scale;

  /// Material Properties
  const MaterialProperty<Real> & _K1;
  const MaterialProperty<Real> & _K2;

  const MaterialProperty<Real> & _omega;

  const MaterialProperty<Real> & _S;

  /// Coupled Variable
  const unsigned int _v_var;

  const VariableValue & _v;

  /// Optional function value
  const Function & _function;

  /// Optional Postprocessor value
  const PostprocessorValue & _postprocessor;
};
