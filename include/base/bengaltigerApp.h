//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#ifndef BENGALTIGERAPP_H
#define BENGALTIGERAPP_H

#include "MooseApp.h"

class bengaltigerApp;

template <>
InputParameters validParams<bengaltigerApp>();

class bengaltigerApp : public MooseApp
{
public:
  bengaltigerApp(InputParameters parameters);
  virtual ~bengaltigerApp();

  static void registerApps();
  static void registerAll(Factory & f, ActionFactory & af, Syntax & s);
};

#endif /* BENGALTIGERAPP_H */
