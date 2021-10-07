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

#include "CrystalPlasticityDislocSlipResistance.h"
#include "DelimitedFileReader.h"

registerMooseObject("bengaltigerApp", CrystalPlasticityDislocSlipResistance);

InputParameters
CrystalPlasticityDislocSlipResistance::validParams()
{
  InputParameters params = CrystalPlasticitySlipResistance::validParams();

  params.addRequiredParam<MaterialPropertyName>("forest_dislocation_density", "name of the forest dislocation user object");
  params.addRequiredParam<MaterialPropertyName>("substruc_dislocation_density", "name of the substructure dislocation user object");
  params.addRequiredParam<FileName>("dislocation_info_filename", "File name for the dislocation evolution parameters");
  params.addParam<Real>("temperature", 300, "temperature in Kelvin");
  params.addRequiredParam<Real>("reference_temperature", "reference temperature in Kelvin");
  params.addRequiredParam<Real>("B", "thermal activation parameter for slip");

  params.addClassDescription("Constitutive model for dislocation density-based slip "
                             "resistance using forest and substructure dislocations");

  return params;
}

CrystalPlasticityDislocSlipResistance::CrystalPlasticityDislocSlipResistance(const InputParameters & parameters)
  : CrystalPlasticitySlipResistance(parameters),
  _disloc_info_filename(getParam<FileName>("dislocation_info_filename")),
  _substruc_disloc_density(getMaterialProperty<std::vector<Real>>("substruc_dislocation_density")),
  _forest_disloc_density(getMaterialProperty<std::vector<Real>>("forest_dislocation_density")),
  _friction_stress(_variable_size),
  _chi(_variable_size),
  _burgers_vector(_variable_size),
  _shear_modulus(_variable_size),
  _k_sub(_variable_size),
  _value_B(getParam<Real>("B")),
  _temperature(getParam<Real>("temperature")),
  _reference_temperature(getParam<Real>("reference_temperature"))
{
  readFileParams();
}

bool
CrystalPlasticityDislocSlipResistance::calcSlipResistance(unsigned int qp, std::vector<Real> & val) const
{
  //hardcoding in that the substructure density is a vector of size 1
  if (_substruc_disloc_density[qp].size() != 1)
    mooseError("substructure dislocation density has more than one component");

  for (unsigned int i = 0; i < _variable_size; ++i)
  {
    Real forest_stress = _chi(i) * _burgers_vector(i) * _shear_modulus(i);
    forest_stress *= std::sqrt(_forest_disloc_density[qp][i]);

    Real substructure_stress = _k_sub(i) * _burgers_vector(i) * _shear_modulus(i);
    substructure_stress *= std::sqrt(_substruc_disloc_density[qp][0]);
    substructure_stress *= std::log10(1.0/(_burgers_vector(i)*std::sqrt(_substruc_disloc_density[qp][0])));

    val[i] = _friction_stress(i) + forest_stress + substructure_stress;

    //adding Grilli thermal modification
    val[i] *= std::exp(-(_temperature - _reference_temperature)/_value_B);
  }

  return true;
}

void
CrystalPlasticityDislocSlipResistance::readFileParams()
{
  // Read the data from CSV file
  MooseUtils::DelimitedFileReader reader(_disloc_info_filename);
  //data in rows
  reader.setFormatFlag(MooseUtils::DelimitedFileReader::FormatFlag::ROWS);
  reader.read();

  //hard-coded number of columns in the input file
  unsigned int num_cols = 10;

  const std::vector<std::vector<double>> & data = reader.getData();
  if (data[0].size() != num_cols)
   mooseError("number of columns incorrect in dislocation slip rate data file");

  //start grabbing the data
  for (unsigned int i=0; i < _variable_size; ++i)
  {
    //skip the first two columns as they are for the human only
    _friction_stress(i) = data[i][0];
    _chi(i) = data[i][1];
    _burgers_vector(i) = data[i][2];
    _shear_modulus(i) = data[i][3];
    _k_sub(i) = data[i][4];
    //skipping other stuff that's read elsewhere
  }
}
