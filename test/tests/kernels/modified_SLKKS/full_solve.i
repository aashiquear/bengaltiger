#
# SLKKS two phase example for the BCC and SIGMA phases. The sigma phase contains
# multiple sublattices. Free energy from
# Jacob, Aurelie, Erwin Povoden-Karadeniz, and Ernst Kozeschnik. "Revised thermodynamic
# description of the Fe-Cr system based on an improved sublattice model of the sigma phase."
# Calphad 60 (2018): 16-28.
#
# In this simulation we consider diffusion (Cahn-Hilliard) and phase transformation.
#

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 1
    nx = 30
    ny = 1
    xmin = -25
    xmax = 25
  []
[]

[AuxVariables]
  [Fglobal]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[Variables]
  # order parameters
  [eta1]
    initial_condition = 0.5
  []
  [eta2]
    initial_condition = 0.5
  []

  # solute concentration
  [cCr]
    order = FIRST
    family = LAGRANGE
    [InitialCondition]
      type = FunctionIC
      function = '(x+25)/50*0.5+0.1'
    []
  []

  # sublattice concentrations (good guesses are needed here! - they can be obtained
  # form a static solve like in sublattice_concentrations.i)
  [BCC_CR]
    [InitialCondition]
      type = FunctionIC
      function = '(x+25)/50*0.5+0.1'
    []
  []
  [SIGMA_0CR]
    [InitialCondition]
      type = FunctionIC
      function = '(x+25)/50*0.17+0.01'
    []
  []
  [SIGMA_1CR]
    [InitialCondition]
      type = FunctionIC
      function = '(x+25)/50*0.36+0.02'
    []
  []
  [SIGMA_2CR]
    [InitialCondition]
      type = FunctionIC
      function = '(x+25)/50*0.33+0.20'
    []
  []

  # Lagrange multiplier
  [lambda]
  []
[]

