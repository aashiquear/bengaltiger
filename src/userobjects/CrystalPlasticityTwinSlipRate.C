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

#include "CrystalPlasticityTwinSlipRate.h"
#include <cmath>

registerMooseObject("bengaltigerApp", CrystalPlasticityTwinSlipRate);

InputParameters
CrystalPlasticityTwinSlipRate::validParams()
{
  InputParameters params = CrystalPlasticitySlipRateGSS::validParams();

  params.addRequiredParam<MaterialPropertyName>("twin_slip_resistance", "name of the twin slip resistance used");
  params.addClassDescription("Phenomenological constitutive model slip rate class "
                             "designed for twinning");
  return params;
}

CrystalPlasticityTwinSlipRate::CrystalPlasticityTwinSlipRate(const InputParameters & parameters)
: CrystalPlasticitySlipRateGSS(parameters),
  _twin_resistance(getMaterialProperty<std::vector<Real>>("twin_slip_resistance"))
{
  // There are some inherited behaviors.
  //_slip_sys_file_name gives the slip system information. That's read in from the base class.
  //_slip_sys_flow_prop_file_name is to get the slip system information.  That's from GSS
  // and it can be in from the input file or another file.  The file is supplied, cannot
  // read from input file.
}

bool
CrystalPlasticityTwinSlipRate::calcSlipRate(unsigned int qp, Real dt, std::vector<Real> & val) const
{
  DenseVector<Real> tau(_variable_size);

  for (unsigned int i = 0; i < _variable_size; ++i)
    tau(i) = _pk2[qp].doubleContraction(_flow_direction[qp][i]);

  for (unsigned int i = 0; i < _variable_size; ++i)
  {
    //check for directionality (tension or compression)
    if ( tau(i) < 0 )
      val[i] = 0;

    else
    {
      val[i] = _a0(i) * std::pow(std::abs(tau(i) / _twin_resistance[qp][i]), 1.0 / _xm(i)) *
              std::copysign(1.0, tau(i));
      if (std::abs(val[i] * dt) > _slip_incr_tol)
        {
          #ifdef DEBUG
          mooseWarning("Maximum allowable slip increment exceeded ", std::abs(val[i]) * dt);
          #endif
          return false;
        }
      }
    }
  return true;
}

bool
CrystalPlasticityTwinSlipRate::calcSlipRateDerivative(unsigned int qp,
                                                     Real /*dt*/,
                                                     std::vector<Real> & val) const
{
  DenseVector<Real> tau(_variable_size);

  for (unsigned int i = 0; i < _variable_size; ++i)
    tau(i) = _pk2[qp].doubleContraction(_flow_direction[qp][i]);

  for (unsigned int i = 0; i < _variable_size; ++i)
  {
    if ( tau(i) < 0 )
      val[i] = 0;
    else
      val[i] = _a0(i) / _xm(i) *
               std::pow(std::abs(tau(i) / _twin_resistance[qp][i]), 1.0 / _xm(i) - 1.0) /
               _twin_resistance[qp][i];
  }
  return true;
}

void
CrystalPlasticityTwinSlipRate::getFlowRateParams()
{
  mooseError("must supply file of twin slip rate parameters and not provide via input file.");
}
