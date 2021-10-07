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

#include "CrystalPlasticitySubstrucDislocRateComp.h"

registerMooseObject("bengaltigerApp", CrystalPlasticitySubstrucDislocRateComp);

InputParameters
CrystalPlasticitySubstrucDislocRateComp::validParams()
{
  InputParameters params = CrystalPlasticityStateVarRateComponent::validParams();

  params.addRequiredParam<FileName>("dislocation_info_filename", "File name for the dislocation evolution parameters");
  params.addRequiredParam<MaterialPropertyName>("forest_dislocation_density", "name of the forest dislocation user object");
  params.addRequiredParam<MaterialPropertyName>("substruc_dislocation_density", "name of the substructure dislocation user object");
  params.addRequiredParam<MaterialPropertyName>("dislocation_slip_rate", "name of the dislocation slip rate user object");
  // variable_size = 1 for the substructure dislocation array
  params.addParam<Real>("boltzmann_constant", 1.38064852e-23, "Boltzmann constant (default in J/K)");
  params.addParam<Real>("temperature", 300, "constant temperature value in Kelvin");
  params.addParam<Real>("strain_rate_reference", 1e-7, "reference strain rate");
  params.addParam<Real>("strain_rate", 1e-5, "constant applied strain rate");

  params.addClassDescription("Constitutive model for substructure dislocation evolution");

  return params;
}

CrystalPlasticitySubstrucDislocRateComp::CrystalPlasticitySubstrucDislocRateComp(
  const InputParameters & parameters)
  : CrystalPlasticityStateVarRateComponent(parameters),
  _disloc_info_filename(getParam<FileName>("dislocation_info_filename")),
  _substruc_disloc_density(getMaterialProperty<std::vector<Real>>("substruc_dislocation_density")),
  _forest_disloc_density(getMaterialProperty<std::vector<Real>>("forest_dislocation_density")),
  _disloc_slip_rate(getMaterialProperty<std::vector<Real>>("dislocation_slip_rate")),
  _chi(_variable_size),
  _burgers_vector(_variable_size),
  _k1(_variable_size),
  _g(_variable_size),
  _drag_stress(_variable_size),
  _f(_variable_size),
  _q(_variable_size),
  _kb(getParam<Real>("boltzmann_constant")),
  _temperature(getParam<Real>("temperature")),
  _strain_rate_ref(getParam<Real>("strain_rate_reference")),
  _strain_rate(getParam<Real>("strain_rate"))
{
  readFileParams();
}

void
CrystalPlasticitySubstrucDislocRateComp::readFileParams()
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
      _chi(i) = data[i][1];
      _burgers_vector(i) = data[i][2];
      //skipping other stuff that's read elsewhere
      _k1(i) = data[i][5];
      _g(i) = data[i][6];
      _drag_stress(i) = data[i][7];
      _f(i) = data[i][8];
      _q(i) = data[i][9];
    }
}

bool
CrystalPlasticitySubstrucDislocRateComp::calcStateVariableEvolutionRateComponent(
    unsigned int qp, std::vector<Real> & val) const
{
  if (_disloc_slip_rate[qp].size() != _forest_disloc_density[qp].size())
    mooseError("dislocation slip rate size not equal to forest dislocation density size");

  //hardcoding in that the substructure density is a vector of size 1
  if (_substruc_disloc_density[qp].size() != 1)
    mooseError("substructure dislocation density must only have one component");

  // change in density with slip * slip rate to give change in density with TIME.
  //d_rho_sub/d_gamma_1 * d_gamma1/dt + d_rho_sub/d_gamma_2 * d_gamma_2/dt + ...
  Real sum(0);
  //do the summation over the slip systems
  for (unsigned int i = 0; i < _disloc_slip_rate[qp].size(); ++i)
  {
    //from Grilli
    //making naming consistent with Grilli's paper
    Real dhat0 = _g(i);
    Real dhat = dhat0 * (1 + (_kb * _temperature / _drag_stress(i) / Utility::pow<3>(_burgers_vector(i))) * std::log(_strain_rate_ref / _strain_rate));

    Real forest_recovery_rate =  dhat * _forest_disloc_density[qp][i];

    Real comp = _f(i) * _burgers_vector(i) * std::sqrt(_substruc_disloc_density[qp][0]);
    comp *= std::abs(_disloc_slip_rate[qp][i]) * forest_recovery_rate;

    sum += _q(i) * comp;
  }

  val[0] = sum;

  return true;
}
