# This is an input file for the alpha-uranium tearing. It's taking an initial
# condition generated earlier and using that.
#
# Length unit: microns

[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 10 #39
  ny = 10 #39
  nz = 10 #39
  xmin = 0
  xmax = 100
  ymin = 0
  ymax = 100
  zmin = 0
  zmax = 100
[]

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Variables]

[]

[Kernels]

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
      [../]
    [../]
  [../]
[]

[Functions]
  [./temp_func]
    type = PiecewiseLinear
    x = '0   600'
    y = '300 900'
  [../]
[]

[Materials]
  [./a]
    type = ComputeElasticityTensor
    fill_method = symmetric9
    base_name = a
    # unit is N / micron^2
    # C_ijkl = 1111 1122 1133 2222 2233 3333 2323 1313 1212
    C_ijkl = '-8.366e-8 2.578e-8 3.227e-8 -4.36e-8 1.238e-8 -3.63e-8 -2.448e-8 -8.974e-9 -4.377e-08'
  [../]
  [./b]
    type = ComputeElasticityTensor
    fill_method = symmetric9
    base_name = b
    # unit is N / micron^2
    # C_ijkl = 1111 1122 1133 2222 2233 3333 2323 1313 1212
    C_ijkl = '3.783e-5 -5.804e-6 -1.456e-5 -1.814e-5 -3.607e-5 -7.805e-5 -5.195e-5 -7.324e-5 -9.479e-6'
  [../]
  [./c]
    type = ComputeElasticityTensor
    fill_method = symmetric9
    base_name = c
    # unit is N / micron^2
    # C_ijkl = 1111 1122 1133 2222 2233 3333 2323 1313 1212
    C_ijkl = '0.2108 0.04622 0.02328 0.2077 0.1178 0.2937 0.1421 0.09617 0.08068'
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
  [../]
  [./thermal_strain_function]
    type = CTEUSingleCrystal
    temperature = temp
    stress_free_temperature = 300 #unit: K
    eigenstrain_name = thermal_strain
  [../]
  [./stress]
    type = ComputeLinearElasticStress
  [../]
[]

[AuxVariables]
  [./temp]
    initial_condition = 300
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

  [./elastic_energy]
    type = ElasticEnergyAux
    variable = elastic_energy
  [../]

  [./eigenstrain_11]
    type = RankTwoAux
    variable = eigenstrain11
    rank_two_tensor = thermal_strain
    index_i = 0
    index_j = 0
    execute_on = 'initial timestep_end'
  [../]
  [./eigenstrain_22]
    type = RankTwoAux
    variable = eigenstrain22
    rank_two_tensor = thermal_strain
    index_i = 1
    index_j = 1
    execute_on = 'initial timestep_end'
  [../]
  [./eigenstrain_12]
    type = RankTwoAux
    variable = eigenstrain12
    rank_two_tensor = thermal_strain
    index_i = 0
    index_j = 1
    execute_on = 'initial timestep_end'
  [../]
  [./eigenstrain_33]
    type = RankTwoAux
    variable = eigenstrain33
    rank_two_tensor = thermal_strain
    index_i = 2
    index_j = 2
    execute_on = 'initial timestep_end'
  [../]
  [./eigenstrain_13]
    type = RankTwoAux
    variable = eigenstrain13
    rank_two_tensor = thermal_strain
    index_i = 0
    index_j = 2
    execute_on = 'initial timestep_end'
  [../]
  [./eigenstrain_23]
    type = RankTwoAux
    variable = eigenstrain23
    rank_two_tensor = thermal_strain
    index_i = 1
    index_j = 2
    execute_on = 'initial timestep_end'
  [../]

  [./C1111]
    type = RankFourAux
    variable = C1111
    rank_four_tensor = elasticity_tensor
    index_i = 0
    index_j = 0
    index_k = 0
    index_l = 0
    execute_on = 'initial timestep_end'
  [../]
  [./C1122]
    type = RankFourAux
    variable = C1122
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
    rank_two_tensor = mechanical_strain
    index_i = 0
    index_j = 0
  [../]
  [./strain_yy]
    type = RankTwoAux
    variable = strain_yy
    rank_two_tensor = mechanical_strain
    index_i = 1
    index_j = 1
  [../]
  [./strain_xy]
    type = RankTwoAux
    variable = strain_xy
    rank_two_tensor = mechanical_strain
    index_i = 0
    index_j = 1
  [../]
  [./strain_zy]
    type = RankTwoAux
    variable = strain_zy
    rank_two_tensor = mechanical_strain
    index_i = 2
    index_j = 1
  [../]
  [./strain_xz]
    type = RankTwoAux
    variable = strain_xz
    rank_two_tensor = mechanical_strain
    index_i = 0
    index_j = 2
  [../]
  [./strain_zz]
    type = RankTwoAux
    variable = strain_zz
    rank_two_tensor = mechanical_strain
    index_i = 2
    index_j = 2
  [../]

  [./elastic_strain_xx]
    type = RankTwoAux
    variable = elastic_strain_xx
    rank_two_tensor = elastic_strain
    index_i = 0
    index_j = 0
    execute_on = TIMESTEP_END
  [../]
  [./elastic_strain_yy]
    type = RankTwoAux
    variable = elastic_strain_yy
    rank_two_tensor = elastic_strain
    index_i = 1
    index_j = 1
    execute_on = TIMESTEP_END
  [../]
  [./elastic_strain_xy]
    type = RankTwoAux
    variable = elastic_strain_xy
    rank_two_tensor = elastic_strain
    index_i = 0
    index_j = 1
    execute_on = TIMESTEP_END
  [../]
  [./elastic_strain_zy]
    type = RankTwoAux
    variable = elastic_strain_zy
    rank_two_tensor = elastic_strain
    index_i = 2
    index_j = 1
  [../]
  [./elastic_strain_xz]
    type = RankTwoAux
    variable = elastic_strain_xz
    rank_two_tensor = elastic_strain
    index_i = 0
    index_j = 2
  [../]
  [./elastic_strain_zz]
    type = RankTwoAux
    variable = elastic_strain_zz
    rank_two_tensor = elastic_strain
    index_i = 2
    index_j = 2
  [../]

  [./effective_thermal_strain]
    type = RankTwoScalarAux
    rank_two_tensor = thermal_strain
    variable = effective_thermal_strain
    scalar_type = EffectiveStrain
  [../]

  [./maxprincipal]
    type = RankTwoScalarAux
    rank_two_tensor = stress
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

  start_time = 0
  n_startup_steps = 1
  end_time = 600

  dt = 50
[]

[Outputs]
  exodus = true
[]