[Materials]
  # CALPHAD free energies
  [F_BCC_A2]
    type = DerivativeParsedMaterial
    f_name = F_BCC_A2
    outputs = exodus
    output_properties = F_BCC_A2
    function = 'BCC_FE:=1-BCC_CR; G := 8.3145*T*(1.0*if(BCC_CR > 1.0e-15,BCC_CR*log(BCC_CR),0) + '
               '1.0*if(BCC_FE > 1.0e-15,BCC_FE*plog(BCC_FE,eps),0) + 3.0*if(BCC_VA > '
               '1.0e-15,BCC_VA*log(BCC_VA),0))/(BCC_CR + BCC_FE) + 8.3145*T*if(T < '
               '548.2*BCC_CR*BCC_FE*BCC_VA*(BCC_CR - BCC_FE) - 932.5*BCC_CR*BCC_FE*BCC_VA + '
               '311.5*BCC_CR*BCC_VA - '
               '1043.0*BCC_FE*BCC_VA,-8.13674105561218e-49*T^15/(0.525599232981783*BCC_CR*BCC_FE*BCC_'
               'VA*(BCC_CR - BCC_FE) - 0.894055608820709*BCC_CR*BCC_FE*BCC_VA + '
               '0.298657718120805*BCC_CR*BCC_VA - BCC_FE*BCC_VA + 9.58772770853308e-13)^15 - '
               '4.65558036243985e-30*T^9/(0.525599232981783*BCC_CR*BCC_FE*BCC_VA*(BCC_CR - BCC_FE) - '
               '0.894055608820709*BCC_CR*BCC_FE*BCC_VA + 0.298657718120805*BCC_CR*BCC_VA - '
               'BCC_FE*BCC_VA + 9.58772770853308e-13)^9 - '
               '1.3485349181899e-10*T^3/(0.525599232981783*BCC_CR*BCC_FE*BCC_VA*(BCC_CR - BCC_FE) - '
               '0.894055608820709*BCC_CR*BCC_FE*BCC_VA + 0.298657718120805*BCC_CR*BCC_VA - '
               'BCC_FE*BCC_VA + 9.58772770853308e-13)^3 + 1 - '
               '0.905299382744392*(548.2*BCC_CR*BCC_FE*BCC_VA*(BCC_CR - BCC_FE) - '
               '932.5*BCC_CR*BCC_FE*BCC_VA + 311.5*BCC_CR*BCC_VA - 1043.0*BCC_FE*BCC_VA + '
               '1.0e-9)/T,if(T < -548.2*BCC_CR*BCC_FE*BCC_VA*(BCC_CR - BCC_FE) + '
               '932.5*BCC_CR*BCC_FE*BCC_VA - 311.5*BCC_CR*BCC_VA + '
               '1043.0*BCC_FE*BCC_VA,-8.13674105561218e-49*T^15/(-0.525599232981783*BCC_CR*BCC_FE*BCC'
               '_VA*(BCC_CR - BCC_FE) + 0.894055608820709*BCC_CR*BCC_FE*BCC_VA - '
               '0.298657718120805*BCC_CR*BCC_VA + BCC_FE*BCC_VA + 9.58772770853308e-13)^15 - '
               '4.65558036243985e-30*T^9/(-0.525599232981783*BCC_CR*BCC_FE*BCC_VA*(BCC_CR - BCC_FE) '
               '+ 0.894055608820709*BCC_CR*BCC_FE*BCC_VA - 0.298657718120805*BCC_CR*BCC_VA + '
               'BCC_FE*BCC_VA + 9.58772770853308e-13)^9 - '
               '1.3485349181899e-10*T^3/(-0.525599232981783*BCC_CR*BCC_FE*BCC_VA*(BCC_CR - BCC_FE) + '
               '0.894055608820709*BCC_CR*BCC_FE*BCC_VA - 0.298657718120805*BCC_CR*BCC_VA + '
               'BCC_FE*BCC_VA + 9.58772770853308e-13)^3 + 1 - '
               '0.905299382744392*(-548.2*BCC_CR*BCC_FE*BCC_VA*(BCC_CR - BCC_FE) + '
               '932.5*BCC_CR*BCC_FE*BCC_VA - 311.5*BCC_CR*BCC_VA + 1043.0*BCC_FE*BCC_VA + '
               '1.0e-9)/T,if(T > -548.2*BCC_CR*BCC_FE*BCC_VA*(BCC_CR - BCC_FE) + '
               '932.5*BCC_CR*BCC_FE*BCC_VA - 311.5*BCC_CR*BCC_VA + 1043.0*BCC_FE*BCC_VA & '
               '548.2*BCC_CR*BCC_FE*BCC_VA*(BCC_CR - BCC_FE) - 932.5*BCC_CR*BCC_FE*BCC_VA + '
               '311.5*BCC_CR*BCC_VA - 1043.0*BCC_FE*BCC_VA < '
               '0,-79209031311018.7*(-0.525599232981783*BCC_CR*BCC_FE*BCC_VA*(BCC_CR - BCC_FE) + '
               '0.894055608820709*BCC_CR*BCC_FE*BCC_VA - 0.298657718120805*BCC_CR*BCC_VA + '
               'BCC_FE*BCC_VA + 9.58772770853308e-13)^5/T^5 - '
               '3.83095660520737e+42*(-0.525599232981783*BCC_CR*BCC_FE*BCC_VA*(BCC_CR - BCC_FE) + '
               '0.894055608820709*BCC_CR*BCC_FE*BCC_VA - 0.298657718120805*BCC_CR*BCC_VA + '
               'BCC_FE*BCC_VA + 9.58772770853308e-13)^15/T^15 - '
               '1.22565886734485e+72*(-0.525599232981783*BCC_CR*BCC_FE*BCC_VA*(BCC_CR - BCC_FE) + '
               '0.894055608820709*BCC_CR*BCC_FE*BCC_VA - 0.298657718120805*BCC_CR*BCC_VA + '
               'BCC_FE*BCC_VA + 9.58772770853308e-13)^25/T^25,if(T > '
               '548.2*BCC_CR*BCC_FE*BCC_VA*(BCC_CR - BCC_FE) - 932.5*BCC_CR*BCC_FE*BCC_VA + '
               '311.5*BCC_CR*BCC_VA - 1043.0*BCC_FE*BCC_VA & 548.2*BCC_CR*BCC_FE*BCC_VA*(BCC_CR - '
               'BCC_FE) - 932.5*BCC_CR*BCC_FE*BCC_VA + 311.5*BCC_CR*BCC_VA - 1043.0*BCC_FE*BCC_VA > '
               '0,-79209031311018.7*(0.525599232981783*BCC_CR*BCC_FE*BCC_VA*(BCC_CR - BCC_FE) - '
               '0.894055608820709*BCC_CR*BCC_FE*BCC_VA + 0.298657718120805*BCC_CR*BCC_VA - '
               'BCC_FE*BCC_VA + 9.58772770853308e-13)^5/T^5 - '
               '3.83095660520737e+42*(0.525599232981783*BCC_CR*BCC_FE*BCC_VA*(BCC_CR - BCC_FE) - '
               '0.894055608820709*BCC_CR*BCC_FE*BCC_VA + 0.298657718120805*BCC_CR*BCC_VA - '
               'BCC_FE*BCC_VA + 9.58772770853308e-13)^15/T^15 - '
               '1.22565886734485e+72*(0.525599232981783*BCC_CR*BCC_FE*BCC_VA*(BCC_CR - BCC_FE) - '
               '0.894055608820709*BCC_CR*BCC_FE*BCC_VA + 0.298657718120805*BCC_CR*BCC_VA - '
               'BCC_FE*BCC_VA + 9.58772770853308e-13)^25/T^25,0))))*log((2.15*BCC_CR*BCC_FE*BCC_VA - '
               '0.008*BCC_CR*BCC_VA + 2.22*BCC_FE*BCC_VA)*if(2.15*BCC_CR*BCC_FE*BCC_VA - '
               '0.008*BCC_CR*BCC_VA + 2.22*BCC_FE*BCC_VA <= 0,-1.0,1.0) + 1)/(BCC_CR + BCC_FE) + '
               '1.0*(BCC_CR*BCC_VA*if(T >= 298.15 & T < 2180.0,139250.0*1/T - 26.908*T*log(T) + '
               '157.48*T + 0.00189435*T^2.0 - 1.47721e-6*T^3.0 - 8856.94,if(T >= 2180.0 & T < '
               '6000.0,-2.88526e+32*T^(-9.0) - 50.0*T*log(T) + 344.18*T - 34869.344,0)) + '
               'BCC_FE*BCC_VA*if(T >= 298.15 & T < 1811.0,77358.5*1/T - 23.5143*T*log(T) + 124.134*T '
               '- 0.00439752*T^2.0 - 5.89269e-8*T^3.0 + 1225.7,if(T >= 1811.0 & T < '
               '6000.0,2.2960305e+31*T^(-9.0) - 46.0*T*log(T) + 299.31255*T - 25383.581,0)))/(BCC_CR '
               '+ BCC_FE) + 1.0*(BCC_CR*BCC_FE*BCC_VA*(500.0 - 1.5*T)*(BCC_CR - BCC_FE) + '
               'BCC_CR*BCC_FE*BCC_VA*(24600.0 - 14.98*T) + BCC_CR*BCC_FE*BCC_VA*(9.15*T - '
               '14000.0)*(BCC_CR - BCC_FE)^2)/(BCC_CR + BCC_FE); G/100000'
    args = 'BCC_CR'
    constant_names = 'BCC_VA T eps'
    constant_expressions = '1 1000 0.01'
  []

  [F_SIGMA]
    type = DerivativeParsedMaterial
    f_name = F_SIGMA
    outputs = exodus
    output_properties = F_SIGMA
    function = 'SIGMA_0FE := 1-SIGMA_0CR; SIGMA_1FE := 1-SIGMA_1CR; SIGMA_2FE := 1-SIGMA_2CR; G := '
               '8.3145*T*(10.0*if(SIGMA_0CR > 1.0e-15,SIGMA_0CR*plog(SIGMA_0CR,eps),0) + '
               '10.0*if(SIGMA_0FE > 1.0e-15,SIGMA_0FE*plog(SIGMA_0FE,eps),0) + 4.0*if(SIGMA_1CR > '
               '1.0e-15,SIGMA_1CR*plog(SIGMA_1CR,eps),0) + 4.0*if(SIGMA_1FE > '
               '1.0e-15,SIGMA_1FE*plog(SIGMA_1FE,eps),0) + 16.0*if(SIGMA_2CR > '
               '1.0e-15,SIGMA_2CR*plog(SIGMA_2CR,eps),0) + 16.0*if(SIGMA_2FE > '
               '1.0e-15,SIGMA_2FE*plog(SIGMA_2FE,eps),0))/(10.0*SIGMA_0CR + 10.0*SIGMA_0FE + '
               '4.0*SIGMA_1CR + 4.0*SIGMA_1FE + 16.0*SIGMA_2CR + 16.0*SIGMA_2FE) + '
               '(SIGMA_0FE*SIGMA_1CR*SIGMA_2CR*SIGMA_2FE*(-70.0*T - 170400.0) + '
               'SIGMA_0FE*SIGMA_1FE*SIGMA_2CR*SIGMA_2FE*(-10.0*T - 330839.0))/(10.0*SIGMA_0CR + '
               '10.0*SIGMA_0FE + 4.0*SIGMA_1CR + 4.0*SIGMA_1FE + 16.0*SIGMA_2CR + 16.0*SIGMA_2FE) + '
               '(SIGMA_0CR*SIGMA_1CR*SIGMA_2CR*(30.0*if(T >= 298.15 & T < 2180.0,139250.0*1/T - '
               '26.908*T*log(T) + 157.48*T + 0.00189435*T^2.0 - 1.47721e-6*T^3.0 - 8856.94,if(T >= '
               '2180.0 & T < 6000.0,-2.88526e+32*T^(-9.0) - 50.0*T*log(T) + 344.18*T - 34869.344,0)) '
               '+ 132000.0) + SIGMA_0CR*SIGMA_1CR*SIGMA_2FE*(-110.0*T + 16.0*if(T >= 298.15 & T < '
               '1811.0,77358.5*1/T - 23.5143*T*log(T) + 124.134*T - 0.00439752*T^2.0 - '
               '5.89269e-8*T^3.0 + 1225.7,if(T >= 1811.0 & T < 6000.0,2.2960305e+31*T^(-9.0) - '
               '46.0*T*log(T) + 299.31255*T - 25383.581,0)) + 14.0*if(T >= 298.15 & T < '
               '2180.0,139250.0*1/T - 26.908*T*log(T) + 157.48*T + 0.00189435*T^2.0 - '
               '1.47721e-6*T^3.0 - 8856.94,if(T >= 2180.0 & T < 6000.0,-2.88526e+32*T^(-9.0) - '
               '50.0*T*log(T) + 344.18*T - 34869.344,0)) + 123500.0) + '
               'SIGMA_0CR*SIGMA_1FE*SIGMA_2CR*(4.0*if(T >= 298.15 & T < 1811.0,77358.5*1/T - '
               '23.5143*T*log(T) + 124.134*T - 0.00439752*T^2.0 - 5.89269e-8*T^3.0 + 1225.7,if(T >= '
               '1811.0 & T < 6000.0,2.2960305e+31*T^(-9.0) - 46.0*T*log(T) + 299.31255*T - '
               '25383.581,0)) + 26.0*if(T >= 298.15 & T < 2180.0,139250.0*1/T - 26.908*T*log(T) + '
               '157.48*T + 0.00189435*T^2.0 - 1.47721e-6*T^3.0 - 8856.94,if(T >= 2180.0 & T < '
               '6000.0,-2.88526e+32*T^(-9.0) - 50.0*T*log(T) + 344.18*T - 34869.344,0)) + 140486.0) '
               '+ SIGMA_0CR*SIGMA_1FE*SIGMA_2FE*(20.0*if(T >= 298.15 & T < 1811.0,77358.5*1/T - '
               '23.5143*T*log(T) + 124.134*T - 0.00439752*T^2.0 - 5.89269e-8*T^3.0 + 1225.7,if(T >= '
               '1811.0 & T < 6000.0,2.2960305e+31*T^(-9.0) - 46.0*T*log(T) + 299.31255*T - '
               '25383.581,0)) + 10.0*if(T >= 298.15 & T < 2180.0,139250.0*1/T - 26.908*T*log(T) + '
               '157.48*T + 0.00189435*T^2.0 - 1.47721e-6*T^3.0 - 8856.94,if(T >= 2180.0 & T < '
               '6000.0,-2.88526e+32*T^(-9.0) - 50.0*T*log(T) + 344.18*T - 34869.344,0)) + 148800.0) '
               '+ SIGMA_0FE*SIGMA_1CR*SIGMA_2CR*(10.0*if(T >= 298.15 & T < 1811.0,77358.5*1/T - '
               '23.5143*T*log(T) + 124.134*T - 0.00439752*T^2.0 - 5.89269e-8*T^3.0 + 1225.7,if(T >= '
               '1811.0 & T < 6000.0,2.2960305e+31*T^(-9.0) - 46.0*T*log(T) + 299.31255*T - '
               '25383.581,0)) + 20.0*if(T >= 298.15 & T < 2180.0,139250.0*1/T - 26.908*T*log(T) + '
               '157.48*T + 0.00189435*T^2.0 - 1.47721e-6*T^3.0 - 8856.94,if(T >= 2180.0 & T < '
               '6000.0,-2.88526e+32*T^(-9.0) - 50.0*T*log(T) + 344.18*T - 34869.344,0)) + 56200.0) + '
               'SIGMA_0FE*SIGMA_1CR*SIGMA_2FE*(26.0*if(T >= 298.15 & T < 1811.0,77358.5*1/T - '
               '23.5143*T*log(T) + 124.134*T - 0.00439752*T^2.0 - 5.89269e-8*T^3.0 + 1225.7,if(T >= '
               '1811.0 & T < 6000.0,2.2960305e+31*T^(-9.0) - 46.0*T*log(T) + 299.31255*T - '
               '25383.581,0)) + 4.0*if(T >= 298.15 & T < 2180.0,139250.0*1/T - 26.908*T*log(T) + '
               '157.48*T + 0.00189435*T^2.0 - 1.47721e-6*T^3.0 - 8856.94,if(T >= 2180.0 & T < '
               '6000.0,-2.88526e+32*T^(-9.0) - 50.0*T*log(T) + 344.18*T - 34869.344,0)) + 152700.0) '
               '+ SIGMA_0FE*SIGMA_1FE*SIGMA_2CR*(14.0*if(T >= 298.15 & T < 1811.0,77358.5*1/T - '
               '23.5143*T*log(T) + 124.134*T - 0.00439752*T^2.0 - 5.89269e-8*T^3.0 + 1225.7,if(T >= '
               '1811.0 & T < 6000.0,2.2960305e+31*T^(-9.0) - 46.0*T*log(T) + 299.31255*T - '
               '25383.581,0)) + 16.0*if(T >= 298.15 & T < 2180.0,139250.0*1/T - 26.908*T*log(T) + '
               '157.48*T + 0.00189435*T^2.0 - 1.47721e-6*T^3.0 - 8856.94,if(T >= 2180.0 & T < '
               '6000.0,-2.88526e+32*T^(-9.0) - 50.0*T*log(T) + 344.18*T - 34869.344,0)) + 46200.0) + '
               'SIGMA_0FE*SIGMA_1FE*SIGMA_2FE*(30.0*if(T >= 298.15 & T < 1811.0,77358.5*1/T - '
               '23.5143*T*log(T) + 124.134*T - 0.00439752*T^2.0 - 5.89269e-8*T^3.0 + 1225.7,if(T >= '
               '1811.0 & T < 6000.0,2.2960305e+31*T^(-9.0) - 46.0*T*log(T) + 299.31255*T - '
               '25383.581,0)) + 173333.0))/(10.0*SIGMA_0CR + 10.0*SIGMA_0FE + 4.0*SIGMA_1CR + '
               '4.0*SIGMA_1FE + 16.0*SIGMA_2CR + 16.0*SIGMA_2FE); G/100000'
    args = 'SIGMA_0CR SIGMA_1CR SIGMA_2CR'
    constant_names = 'T eps'
    constant_expressions = '1000 0.01'
  []

  # h(eta)
  [h1]
    type = SwitchingFunctionMaterial
    function_name = h1
    h_order = HIGH
    eta = eta1
  []
  [h2]
    type = SwitchingFunctionMaterial
    function_name = h2
    h_order = HIGH
    eta = eta2
  []

  # g(eta)
  [g1]
    type = BarrierFunctionMaterial
    function_name = g1
    g_order = SIMPLE
    eta = eta1
  []
  [g2]
    type = BarrierFunctionMaterial
    function_name = g2
    g_order = SIMPLE
    eta = eta2
  []

  # constant properties
  [constants]
    type = GenericConstantMaterial
    prop_names = 'D   L   kappa'
    prop_values = '10  1   0.1  '
  []

  # Coefficients for diffusion equation
  [Dh1]
    type = DerivativeParsedMaterial
    material_property_names = 'D h1(eta1)'
    function = D*h1
    f_name = Dh1
    args = eta1
    derivative_order = 1
  []
  [Dh2a]
    type = DerivativeParsedMaterial
    material_property_names = 'D h2(eta2)'
    function = D*h2*10/30
    f_name = Dh2a
    args = eta2
    derivative_order = 1
  []
  [Dh2b]
    type = DerivativeParsedMaterial
    material_property_names = 'D h2(eta2)'
    function = D*h2*4/30
    f_name = Dh2b
    args = eta2
    derivative_order = 1
  []
  [Dh2c]
    type = DerivativeParsedMaterial
    material_property_names = 'D h2(eta2)'
    function = D*h2*16/30
    f_name = Dh2c
    args = eta2
    derivative_order = 1
  []
  # omegas
  [omega1]
    type = DerivativeParsedMaterial
    f_name = omega1
    function = '1'
    derivative_order = 1
  []
  [omega2]
    type = DerivativeParsedMaterial
    f_name = omega2
    function = '1'
    derivative_order = 1
  []

  # site fraction
  [ka]
   type = DerivativeParsedMaterial
   f_name = ka
   function = '1'
   derivative_order = 1
  []
  [kb]
   type = DerivativeParsedMaterial
   f_name = kb
   function = '10/30'
   derivative_order = 1
  []
