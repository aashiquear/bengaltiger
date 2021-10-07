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

#include "CrystalPlasticityDislocSlipRate.h"
#include <cmath>

registerMooseObject("bengaltigerApp", CrystalPlasticityDislocSlipRate);

InputParameters
CrystalPlasticityDislocSlipRate::validParams()
{
   InputParameters params = CrystalPlasticitySlipRateGSS::validParams();

   params.addRequiredParam<std::string>("disloc_slip_resistance_uo_name", "name of the dislocation slip resistance used");

   params.addClassDescription("Phenomenological constitutive model slip rate class "
                              "designed for slip arising from dislocations");
  return params;
}

CrystalPlasticityDislocSlipRate::CrystalPlasticityDislocSlipRate(const InputParameters & parameters)
: CrystalPlasticitySlipRateGSS(parameters),
  _slip_resistance(getMaterialProperty<std::vector<Real>>(parameters.get<std::string>("disloc_slip_resistance_uo_name")))
{
  // There are some inherited behaviors.
  //_slip_sys_file_name gives the slip system information. That's read in from the base class.
  //_slip_sys_flow_prop_file_name is to get the slip system information.  That's from GSS
  // and it can be in from the input file or another file.  Here, the file is supplied only,
  // cannot be read in from input.
}

bool
CrystalPlasticityDislocSlipRate::calcSlipRate(unsigned int qp, Real dt, std::vector<Real> & val) const
{
  DenseVector<Real> tau(_variable_size);

  for (unsigned int i = 0; i < _variable_size; ++i)
    tau(i) = _pk2[qp].doubleContraction(_flow_direction[qp][i]);

  for (unsigned int i = 0; i < _variable_size; ++i)
  {
    val[i] = _a0(i) * std::pow(std::abs(tau(i) / _slip_resistance[qp][i]), 1.0 / _xm(i)) *
           MathUtils::sign(tau(i));

    if (std::abs(val[i] * dt) > _slip_incr_tol)
    {
#ifdef DEBUG
      mooseWarning("Maximum allowable slip increment exceeded ", std::abs(val[i]) * dt);
#endif
      return false;
    }
  }

  return true;
}


bool
CrystalPlasticityDislocSlipRate::calcSlipRateDerivative(unsigned int qp,
                                                     Real /*dt*/,
                                                     std::vector<Real> & val) const
{
  DenseVector<Real> tau(_variable_size);

  for (unsigned int i = 0; i < _variable_size; ++i)
    tau(i) = _pk2[qp].doubleContraction(_flow_direction[qp][i]);

  for (unsigned int i = 0; i < _variable_size; ++i)
    val[i] = _a0(i) / _xm(i) *
             std::pow(std::abs(tau(i) / _slip_resistance[qp][i]), 1.0 / _xm(i) - 1.0) /
             _slip_resistance[qp][i];

  return true;
}


void
CrystalPlasticityDislocSlipRate::getFlowRateParams()
{
  mooseError("must supply file of slip rate parameters and not provide via input file.");
}
