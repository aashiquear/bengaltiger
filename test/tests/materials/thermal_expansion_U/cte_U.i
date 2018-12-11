# This is an input file for the alpha-uranium tearing. It's taking an initial
# condition generated earlier and using that.
# This file has been parameterized for the system at 400C (673 K)
# Length unit: microns

[Mesh]
  type= GeneratedMesh
  dim = 2
  nx = 39
  ny = 39
  xmin = 0
  xmax = 62
  ymin = 0
  ymax = 62
[]

[GlobalParams]
  op_num = 12
  var_name_base = gr
  displacements = 'disp_x disp_y'
[]

[UserObjects]
  [./euler_angle_file]
    type = EulerAngleFileReader
    file_name = 'mid1.tex'
  [../]
  [./initial_grains]
    type = SolutionUserObject
    mesh = alphaU_diffuseIC_2um_2D_mid1.e-s022
    timestep = LATEST
  [../]
  [./grain_tracker]
    type = GrainTrackerElasticity
    threshold = 0.5
    connecting_threshold = 0.08
    compute_var_to_feature_map = true
    compute_halo_maps = false
    execute_on = 'INITIAL'
    remap_grains = false
    flood_entity_type = ELEMENTAL

    fill_method = symmetric9

    # C_ijkl = 1111 1122 1133 2222 2233 3333 2323 1313 1212   Reference: 1966 Fisher aUranium Mechanical Properties
    # C_ijkl = '2.148e-1 0.465e-1 0.218e-1 1.986e-1 1.076e-1 2.671e-1 1.244e-1 0.734e-1 0.743e-1' # temperature: 298K
    # C_ijkl = '1.984e-1 5.37e-2 2.82e-2 1.76e-1 9.87e-2 2.249e-1 9.58e-2 4.26e-2 5.46e-2'  # temperature: 673K
    C_ijkl = '2.139e-1 0.476e-1 0.222e-1 1.961e-1 1.070e-1 2.633e-1 1.210e-1 0.695e-1 0.718e-1' # temperature: 348K Reference: 1966 Fisher aUranium Mechanical Properties

    euler_angle_provider = euler_angle_file
  [../]
[]

[Variables]
  # [./c]
  #   order = FIRST
  #   family= LAGRANGE
  # [../]
  [./temp]
    initial_condition = 50
  [../]
[]

[Kernels]
  # [./solid_x]
  #   type = PhaseFieldFractureMechanicsOffDiag
  #   variable = disp_x
  #   component = 0
  #   c = c
  # [../]
  # [./solid_y]
  #   type = PhaseFieldFractureMechanicsOffDiag
  #   variable = disp_y
  #   component = 1
  #   c = c
  # [../]
  # [./ACBulk]
  #   type = AllenCahn
  #   variable = c
  #   f_name = E_el
  # [../]
  # [./ACinterface]
  #   type = ACInterface
  #   variable = c
  #   kappa_name = kappa_op
  # [../]
  [./HeatCondTime]
    type = HeatConductionTimeDerivative
    variable = temp
  [../]
  [./HeatCond]
    type = HeatConduction
    variable = temp
  [../]
  [./HeatGen]
    type = HeatSource
    variable = temp
    value = 1  #unit: W/um^2
    function = 't/100'
  [../]
[]

[Modules]
# [./PhaseField]
#   [./Nonconserved]
#     [./c]
#       free_energy = E_el
#       kappa = kappa_op
#       mobility = L
#     [../]
#   [../]
# [../]
  [./TensorMechanics]
    [./Master]
      [./mech]
        add_variables = true
        strain = SMALL
        #NB: it's eigenstrain_names, PLURAL!!!!
        eigenstrain_names = thermal_strain
        generate_output = 'stress_xx stress_yy stress_xy
                           vonmises_stress hydrostatic_stress' #strain_xx strain_yy strain_xy
        planar_formulation = PLANE_STRAIN
        # strain_base_name = uncracked
      [../]
    [../]
  [../]
[]

