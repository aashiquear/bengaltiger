# This is an input file for the alpha-uranium tearing. It's taking an initial
# condition generated earlier and using that.
#
# Length unit: microns

[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 104 #39
  ny = 104 #39
  nz = 104 #39
  xmin = 0
  xmax = 62
  ymin = 0
  ymax = 62
  zmin = 0
  zmax = 62
[]

[GlobalParams]
  op_num = 12
  var_name_base = gr
  displacements = 'disp_x disp_y disp_z'
  euler_angle_provider = 'euler_angle_file'
  grain_tracker = 'grain_tracker'
[]

[UserObjects]
  [./euler_angle_file]
    type = EulerAngleFileReader
    file_name = 'mid1.tex'
  [../]
  [./initial_grains]
    type = SolutionUserObject
    mesh = alphaU_diffuseIC_2um_3D_mid1_exodus.e-s022
    timestep = LATEST
  [../]
  [./grain_tracker]
    type = GrainTracker
    threshold = 0.5
    connecting_threshold = 0.08
    execute_on = INITIAL
    compute_halo_maps = false #true
    compute_var_to_feature_map = true
    remap_grains = false
  [../]
  # [./grain_tracker]
  #   type = GrainTrackerElasticity
  #   threshold = 0.5
  #   connecting_threshold = 0.08
  #   compute_var_to_feature_map = true
  #   compute_halo_maps = false
  #   execute_on = 'INITIAL'
  #   remap_grains = false
  #   flood_entity_type = ELEMENTAL
  #
  #   fill_method = symmetric9
  #   # unit is N / micron^2
  #   # C_ijkl = 1111 1122 1133 2222 2233 3333 2323 1313 1212
  #   # C_ijkl = '2.148e-1 0.465e-1 0.218e-1 1.986e-1 1.076e-1 2.671e-1 1.244e-1 0.734e-1 0.743e-1'
  #         # temperature: 298K Reference: 1966 Fisher aUranium Mechanical Properties
  #
  #   # C_ijkl = '1.984e-1 5.37e-2 2.82e-2 1.76e-1 9.87e-2 2.249e-1 9.58e-2 4.26e-2 5.46e-2'
  #         # temperature: 673K Reference: 1966 Fisher aUranium Mechanical Properties
  #
  #   C_ijkl = '2.139e-1 0.476e-1 0.222e-1 1.961e-1 1.070e-1 2.633e-1 1.210e-1 0.695e-1 0.718e-1'
  #         # temperature: 348K Reference: 1966 Fisher aUranium Mechanical Properties
  #
  #   euler_angle_provider = euler_angle_file
  # [../]
[]

[Variables]
  [./c]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[Kernels]
  [./solid_x]
    type = PhaseFieldFractureMechanicsOffDiag
    variable = disp_x
    component = 0
    c = c
  [../]
  [./solid_y]
    type = PhaseFieldFractureMechanicsOffDiag
    variable = disp_y
    component = 1
    c = c
  [../]
  [./solid_z]
    type = PhaseFieldFractureMechanicsOffDiag
    variable = disp_z
    component = 2
    c = c
  [../]
  [./ACBulk]
    type = AllenCahn
    variable = c
    f_name = E_el
  [../]
  [./ACinterface]
    type = ACInterface
    variable = c
    kappa_name = kappa_op
  [../]
[]

[Modules]
  [./TensorMechanics]
    [./Master]
      [./mech]
        add_variables = true
        strain = SMALL
        #NB: it's eigenstrain_names, PLURAL!!!!
        # eigenstrain_names = growth_strain
        eigenstrain_names = thermal_strain
        generate_output = 'stress_xx stress_yy stress_xy stress_zz stress_yz stress_zx
                           vonmises_stress hydrostatic_stress' #strain_xx strain_yy strain_xy
        # planar_formulation = PLANE_STRAIN
        strain_base_name = uncracked
      [../]
    [../]
  [../]
[]

[Functions]
  [./temp_func]
    type = PiecewiseLinear
    x = '0 36000'
    y = '298 673'
  [../]
[]

[Materials]
  [./gc]
    type = ParsedMaterial
    f_name = gc #1e6 MPa-mm
    args = temp
    function = 'if(temp<580, -1.082e-27 * (temp)^3 + 8.570e-11 * (temp)^2 - 1.016e-7 * temp + 3.399e-5,
                             -5.799e-14 * (temp)^3 + 1.758e-10 * (temp)^2 - 1.756e-7 * temp + 5.798e-5)'
  [../]
  [./gc_prop]
    type = ParsedMaterial
    f_name = gc_prop
    args = 'bnds'
    material_property_names = 'gc'
    function = 'if(bnds<0.55, gc, gc * 4) ' #1e6 MPa-mm
  [../]
  [./pfbulkmat]
    type = GenericConstantMaterial
    # prop_names = 'gc_prop l visco '
    # prop_values = '0.0027 0.0075 1e-4 '
    prop_names = 'l visco' #um s/um
    prop_values = '1.2 1e-7'
  [../]
  [./a]
    type = PolycrystalElasticityTensor
    # type = ComputeElasticityTensor
    fill_method = symmetric9
    base_name = a
    # unit is N / micron^2
    # C_ijkl = 1111 1122 1133 2222 2233 3333 2323 1313 1212
    C_ijkl = '-8.366e-8 2.578e-8 3.227e-8 -4.36e-8 1.238e-8 -3.63e-8 -2.448e-8 -8.974e-9 -4.377e-08'

    grain_tracker = 'grain_tracker'
    euler_angle_provider = euler_angle_file
  [../]
  [./b]
    type = PolycrystalElasticityTensor
    fill_method = symmetric9
    base_name = b
    # unit is N / micron^2
    # C_ijkl = 1111 1122 1133 2222 2233 3333 2323 1313 1212
    C_ijkl = '3.783e-5 -5.804e-6 -1.456e-5 -1.814e-5 -3.607e-5 -7.805e-5 -5.195e-5 -7.324e-5 -9.479e-6'

    grain_tracker = 'grain_tracker'
    euler_angle_provider = euler_angle_file
  [../]
  [./c]
    type = PolycrystalElasticityTensor
    fill_method = symmetric9
    base_name = c
    # unit is N / micron^2
    # C_ijkl = 1111 1122 1133 2222 2233 3333 2323 1313 1212
    C_ijkl = '0.2108 0.04622 0.02328 0.2077 0.1178 0.2937 0.1421 0.09617 0.08068'

    grain_tracker = 'grain_tracker'
    euler_angle_provider = euler_angle_file
  [../]
  [./Fa]
    type = DerivativeParsedMaterial
    f_name = Fa
    function = 'temp^2'
    args = temp
  [../]
  [./Fb]
    type = DerivativeParsedMaterial
    f_name = Fb
    function = 'temp'
    args = temp
  [../]
  [./Fc]
    type = DerivativeParsedMaterial
    f_name = Fc
    function = '1'
  [../]
  [./elasticity_tensor]
    type = CompositeElasticityTensor
    args = temp
    tensors = 'a b c'
    weights = 'Fa Fb Fc'
    base_name = uncracked
  [../]
  [./thermal_strain_function]
    type = ThermalExpansionUPoly
    temperature = temp
    stress_free_temperature = 298 #unit: K
    eigenstrain_name = thermal_strain
    # euler_angle_provider = euler_angle_file
    # grain_tracker = grain_tracker
    base_name = uncracked
  [../]
  [./stress]
    type = ComputeLinearElasticStress
    base_name = uncracked
  [../]
  [./cracked_stress]
    type = ComputeCrackedStress
    c = c
    kdamage = 1e-4
    F_name = E_el
    use_current_history_variable = false
    uncracked_base_name = uncracked
  [../]
