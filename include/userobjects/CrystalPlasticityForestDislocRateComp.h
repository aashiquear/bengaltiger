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

#include "CrystalPlasticityStateVarRateComponent.h"

class CrystalPlasticityForestDislocRateComp;

/**
 * Phenomenological constitutive model state variable evolution rate component
 * userobject class.
 */
class CrystalPlasticityForestDislocRateComp : public CrystalPlasticityStateVarRateComponent
{
public:
  static InputParameters validParams();

  CrystalPlasticityForestDislocRateComp(const InputParameters & parameters);

  virtual bool calcStateVariableEvolutionRateComponent(unsigned int qp,
                                                       std::vector<Real> & val) const;

protected:
  virtual void readFileParams();

  /// file name of the text file providing the slip resistance information
  const FileName _disloc_info_filename;

  /// vector holding the forest dislocation density (one for each slip system)
  const MaterialProperty<std::vector<Real>> & _forest_disloc_density;

  /// vector holding the slip rate for each slip system
  const MaterialProperty<std::vector<Real>> & _disloc_slip_rate;

  /**
   * Dislocation interaction parameter for each slip system (often constant) for
   * forest stress, see Knezevic et al. 2012
   */
  DenseVector<Real> _chi;

  /// Burgers vector for each slip system
  DenseVector<Real> _burgers_vector;

  /**
   * Dislocation multiplication factor for each slip system (often constant) for
   * forest dislocations, see Grilli et al. 2020
   */
  DenseVector<Real> _k1;

  /// Dislocation annihilation length for each slip system (see Grilli et al. 2020)
  DenseVector<Real> _g;

  /// Drag stress (D) for each slip system (see Grilli et al. 2020)
  DenseVector<Real> _drag_stress;

  /// Boltzmann constant
  Real _kb;

  /// The simulation temperature
  Real _temperature;

  /// Reference strain rate
  Real _strain_rate_ref;

  /// strain rate of the simulation
  Real _strain_rate;
};