[Functions]
  # [./top_disp]
  #   type = ParsedFunction
  #   value = '10*t'
  # [../]
  [./temp_func]
    type = ParsedFunction
    value = '343+1e6*t/20'
  [../]
  [./temp_func_top]
    type = ParsedFunction
    value = '353+1e6*t/20'
  [../]
  [./temp_func_K]
    type = PiecewiseLinear
    x = '43     54    100   150   200   250   300   350   400   450   500   550   600   650   700   750   800   850   900   933'
    y = '36.96  32.27 26.29 25.25 25.36 25.91 26.66 27.54 28.5  29.51 30.56 31.64 32.75 33.88 35.03 36.2  37.38 38.57 39.78 40.58'
    scale_factor = '1e-6'
  [../]
  [./temp_func_Cp]
    type = PiecewiseLinear
    x = '30         60         90          200         300        500         600         700         900'
    y = '9.90962422 43.6023466 68.17821468 96.71793246 103.060092 107.8167116 109.0058665 110.5914064 112.9697162'
  [../]
[]

[Materials]
  # [./gc_prop]
  #   type = ParsedMaterial
  #   f_name = gc_prop
  #   args = bnds
  #   function = 'if(bnds<0.55, 0.0013e-3, 0.018e-3) ' #1e6 MPa-mm
  # [../]
  # [./pfbulkmat]
  #   type = GenericConstantMaterial
  #   # prop_names = 'gc_prop l visco '
  #   # prop_values = '0.0027 0.0075 1e-4 '
  #   prop_names = 'l visco' #um s/um
  #   prop_values = '0.6 1e-7'
  # [../]
  # [./elasticity_tensor]
  #   type = ComputeElasticityTensor
  #   C_ijkl = '1.984e-1 1.76e-1'
  #   fill_method = symmetric_isotropic
  #   base_name = uncracked
  # [../]
  [./elasticity_tensor]
    type = ComputePolycrystalElasticityTensor
    op_num = 12
    grain_tracker = grain_tracker
    var_name_base = gr
    # base_name = uncracked
  [../]
  # [./thermal_strain]
  #   type = ComputeAnisotropicThermalExpansionEigenstrain
  #   temperature = temp
  #   # thermal_expansion_coeff = 3.66e-5 #unit: K^-1 at 600K
  #   thermal_expansion_coeff1 = 20.3e-6 #unit: um/um K^-1 at 75C reference 1956 Bridge X-Ray diffraction
  #   thermal_expansion_coeff2 = -1.4e-6
  #   thermal_expansion_coeff3 = 22.2e-6
  #   stress_free_temperature = 273 #unit: K
  #   eigenstrain_name = thermal_strain
  #   euler_angle_provider = euler_angle_file
  #   grain_tracker = grain_tracker
  #   base_name = uncracked
  # [../]
  [./thermal_strain_function]
    type = ThermalExpansionU
    temperature = temp
    stress_free_temperature = 50 #unit: K
    eigenstrain_name = thermal_strain
    euler_angle_provider = euler_angle_file
    grain_tracker = grain_tracker
    # base_name = uncracked
  [../]
  [./heat]
    type = HeatConductionMaterial
    temp = temp
    # thermal_conductivity = '27.5e-6' #unit: W/(um-K)
    thermal_conductivity_temperature_function = 'temp_func_K' #unit: W/(um-K)
    # specific_heat = 110 #unit: J/kg-K at 600K
    # specific_heat = '102' #unit: J/kg-K at 298K
    specific_heat_temperature_function = 'temp_func_Cp' #unit: J/kg-K
  [../]
  [./density]
    type = Density
    density = 19.1e-15 #unit: kg/um^3
  [../]
  # [./isotropic_plasticity]
  #   type = IsotropicPlasticityStressUpdate
  #   yield_stress = 151e-6
  #   hardening_function = hf
  #   base_name = uncracked
  # [../]
  # [./plastic_stress]
  #   type = ComputeMultiPlasticityStress
  #   ep_plastic_tolerance = 1e-9
  #   tangent_operator = elastic
  #   plastic_models = j2
  #   # ignore_failures = true
  #   # inelastic_models = 'isotropic_plasticity'
  #   base_name = uncracked
  # [../]
  [./stress]
    type = ComputeLinearElasticStress
    # base_name = uncracked
  [../]
  # [./cracked_stress]
  #   type = ComputeCrackedStress
  #   c = c
  #   kdamage = 1e-6
  #   F_name = E_el
  #   use_current_history_variable = false
  #   uncracked_base_name = uncracked
  # [../]