[]

# Generate these via a new option in PolycrystalVariables
[AuxVariables]
  [./temp]
    initial_condition = 298
  [../]

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
  [./strain_zy]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./strain_xz]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./strain_zz]
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
  [./elastic_strain_zy]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./elastic_strain_xz]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./elastic_strain_zz]
    family = MONOMIAL
    order = CONSTANT
  [../]

  [./uncracked_stress_xx]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./uncracked_stress_yy]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./uncracked_stress_xy]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./uncracked_stress_zy]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./uncracked_stress_xz]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./uncracked_stress_zz]
    family = MONOMIAL
    order = CONSTANT
  [../]

  [./effective_thermal_strain]
    family = MONOMIAL
    order = CONSTANT
  [../]

  [./maxprincipal]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[AuxKernels]
  [./temp]
    type = FunctionAux
    variable = temp
    function = temp_func
  [../]

  [./init_gr0]
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
  [./init_gr10]
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
    base_name = uncracked
  [../]

  [./eigenstrain_11]
    type = RankTwoAux
    variable = eigenstrain11
    rank_two_tensor = uncracked_thermal_strain
    index_i = 0
    index_j = 0
    execute_on = 'initial timestep_end'
  [../]
  [./eigenstrain_22]
    type = RankTwoAux
    variable = eigenstrain22
    rank_two_tensor = uncracked_thermal_strain
    index_i = 1
    index_j = 1
    execute_on = 'initial timestep_end'
  [../]
  [./eigenstrain_12]
    type = RankTwoAux
    variable = eigenstrain12
    rank_two_tensor = uncracked_thermal_strain
    index_i = 0
    index_j = 1
    execute_on = 'initial timestep_end'
  [../]
  [./eigenstrain_33]
    type = RankTwoAux
    variable = eigenstrain33
    rank_two_tensor = uncracked_thermal_strain
    index_i = 2
    index_j = 2
    execute_on = 'initial timestep_end'
  [../]
  [./eigenstrain_13]
    type = RankTwoAux
    variable = eigenstrain13
    rank_two_tensor = uncracked_thermal_strain
    index_i = 0
    index_j = 2
    execute_on = 'initial timestep_end'
  [../]
  [./eigenstrain_23]
    type = RankTwoAux
    variable = eigenstrain23
    rank_two_tensor = uncracked_thermal_strain
    index_i = 1
    index_j = 2
    execute_on = 'initial timestep_end'
  [../]

  [./C1111]
    type = RankFourAux
    variable = C1111
    rank_four_tensor = uncracked_elasticity_tensor
    index_i = 0
    index_j = 0
    index_k = 0
    index_l = 0
    execute_on = 'initial timestep_end'
  [../]
  [./C1122]
    type = RankFourAux
    variable = C1122
    rank_four_tensor = uncracked_elasticity_tensor
    index_i = 0
    index_j = 0
    index_k = 1
    index_l = 1
    execute_on = 'initial timestep_end'
  [../]
  [./C1212]
    type = RankFourAux
    variable = C1212
    rank_four_tensor = uncracked_elasticity_tensor
    index_i = 0
    index_j = 1
    index_k = 0
    index_l = 1
    execute_on = 'initial timestep_end'
  [../]
  [./C3333]
    type = RankFourAux
    variable = C3333
    rank_four_tensor = uncracked_elasticity_tensor
    index_i = 2
    index_j = 2
    index_k = 2
    index_l = 2
    execute_on = 'initial timestep_end'
  [../]
  [./C1133]
    type = RankFourAux
    variable = C1133
    rank_four_tensor = uncracked_elasticity_tensor
    index_i = 0
    index_j = 0
    index_k = 2
    index_l = 2
    execute_on = 'initial timestep_end'
  [../]
  [./C1313]
    type = RankFourAux
    variable = C1313
    rank_four_tensor = uncracked_elasticity_tensor
    index_i = 0
    index_j = 2
    index_k = 0
    index_l = 2
    execute_on = 'initial timestep_end'
  [../]
  [./C2222]
    type = RankFourAux
    variable = C2222
    rank_four_tensor = uncracked_elasticity_tensor
    index_i = 1
    index_j = 1
    index_k = 1
    index_l = 1
    execute_on = 'initial timestep_end'
  [../]
  [./C2233]
    type = RankFourAux
    variable = C2233
    rank_four_tensor = uncracked_elasticity_tensor
    index_i = 1
    index_j = 1
    index_k = 2
    index_l = 2
    execute_on = 'initial timestep_end'
  [../]
  [./C2323]
    type = RankFourAux
    variable = C2323
    rank_four_tensor = uncracked_elasticity_tensor
    index_i = 1
    index_j = 2
    index_k = 1
    index_l = 2
    execute_on = 'initial timestep_end'
  [../]

  [./strain_xx]
    type = RankTwoAux
    variable = strain_xx
    rank_two_tensor = uncracked_mechanical_strain
    index_i = 0
    index_j = 0
  [../]
  [./strain_yy]
    type = RankTwoAux
    variable = strain_yy
    rank_two_tensor = uncracked_mechanical_strain
    index_i = 1
    index_j = 1
  [../]
  [./strain_xy]
    type = RankTwoAux
    variable = strain_xy
    rank_two_tensor = uncracked_mechanical_strain
    index_i = 0
    index_j = 1
  [../]
  [./strain_zy]
    type = RankTwoAux
    variable = strain_zy
    rank_two_tensor = uncracked_mechanical_strain
    index_i = 2
    index_j = 1
  [../]
  [./strain_xz]
    type = RankTwoAux
    variable = strain_xz
    rank_two_tensor = uncracked_mechanical_strain
    index_i = 0
    index_j = 2
  [../]
  [./strain_zz]
    type = RankTwoAux
    variable = strain_zz
    rank_two_tensor = uncracked_mechanical_strain
    index_i = 2
    index_j = 2
  [../]

  [./elastic_strain_xx]
    type = RankTwoAux
    variable = elastic_strain_xx
    rank_two_tensor = uncracked_elastic_strain
    index_i = 0
    index_j = 0
    execute_on = TIMESTEP_END
  [../]
  [./elastic_strain_yy]
    type = RankTwoAux
    variable = elastic_strain_yy
    rank_two_tensor = uncracked_elastic_strain
    index_i = 1
    index_j = 1
    execute_on = TIMESTEP_END
  [../]
  [./elastic_strain_xy]
    type = RankTwoAux
    variable = elastic_strain_xy
    rank_two_tensor = uncracked_elastic_strain
    index_i = 0
    index_j = 1
    execute_on = TIMESTEP_END
  [../]
  [./elastic_strain_zy]
    type = RankTwoAux
    variable = elastic_strain_zy
    rank_two_tensor = uncracked_elastic_strain
    index_i = 2
    index_j = 1
  [../]
  [./elastic_strain_xz]
    type = RankTwoAux
    variable = elastic_strain_xz
    rank_two_tensor = uncracked_elastic_strain
    index_i = 0
    index_j = 2
  [../]
  [./elastic_strain_zz]
    type = RankTwoAux
    variable = elastic_strain_zz
    rank_two_tensor = uncracked_elastic_strain
    index_i = 2
    index_j = 2
  [../]

  [./uncracked_stress_xx]
    type = RankTwoAux
    variable = uncracked_stress_xx
    rank_two_tensor = uncracked_stress
    index_i = 0
    index_j = 0
    execute_on = TIMESTEP_END
  [../]
  [./uncracked_stress_yy]
    type = RankTwoAux
    variable = uncracked_stress_yy
    rank_two_tensor = uncracked_stress
    index_i = 1
    index_j = 1
    execute_on = TIMESTEP_END
  [../]
  [./uncracked_stress_xy]
    type = RankTwoAux
    variable = uncracked_stress_xy
    rank_two_tensor = uncracked_stress
    index_i = 0
    index_j = 1
    execute_on = TIMESTEP_END
  [../]
  [./uncracked_strain_zy]
    type = RankTwoAux
    variable = uncracked_stress_zy
    rank_two_tensor = uncracked_stress
    index_i = 2
    index_j = 1
  [../]
  [./uncracked_strain_xz]
    type = RankTwoAux
    variable = uncracked_stress_xz
    rank_two_tensor = uncracked_stress
    index_i = 0
    index_j = 2
  [../]
  [./uncracked_strain_zz]
    type = RankTwoAux
    variable = uncracked_stress_zz
    rank_two_tensor = uncracked_stress
    index_i = 2
    index_j = 2
  [../]

  [./effective_thermal_strain]
    type = RankTwoScalarAux
    rank_two_tensor = uncracked_thermal_strain
    variable = effective_thermal_strain
    scalar_type = EffectiveStrain
  [../]

  [./maxprincipal]
    type = RankTwoScalarAux
    rank_two_tensor = uncracked_stress
    variable = maxprincipal
    scalar_type = MaxPRiNCIpAl
  [../]
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
  [./pin_disp_z]
    type = DirichletBC
    variable = disp_z
    boundary = 'back'
    value = 0.0
  [../]
