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

#include "CrystalPlasticityTwinSlipResistance.h"

registerMooseObject("bengaltigerApp", CrystalPlasticityTwinSlipResistance);

InputParameters
CrystalPlasticityTwinSlipResistance::validParams()
{
  InputParameters params = CrystalPlasticitySlipResistance::validParams();

  params.addRequiredParam<MaterialPropertyName>("forest_dislocation_density", "name of the forest dislocation user object");
  params.addRequiredParam<unsigned int>("number_slip_systems", "Number of slip systems (variable_size is for the twin systems)");
  params.addRequiredParam<FileName>("twin_info_filename", "File name for the twin evolution parameters");
  params.addRequiredParam<FileName>("dislocation_info_filename", "File name for the twin evolution parameters");

  params.addClassDescription("Constitutive model for dislocation density-based twin slip "
                             "resistance using forest dislocations");

  return params;
}

CrystalPlasticityTwinSlipResistance::CrystalPlasticityTwinSlipResistance(
  const InputParameters & parameters)
  : CrystalPlasticitySlipResistance(parameters),
    _twin_info_filename(getParam<FileName>("twin_info_filename")),
    _disloc_info_filename(getParam<FileName>("dislocation_info_filename")),
    _num_slip_sys(getParam<unsigned int>("number_slip_systems")),
    _forest_disloc_density(getMaterialProperty<std::vector<Real>>("forest_dislocation_density")),
    _friction_stress(_variable_size),
    _burgers_vector_slip(_num_slip_sys),
    _burgers_vector_twin(_variable_size),
    _shear_modulus(_variable_size),
    _matrix_C_ab(_variable_size, _num_slip_sys)
{
    readFileParams();
}

bool
CrystalPlasticityTwinSlipResistance::calcSlipResistance(unsigned int qp, std::vector<Real> & val) const
{
  //outer loop is for twin systems
  for (unsigned int i = 0; i < _variable_size; ++i)
  {
    Real forest_stress = 0;
    //inner loop is for slip systems
    for (unsigned int j = 0; j < _num_slip_sys; ++j)
        forest_stress += _matrix_C_ab(i,j) * _burgers_vector_slip(j) * _burgers_vector_twin(i) * _forest_disloc_density[qp][j];

    forest_stress *= _shear_modulus(i);

    val[i] = _friction_stress(i) + forest_stress;
  }

  return true;
}

void
CrystalPlasticityTwinSlipResistance::readFileParams()
{
  // Read the data from CSV file
  MooseUtils::DelimitedFileReader reader(_twin_info_filename);
  //data in rows
  reader.setFormatFlag(MooseUtils::DelimitedFileReader::FormatFlag::ROWS);
  reader.read();

  //hard-coded number of columns in the input file for slip system parameters
  //but adding the slip system variable length in for Cab
  unsigned int num_cols = 3 + _num_slip_sys;

  const std::vector<std::vector<double>> & data = reader.getData();
  if (data[0].size() != num_cols)
   mooseError("number of columns incorrect in twin slip resistance data file");

  //start grabbing the data
  for (unsigned int i=0; i < _variable_size; ++i)
  {
    _friction_stress(i) = data[i][0];
    _burgers_vector_twin(i) = data[i][1];
    _shear_modulus(i) = data[i][2];
    //put the info into C_ab
    for (unsigned int j=0; j < _num_slip_sys; ++j)
    {
      _matrix_C_ab(i,j) = data[i][3+j];
    }
  }

  //get the burgers vectors for the slip systems
  MooseUtils::DelimitedFileReader reader2(_disloc_info_filename);
  //data in rows
  reader2.setFormatFlag(MooseUtils::DelimitedFileReader::FormatFlag::ROWS);
  reader2.read();

  //hard-coded number of columns in the input file
  num_cols = 10;

  const std::vector<std::vector<double>> & data2 = reader2.getData();
  if (data2[0].size() > num_cols)
   mooseError("number of columns incorrect in dislocation slip resistance data file");

  for (unsigned int i=0; i < _num_slip_sys; ++i)
  {
    //skip the unnecessary columns
    _burgers_vector_slip(i) = data2[i][2];
    _console<<"burgers_vector_slip("<<i<<") = "<<_burgers_vector_slip(i)<<std::endl;
  }
}