[]

# Generate these via a new option in PolycrystalVariables
[AuxVariables]
  [./gr0]
    order = FIRST
    family = LAGRANGE
  [../]
  [./gr1]
    order = FIRST
    family = LAGRANGE
  [../]
  [./gr2]
    order = FIRST
    family = LAGRANGE
  [../]
  [./gr3]
    order = FIRST
    family = LAGRANGE
  [../]
  [./gr4]
    order = FIRST
    family = LAGRANGE
  [../]
  [./gr5]
    order = FIRST
    family = LAGRANGE
  [../]
  [./gr6]
    order = FIRST
    family = LAGRANGE
  [../]
  [./gr7]
    order = FIRST
    family = LAGRANGE
  [../]
  [./gr8]
    order = FIRST
    family = LAGRANGE
  [../]
  [./gr9]
    order = FIRST
    family = LAGRANGE
  [../]
  [./gr10]
    order = FIRST
    family = LAGRANGE
  [../]
  [./gr11]
    order = FIRST
    family = LAGRANGE
  [../]

  [./bnds]
    order = FIRST
    family = LAGRANGE
  [../]

  [./elastic_energy]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./eigenstrain11]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./eigenstrain22]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./eigenstrain12]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./eigenstrain33]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./eigenstrain13]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./eigenstrain23]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./C1111]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./C1122]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./C1212]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./C2222]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./C3333]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./C1313]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./C2323]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./C1133]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./C2233]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./strain_xx]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./strain_yy]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./strain_xy]
    family = MONOMIAL
    order = CONSTANT
  [../]

  [./elastic_strain_xx]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./elastic_strain_yy]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./elastic_strain_xy]
    family = MONOMIAL
    order = CONSTANT
  [../]

  # [./uncracked_stress_xx]
  #   family = MONOMIAL
  #   order = CONSTANT
  # [../]
  # [./uncracked_stress_yy]
  #   family = MONOMIAL
  #   order = CONSTANT
  # [../]
  # [./uncracked_stress_xy]
  #   family = MONOMIAL
  #   order = CONSTANT
  # [../]
[]