[]

[Postprocessors]
  [./DOFs]
    type = NumDOFs
    execute_on = 'initial timestep_end'
    system = NL
  [../]
  [./elastic_energy]
    type = ElementIntegralVariablePostprocessor
    variable = elastic_energy
  [../]
  [./av_elastic_energy]
    type = ElementAverageValue
    variable = elastic_energy
  [../]
  [./physical]
    type = MemoryUsage
    mem_type = physical_memory
    # value_type = total
    # by default MemoryUsage reports the peak value for the current timestep
    # out of all samples that have been taken (at linear and nonlinear iterations)
    execute_on = 'INITIAL TIMESTEP_END NONLINEAR LINEAR'
  [../]
  [./virtual]
    type = MemoryUsage
    mem_type = virtual_memory
    # value_type = total
    execute_on = 'INITIAL TIMESTEP_END'
  [../]
  [./page_faults]
    type = MemoryUsage
    mem_type = page_faults
    # value_type = total
    execute_on = 'INITIAL TIMESTEP_END'
  [../]
  [./av_von_misses]
    type = ElementAverageValue
    variable = vonmises_stress
  [../]
  [./max_von_misses]
    type = ElementExtremeValue
    variable = vonmises_stress
  [../]
  [./av_hydrostatic_stress]
    type = ElementAverageValue
    variable = hydrostatic_stress
  [../]
  [./max_hydrostatic_stress]
    type = ElementExtremeValue
    variable = hydrostatic_stress
  [../]
  [./max_principal_stress]
    type = ElementExtremeValue
    variable = maxprincipal
  [../]
  [./max_stress_xx]
    type = ElementExtremeValue
    variable = stress_xx
  [../]
  [./max_stress_yy]
    type = ElementExtremeValue
    variable = stress_yy
  [../]
  [./max_stress_zz]
    type = ElementExtremeValue
    variable = stress_zz
  [../]
  [./misfit_strain]
    type = ElementAverageValue
    variable = effective_thermal_strain
  [../]
  [./max_misfit_strain]
    type = ElementExtremeValue
    variable = effective_thermal_strain
  [../]
  [./T]
    type = ElementAverageValue
    variable = temp
  [../]
  [./max_T]
    type = ElementExtremeValue
    variable = temp
  [../]
  [./stress_xx]
    type = ElementAverageValue
    variable = stress_xx
  [../]
  [./strain_xx]
    type = ElementAverageValue
    variable = strain_xx
  [../]
  [./stress_yy]
    type = ElementAverageValue
    variable = stress_yy
  [../]
  [./strain_yy]
    type = ElementAverageValue
    variable = strain_yy
  [../]
  [./stress_zz]
    type = ElementAverageValue
    variable = stress_zz
  [../]
  [./strain_zz]
    type = ElementAverageValue
    variable = strain_zz
  [../]

  [./feature_counter]
    type = FeatureFloodCount
    variable = c
    threshold = 0.9
    use_less_than_threshold_comparison = true
    compute_var_to_feature_map = true
    execute_on = 'initial timestep_end'
    compute_halo_maps = true
    flood_entity_type = ELEMENTAL
  [../]
  [./Volume]
    type = VolumePostprocessor
    execute_on = 'initial'
  [../]
  [./c_volume_fraction]
    type = FeatureVolumeFraction
    execute_on = 'initial timestep_end'
    mesh_volume = Volume
    feature_volumes = feature_volumes
    value_type = VOLUME_FRACTION
  [../]
