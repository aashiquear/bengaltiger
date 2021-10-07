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

#include "CrystalPlasticitySlipResistance.h"

class CrystalPlasticityDislocSlipResistance;

/**
 * Constitutive model based on forest and substructure dislocations
 * userobject class.
 */
class CrystalPlasticityDislocSlipResistance : public CrystalPlasticitySlipResistance
{
public:
  static InputParameters validParams();

  CrystalPlasticityDislocSlipResistance(const InputParameters & parameters);

  virtual bool calcSlipResistance(unsigned int qp, std::vector<Real> & val) const;

protected:
  virtual void readFileParams();

  /// file name of the text file providing the slip resistance information
  const FileName _disloc_info_filename;

  /// vector holding substructure dislocation density
  const MaterialProperty<std::vector<Real>> & _substruc_disloc_density;

  /// vector holding the forest dislocation density (one for each slip system)
  const MaterialProperty<std::vector<Real>> & _forest_disloc_density;

  /// Holds the friction stress for each slip system
  DenseVector<Real> _friction_stress;

  /**
   * Dislocation interaction parameter for each slip system (often constant) for
   * forest stress, see Knezevic et al. 2012
   */
  DenseVector<Real> _chi;

  /// Burgers vector for each slip system
  DenseVector<Real> _burgers_vector;

  /// Shear modulus for each slip system
  DenseVector<Real> _shear_modulus;

  /**
   * Empirical parameter for each slip system (often constant) for
   * substruccture stress, see Knezevic et al. 2012
   */
  DenseVector<Real> _k_sub;

  /// B thermal modification parameter (see Grilli et al. 2020)
  Real _value_B;

  /// The simulation temperature
  Real _temperature;

  /// The reference temperature for the thermal modification term
  Real _reference_temperature;
};