[AuxKernels]
  [./init_grO]
    type = SolutionAux
    execute_on = INITIAL
    variable = gr0
    solution = initial_grains
    from_variable = gr0
  [../]
  [./init_gr1]
    type = SolutionAux
    execute_on = INITIAL
    variable = gr1
    solution = initial_grains
    from_variable = gr1
  [../]
  [./init_gr2]
    type = SolutionAux
    execute_on = INITIAL
    variable = gr2
    solution = initial_grains
    from_variable = gr2
  [../]
  [./init_gr3]
    type = SolutionAux
    execute_on = INITIAL
    variable = gr3
    solution = initial_grains
    from_variable = gr3
  [../]
  [./init_gr4]
    type = SolutionAux
    execute_on = INITIAL
    variable = gr4
    solution = initial_grains
    from_variable = gr4
  [../]
  [./init_gr5]
    type = SolutionAux
    execute_on = INITIAL
    variable = gr5
    solution = initial_grains
    from_variable = gr5
  [../]
  [./init_gr6]
    type = SolutionAux
    execute_on = INITIAL
    variable = gr6
    solution = initial_grains
    from_variable = gr6
  [../]
  [./init_gr7]
    type = SolutionAux
    execute_on = INITIAL
    variable = gr7
    solution = initial_grains
    from_variable = gr7
  [../]
  [./init_gr8]
    type = SolutionAux
    execute_on = INITIAL
    variable = gr8
    solution = initial_grains
    from_variable = gr8
  [../]
  [./init_gr9]
    type = SolutionAux
    execute_on = INITIAL
    variable = gr9
    solution = initial_grains
    from_variable = gr9
  [../]
  [./in1t_gr10]
    type = SolutionAux
    execute_on = INITIAL
    variable = gr10
    solution = initial_grains
    from_variable = gr10
  [../]
  [./init_gr11]
    type = SolutionAux
    execute_on = INITIAL
    variable = gr11
    solution = initial_grains
    from_variable = gr11
  [../]

  [./bnds_aux]
    # AuxKernel that calculates the GB term
    type = BndsCalcAux
    variable = bnds
    execute_on = timestep_end
  [../]

  [./elastic_energy]
    type = ElasticEnergyAux
    variable = elastic_energy
    # base_name = uncracked
  [../]

  [./eigenstrain_11]
    type = RankTwoAux
    variable = eigenstrain11
    # rank_two_tensor = uncracked_thermal_strain
    rank_two_tensor = thermal_strain
    index_i = 0
    index_j = 0
    execute_on = 'initial timestep_end'
  [../]
  [./eigenstrain_22]
    type = RankTwoAux
    variable = eigenstrain22
    # rank_two_tensor = uncracked_thermal_strain
    rank_two_tensor = thermal_strain
    index_i = 1
    index_j = 1
    execute_on = 'initial timestep_end'
  [../]
  [./eigenstrain_12]
    type = RankTwoAux
    variable = eigenstrain12
    # rank_two_tensor = uncracked_thermal_strain
    rank_two_tensor = thermal_strain
    index_i = 0
    index_j = 1
    execute_on = 'initial timestep_end'
  [../]
  [./eigenstrain_33]
    type = RankTwoAux
    variable = eigenstrain33
    # rank_two_tensor = uncracked_thermal_strain
    rank_two_tensor = thermal_strain
    index_i = 2
    index_j = 2
    execute_on = 'initial timestep_end'
  [../]
  [./eigenstrain_13]
    type = RankTwoAux
    variable = eigenstrain13
    # rank_two_tensor = uncracked_thermal_strain
    rank_two_tensor = thermal_strain
    index_i = 0
    index_j = 2
    execute_on = 'initial timestep_end'
  [../]
  [./eigenstrain_23]
    type = RankTwoAux
    variable = eigenstrain23
    # rank_two_tensor = uncracked_thermal_strain
    rank_two_tensor = thermal_strain
    index_i = 1
    index_j = 2
    execute_on = 'initial timestep_end'
  [../]

  [./C1111]
    type = RankFourAux
    variable = C1111
    # rank_four_tensor = uncracked_elasticity_tensor
    rank_four_tensor = elasticity_tensor
    index_i = 0
    index_j = 0
    index_k = 0
    index_l = 0
    execute_on= 'initial timestep_end'
  [../]
  [./C1122]
    type = RankFourAux
    variable = C1122
    # rank_four_tensor = uncracked_elasticity_tensor
    rank_four_tensor = elasticity_tensor
    index_i = 0
    index_j = 0
    index_k = 1
    index_l = 1
    execute_on = 'initial timestep_end'
  [../]
  [./C1212]
    type = RankFourAux
    variable = C1212
    # rank_four_tensor = uncracked_elasticity_tensor
    rank_four_tensor = elasticity_tensor
    index_i = 0
    index_j = 1
    index_k = 0
    index_l = 1
    execute_on = 'initial timestep_end'
  [../]
  [./C3333]
    type = RankFourAux
    variable = C3333
    # rank_four_tensor = uncracked_elasticity_tensor
    rank_four_tensor = elasticity_tensor
    index_i = 2
    index_j = 2
    index_k = 2
    index_l = 2
    execute_on = 'initial timestep_end'
  [../]
  [./C1133]
    type = RankFourAux
    variable = C1133
    # rank_four_tensor = uncracked_elasticity_tensor
    rank_four_tensor = elasticity_tensor
    index_i = 0
    index_j = 0
    index_k = 2
    index_l = 2
    execute_on = 'initial timestep_end'
  [../]
  [./C1313]
    type = RankFourAux
    variable = C1313
    # rank_four_tensor = uncracked_elasticity_tensor
    rank_four_tensor = elasticity_tensor
    index_i = 0
    index_j = 2
    index_k = 0
    index_l = 2
    execute_on = 'initial timestep_end'
  [../]
  [./C2222]
    type = RankFourAux
    variable = C2222
    # rank_four_tensor = uncracked_elasticity_tensor
    rank_four_tensor = elasticity_tensor
    index_i = 1
    index_j = 1
    index_k = 1
    index_l = 1
    execute_on = 'initial timestep_end'
  [../]
  [./C2233]
    type = RankFourAux
    variable = C2233
    # rank_four_tensor = uncracked_elasticity_tensor
    rank_four_tensor = elasticity_tensor
    index_i = 1
    index_j = 1
    index_k = 2
    index_l = 2
    execute_on = 'initial timestep_end'
  [../]
  [./C2323]
    type = RankFourAux
    variable = C2323
    # rank_four_tensor = uncracked_elasticity_tensor
    rank_four_tensor = elasticity_tensor
    index_i = 1
    index_j = 2
    index_k = 1
    index_l = 2
    execute_on = 'initial timestep_end'
  [../]

  [./strain_xx]
    type = RankTwoAux
    variable = strain_xx
    # rank_two_tensor = uncracked_mechanical_strain
    rank_two_tensor = mechanical_strain
    index_i = 0
    index_j = 0
  [../]
  [./strain_yy]
    type = RankTwoAux
    variable = strain_yy
    # rank_two_tensor = uncracked_mechanical_strain
    rank_two_tensor = mechanical_strain
    index_i = 1
    index_j = 1
  [../]
  [./strain_xy]
    type = RankTwoAux
    variable = strain_xy
    # rank_two_tensor = uncracked_mechanical_strain
    rank_two_tensor = mechanical_strain
    index_i = 0
    index_j = 1
  [../]

  [./elastic_strain_xx]
    type = RankTwoAux
    variable = elastic_strain_xx
    # rank_two_tensor = uncracked_elastic_strain
    rank_two_tensor = elastic_strain
    index_i = 0
    index_j = 0
    execute_on = TIMESTEP_END
  [../]
  [./elastic_strain_yy]
    type = RankTwoAux
    variable = elastic_strain_yy
    # rank_two_tensor = uncracked_elastic_strain
    rank_two_tensor = elastic_strain
    index_i = 1
    index_j = 1
    execute_on = TIMESTEP_END
  [../]
  [./elastic_strain_xy]
    type = RankTwoAux
    variable = elastic_strain_xy
    # rank_two_tensor = uncracked_elastic_strain
    rank_two_tensor = elastic_strain
    index_i = 0
    index_j = 1
    execute_on = TIMESTEP_END
  [../]

  # [./uncracked_stress_xx]
  #   type = RankTwoAux
  #   variable = uncracked_stress_xx
  #   rank_two_tensor = uncracked_stress
  #   index_i = 0
  #   index_j = 0
  #   execute_on = TIMESTEP_END
  # [../]
  # [./uncracked_stress_yy]
  #   type = RankTwoAux
  #   variable = uncracked_stress_yy
  #   rank_two_tensor = uncracked_stress
  #   index_i = 1
  #   index_j = 1
  #   execute_on = TIMESTEP_END
  # [../]
  # [./uncracked_stress_xy]
  #   type = RankTwoAux
  #   variable = uncracked_stress_xy
  #   rank_two_tensor = uncracked_stress
  #   index_i = 0
  #   index_j = 1
  #   execute_on = TIMESTEP_END
  # [../]
