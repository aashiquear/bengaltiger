#include "bengaltigerApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
bengaltigerApp::validParams()
{
  InputParameters params = MooseApp::validParams();
  return params;
}

bengaltigerApp::bengaltigerApp(InputParameters parameters) : MooseApp(parameters)
{
  bengaltigerApp::registerAll(_factory, _action_factory, _syntax);
}

bengaltigerApp::~bengaltigerApp() {}

void
bengaltigerApp::registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ModulesApp::registerAll(f, af, s);
  Registry::registerObjectsTo(f, {"bengaltigerApp"});
  Registry::registerActionsTo(af, {"bengaltigerApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
bengaltigerApp::registerApps()
{
  registerApp(bengaltigerApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
bengaltigerApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  bengaltigerApp::registerAll(f, af, s);
}
extern "C" void
bengaltigerApp__registerApps()
{
  bengaltigerApp::registerApps();
}
