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

#include "CrystalPlasticityForestDislocRateComp.h"

registerMooseObject("bengaltigerApp", CrystalPlasticityForestDislocRateComp);

InputParameters
CrystalPlasticityForestDislocRateComp::validParams()
{
  InputParameters params = CrystalPlasticityStateVarRateComponent::validParams();

  params.addParam<Real>("strain_rate", 1e-5, "external strain rate applied");
  params.addParam<Real>("strain_rate_reference", 1e-7, "reference external strain rate");
  params.addParam<Real>("boltzmann_constant", 1.38064852e-23, "Boltzmann constant in your units of choice (default is J/K)");
  params.addParam<Real>("temperature", 300, "temperature (constant)");
  params.addRequiredParam<MaterialPropertyName>("forest_dislocation_density", "name of the forest dislocation user object");
  params.addRequiredParam<MaterialPropertyName>("dislocation_slip_rate", "name of the dislocation slip rate user object");
  params.addRequiredParam<FileName>("dislocation_info_filename", "File name for the dislocation evolution parameters");

  params.addClassDescription("Constitutive model for forest dislocation evolution (specifically for alpha-uranium)");

  return params;
}

CrystalPlasticityForestDislocRateComp::CrystalPlasticityForestDislocRateComp(
  const InputParameters & parameters)
  : CrystalPlasticityStateVarRateComponent(parameters),
  _disloc_info_filename(getParam<FileName>("dislocation_info_filename")),
  _forest_disloc_density(getMaterialProperty<std::vector<Real>>("forest_dislocation_density")),
  _disloc_slip_rate(getMaterialProperty<std::vector<Real>>("dislocation_slip_rate")),
  _chi(_variable_size),
  _burgers_vector(_variable_size),
  _k1(_variable_size),
  _g(_variable_size),
  _drag_stress(_variable_size),
  _kb(getParam<Real>("boltzmann_constant")),
  _temperature(getParam<Real>("temperature")),
  _strain_rate_ref(getParam<Real>("strain_rate_reference")),
  _strain_rate(getParam<Real>("strain_rate"))
{
  readFileParams();
}

bool
CrystalPlasticityForestDislocRateComp::calcStateVariableEvolutionRateComponent(
    unsigned int qp, std::vector<Real> & val) const
{
  // change in density with slip * slip rate to give change in density with TIME.

  for (unsigned int i = 0; i < _variable_size; ++i)
  {
    //from Grilli
    Real generation = std::sqrt(_forest_disloc_density[qp][i]);

    //Grilli calls it dhat0, so we'll call it that here.
    Real dhat0 = _g(i);

    Real dhat = dhat0 * (1 + (_kb * _temperature / _drag_stress(i) / Utility::pow<3>(_burgers_vector(i))) * std::log(_strain_rate_ref / _strain_rate));
    Real recovery = dhat * _forest_disloc_density[qp][i];

    val[i] = std::abs(_disloc_slip_rate[qp][i]) * _k1(i) * (generation - recovery);
  }

  return true;
}

void
CrystalPlasticityForestDislocRateComp::readFileParams()
{
  // Read the data from CSV file
  MooseUtils::DelimitedFileReader reader(_disloc_info_filename);
  //data in rows
  reader.setFormatFlag(MooseUtils::DelimitedFileReader::FormatFlag::ROWS);
  reader.read();

  //start grabbing the data
  //hard-coded number of columns in the input file
  unsigned int num_cols = 10;

  const std::vector<std::vector<double>> & data = reader.getData();
  if (data[0].size() != num_cols)
   mooseError("number of columns incorrect in dislocation slip rate data file");

  for (unsigned int i=0; i < _variable_size; ++i)
  {
      _chi(i) = data[i][1];
      _burgers_vector(i) = data[i][2];
      //skipping other stuff that's read elsewhere
      _k1(i) = data[i][5];
      _g(i) = data[i][6];
      _drag_stress(i) = data[i][7];
    }
}
