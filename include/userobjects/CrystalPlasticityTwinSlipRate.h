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

#pragma once

#include "CrystalPlasticitySlipRateGSS.h"

class CrystalPlasticityTwinSlipRate;

/**
 * Phenomenological constitutive model of slip rate using the userobject class.
 * This class is similar to CrystalPlasticitySlipRateGSS but is designed to
 * work with dislocation density-based rules such that the threshold stress of
 * the slip system is computed from dislocation densities.
 */
class CrystalPlasticityTwinSlipRate : public CrystalPlasticitySlipRateGSS
{
public:
  static InputParameters validParams();

  CrystalPlasticityTwinSlipRate(const InputParameters & parameters);

  virtual bool calcSlipRate(unsigned int qp, Real dt, std::vector<Real> & val) const;
  virtual bool calcSlipRateDerivative(unsigned int qp, Real /*dt*/, std::vector<Real> & val) const;

protected:
  virtual void getFlowRateParams();

  /// holds the slip resistance for each twin system
  const MaterialProperty<std::vector<Real>> & _twin_resistance;
};