[]

[VectorPostprocessors]
  [./feature_volumes]
    type = FeatureVolumeVectorPostprocessor
    flood_counter = feature_counter
    execute_on = 'initial timestep_end'
  [../]
  [./diagonal_data]
    type = LineValueSampler
    variable = 'temp stress_xx stress_yy stress_zz stress_xy stress_yz stress_zx vonmises_stress hydrostatic_stress'
    sort_by = x
    start_point = '0 0 0'
    end_point = '62 62 62'
    execute_on = 'TIMESTEP_END'
    num_points = 295
  [../]
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
  # petsc_options_iname = '-pc_type -pc_factor_mat_solving_package'
  # petsc_options_value = 'lu       superlu_dist'
  petsc_options_iname = '-pc_type -sub_pc_type -pc_factor_mat_solving_package -pc_asm_overlap'
  petsc_options_value = 'asm      lu           superlu_dist                  1'

  nl_max_its = 15
  l_max_its = 40
  l_tol = 1e-4
  nl_rel_tol = 1e-5
  nl_abs_tol = 1e-6

  start_time = 0
  n_startup_steps = 1
  end_time = 36.0e3

  dtmax = 1e3
  dtmin = 1.0e-8

  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1e-6
    optimal_iterations = 8
    iteration_window = 2
    linear_iteration_ratio = 10
    growth_factor = 1.25
    cutback_factor = .5
  [../]
[]

[Outputs]
  exodus = true
  csv = true
  interval = 1
  perf_graph = true
[]