[]

[Kernels]
  #Kernels for diffusion equation
  [diff_time]
    type = TimeDerivative
    variable = cCr
  []
  [diff_c1]
    type = MatDiffusion
    variable = cCr
    diffusivity = Dh1
    v = BCC_CR
    args = eta1
  []
  [diff_c2a]
    type = MatDiffusion
    variable = cCr
    diffusivity = Dh2a
    v = SIGMA_0CR
    args = eta2
  []
  [diff_c2b]
    type = MatDiffusion
    variable = cCr
    diffusivity = Dh2b
    v = SIGMA_1CR
    args = eta2
  []
  [diff_c2c]
    type = MatDiffusion
    variable = cCr
    diffusivity = Dh2c
    v = SIGMA_2CR
    args = eta2
  []

  # enforce pointwise equality of chemical potentials
  [chempot1a2a]
    # The BCC phase has only one sublattice
    # we tie it to the first sublattice with site fraction 10/(10+4+16) in the sigma phase
    type = MKKSPhaseChemicalPotential
    variable = BCC_CR
    cb = SIGMA_0CR
    ka = ka
    kb = kb #'${fparse 10/30}'
    fa_name = F_BCC_A2
    fb_name = F_SIGMA
    args_b = 'SIGMA_1CR SIGMA_2CR'
  []
  [chempot2a2b]
    # This kernel ties the first two sublattices in the sigma phase together
    type = SLKKSChemicalPotential
    variable = SIGMA_0CR
    a = 10
    cs = SIGMA_1CR
    as = 4
    F = F_SIGMA
    args = 'SIGMA_2CR'
  []
  [chempot2b2c]
    # This kernel ties the remaining two sublattices in the sigma phase together
    type = SLKKSChemicalPotential
    variable = SIGMA_1CR
    a = 4
    cs = SIGMA_2CR
    as = 16
    F = F_SIGMA
    args = 'SIGMA_0CR'
  []

  [phaseconcentration]
    # This kernel ties the sum of the sublattice concentrations to the global concentration cCr
    type = MSLKKSMultiPhaseConcentration
    variable = SIGMA_2CR
    c = cCr
    ns = '1      3'
    as = '1      10        4         16'
    cs = 'BCC_CR SIGMA_0CR SIGMA_1CR SIGMA_2CR'
    h_names = 'h1   h2'
    eta = 'eta1 eta2'
    omega_names = 'omega1 omega2'
  []

  # Kernels for Allen-Cahn equation for eta1
  [deta1dt]
    type = TimeDerivative
    variable = eta1
  []
  [ACBulkF1]
    type = KKSMultiACBulkF
    variable = eta1
    Fj_names = 'F_BCC_A2 F_SIGMA'
    hj_names = 'h1    h2'
    gi_name = g1
    eta_i = eta1
    wi = 0.1
    args = 'BCC_CR SIGMA_0CR SIGMA_1CR SIGMA_2CR eta2'
  []
  [ACBulkC1]
    type = MSLKKSMultiACBulkC
    variable = eta1
    F = F_BCC_A2
    c = BCC_CR
    ns = '1      3'
    as = '1      10        4         16'
    cs = 'BCC_CR SIGMA_0CR SIGMA_1CR SIGMA_2CR'
    h_names = 'h1   h2'
    eta = 'eta1 eta2'
    omega_names = 'omega1 omega2'
  []
  [ACInterface1]
    type = ACInterface
    variable = eta1
    kappa_name = kappa
  []
  [lagrange1]
    type = SwitchingFunctionConstraintEta
    variable = eta1
    h_name = h1
    lambda = lambda
    args = 'eta2'
  []

  # Kernels for Allen-Cahn equation for eta1
  [deta2dt]
    type = TimeDerivative
    variable = eta2
  []
  [ACBulkF2]
    type = KKSMultiACBulkF
    variable = eta2
    Fj_names = 'F_BCC_A2 F_SIGMA'
    hj_names = 'h1    h2'
    gi_name = g2
    eta_i = eta2
    wi = 0.1
    args = 'BCC_CR SIGMA_0CR SIGMA_1CR SIGMA_2CR eta1'
  []
  [ACBulkC2]
    type = MSLKKSMultiACBulkC
    variable = eta2
    F = F_BCC_A2
    c = BCC_CR
    ns = '1      3'
    as = '1      10        4         16'
    cs = 'BCC_CR SIGMA_0CR SIGMA_1CR SIGMA_2CR'
    h_names = 'h1   h2'
    eta = 'eta1 eta2'
    omega_names = 'omega1 omega2'
  []
  [ACInterface2]
    type = ACInterface
    variable = eta2
    kappa_name = kappa
  []
  [lagrange2]
    type = SwitchingFunctionConstraintEta
    variable = eta2
    h_name = h2
    lambda = lambda
    args = 'eta1'
  []

  # Lagrange-multiplier constraint kernel for lambda
  [lagrange]
    type = SwitchingFunctionConstraintLagrange
    variable = lambda
    h_names = 'h1   h2'
    etas = 'eta1 eta2'
    epsilon = 1e-6
  []