[]

[BCs]
  # You can use PresetBC or Dirichlet BC, they give the same result, they are just implemented
  # differently (Dirichlet imposed DURING solve, Preset imposed first, one may be better than
  # the other depending on the problem
  [./pin_disp_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'left'
    value = 0.0
  [../]
  [./pin_disp_y]
    type = DirichletBC
    variable = disp_y
    boundary = 'bottom'
    value = 0.0
  [../]
  # [disp_top]
  #   type = FunctionDirichletBC
  #   variable = disp_y
  #   boundary = 'top'
  #   function = 'top_disp'
  # [../]
  # [./temp_left]
  #   type = DirichletBC
  #   variable = temp
  #   value = 310
  #   boundary = 'left'
  # [../]
  # [./temp_right]
  #   type = FunctionDirichletBC
  #   variable = temp
  #   function = 'temp_func'
  #   boundary = 'right'
  # [../]
  [./flux_boundary]
    type = NeumannBC
    variable = temp
    boundary = 'left right top bottom'
    value = 0
  [../]
  # [./temp_bottom]
  #   type = DirichletBC
  #   variable = temp
  #   value = 298
  #   boundary = 'bottom'
  # [../]
  # [./temp_top]
  #   type = DirichletBC
  #   variable = temp
  #   value = 273
  #   boundary = 'top'
  # [../]
  # [./temp_top]
  #   type = FunctionDirichletBC
  #   variable = temp
  #   function = 'temp_func_top'
  #   boundary = 'top'
  # [../]
  # [./pin_disp_zl
  #   type = DirichletBC
  #   variable = disp_z
  #   boundary = 'back'
  #   value = 0.0
  # [../]
[]

[Postprocessors]
  # [./DOFs]
  #   type = NumDOFs
  #   execute_on = 'initial timestep_end'
  #   system = NL
  # [../]
  # [./elastic_energy]
  #   type = ElementIntegralVariablePostprocessor
  #   variable = elastic_energy
  # [../]
  # [./av_elastic_energy]
  #   type = ElementAverageValue
  #   variable = elastic_energy
  # [../]
  # [./physical]
  #   type = MemoryUsage
  #   mem_type = physical_memory
  #   # value_type = total
  #   # by default MemoryUsage reports the peak value for the current timestep
  #   # out of all samples that have been taken (at linear and nonlinear iterations)
  #   execute_on = 'INITIAL TIMESTEP_END NONLINEAR LINEAR'
  # [../]
  # [./virtual]
  #   type = MemoryUsage
  #   mem_type = virtual_memory
  #   # value_type = total
  #   execute_on = 'INITIAL TIMESTEP_END'
  # [../]
  # [./page_faults]
  #   type = MemoryUsage
  #   mem_type = page_faults
  #   # value_type = total
  #   execute_on = 'INITIAL TIMESTEP_END'
  # [../]
  # [./stress_xx]
  #   type = ElementAverageValue
  #   variable = stress_xx
  # [../]
  # [./strain_xx]
  #   type = ElementAverageValue
  #   variable = strain_xx
  # [../]
  # [./av_von_misses]
  #   type = ElementAverageValue
  #   variable = vonmises_stress
  # [../]
  # [./disp_y_top]
  #   type = SideAverageValue
  #   variable = disp_y
  #   boundary = top
  # [../]
  # [./av_stress_yy]
  #   type = SideAverageValue
  #   variable = stress_yy
  #   boundary = top
  # [../]
  # [./av_strain_yy]
  #   type = SideAverageValue
  #   variable = strain_yy
  #   boundary = top
  # [../]
  # [./stress_yy]
  #   type = ElementAverageValue
  #   variable = stress_yy
  # [../]
  # [./strain_yy]
  #   type = ElementAverageValue
  #   variable = strain_yy
  # [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  scheme = 'BDF2'
  solve_type = NEWTON
  # petsc_options_iname = '-pc_type -sub_pc_type -ksp_gmres_restart pc_hypre_boomeramg_strong_threshold'
  # petsc_opt10ns_value = 'hypre    boomeramg    201                0.9'
  # solve_type = PJFNK
  petsc_options_iname = '-pc_type -pc_factor_mat_solving_package'
  petsc_options_value = 'lu       superlu_dist'
  # petsc_options_iname = '-pc_type -sub_pc_type -pc_factor_mat_solving_package -pc_asm_overlap'
  # petsc_options_value = 'asm      lu           superlu_dist                  1'

  nl_max_its = 15
  l_max_its = 40
  l_tol = 1e-4
  nl_rel_tol = 1e-5
  nl_abs_tol = 1e-6
  [./TimeStepper]
    type = ConstantDT
    dt = 1e-6
  [../]

  num_steps = 10
[]

[Outputs]
  exodus = true
[]
