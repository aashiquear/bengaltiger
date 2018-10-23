//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#ifndef BENGALTIGERTESTAPP_H
#define BENGALTIGERTESTAPP_H

#include "MooseApp.h"

class bengaltigerTestApp;

template <>
InputParameters validParams<bengaltigerTestApp>();

class bengaltigerTestApp : public MooseApp
{
public:
  bengaltigerTestApp(InputParameters parameters);
  virtual ~bengaltigerTestApp();

  static void registerApps();
  static void registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs = false);
};

#endif /* BENGALTIGERTESTAPP_H */