[]

[AuxKernels]
  [GlobalFreeEnergy]
    type = KKSMultiFreeEnergy
    variable = Fglobal
    Fj_names = 'F_BCC_A2 F_SIGMA'
    hj_names = 'h1 h2'
    gj_names = 'g1 g2'
    interfacial_vars = 'eta1 eta2'
    kappa_names = 'kappa kappa'
    w = 0.1
  []
[]

[Preconditioning]
  [full]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  solve_type = 'PJFNK'
  line_search = none

  petsc_options_iname = '-pc_type -sub_pc_type -sub_pc_factor_shift_type'
  petsc_options_value = 'asm      ilu          nonzero'

  # petsc_options_iname = '-pc_type -sub_pc_type -sub_pc_factor_shift_type -ksp_gmres_restart'
  # petsc_options_value = 'asm      lu          nonzero                    30'

  l_max_its = 100
  nl_max_its = 20
  nl_abs_tol = 1e-10

  end_time = 1000

  [TimeStepper]
    type = IterationAdaptiveDT
    optimal_iterations = 12
    iteration_window = 2
    growth_factor = 2
    cutback_factor = 0.5
    dt = 0.1
  []
[]

[Postprocessors]
  [F]
    type = ElementIntegralVariablePostprocessor
    variable = Fglobal
  []
  [cmin]
    type = NodalExtremeValue
    value_type = min
    variable = cCr
  []
  [cmax]
    type = NodalExtremeValue
    value_type = max
    variable = cCr
  []
[]

[Outputs]
  exodus = true
  print_linear_residuals = false
  # exclude lagrange multiplier from output, it can diff more easily
  hide = lambda
[]
