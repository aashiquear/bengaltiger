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

class CrystalPlasticityTwinSlipResistance;

/**
 * Constitutive model based on forest and substructure dislocations
 * userobject class.
 */
class CrystalPlasticityTwinSlipResistance : public CrystalPlasticitySlipResistance
{
public:
  static InputParameters validParams();

  CrystalPlasticityTwinSlipResistance(const InputParameters & parameters);

  virtual bool calcSlipResistance(unsigned int qp, std::vector<Real> & val) const;

protected:
  virtual void readFileParams();

  /// file name for the text file containing twin slip resistance information
  const FileName _twin_info_filename;

  /// file name for the text file containing the slip resistance information
  const FileName _disloc_info_filename;

  /// number of slip systems
  unsigned int _num_slip_sys;

  /// holds the forest dislocation density for each slip system
  const MaterialProperty<std::vector<Real>> & _forest_disloc_density;

  /// friction stress for each slip system
  DenseVector<Real> _friction_stress;

  /// burgers vector for each slip system
  DenseVector<Real> _burgers_vector_slip;

  /// burgers vector for each twin system
  DenseVector<Real> _burgers_vector_twin;

  /// shear modulus
  DenseVector<Real> _shear_modulus;

  /// coupling coefficient matrix for twin hardening
  DenseMatrix<Real> _matrix_C_ab;
};
