# This file is to build up a crystal plasticity model for alpha-U.
# units are seconds, microns, nanojoules

[Mesh]
  type = GeneratedMesh
  nx = 1
  ny = 1
  nz = 1
  xmin = 0
  xmax = 100
  ymin = 0
  ymax = 100
  zmin = 0
  zmax = 100
  dim = 3
  elem_type = HEX8
[]

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  temperature = 300
[]

[Modules/TensorMechanics/Master]
  [./all]
    strain = FINITE
    add_variables = true
    volumetric_locking_correction = false
  [../]
[]

[Materials]
  [./crystal_plasticity]
    type = FiniteStrainUObasedCP
    block = 0
    stol = 1e-7
    rtol = 1e-7
    abs_tol = 1e-7
    tan_mod_type = none
    zero_tol = 1.0e-13
    maximum_substep_iteration = 5
    maxiter = 100
    maxiter_state_variable = 100
    use_line_search = false
    uo_slip_rates = 'slip_rate twin_rate'
    uo_slip_resistances = 'slip_resistance twin_resistance'
    uo_state_vars = 'forest_disloc_density substruc_disloc_density'
    uo_state_var_evol_rate_comps = 'forest_disloc_rate_comp substruc_disloc_rate_comp'
  [../]
  [./elasticity_tensor]
    type = ComputeElasticityTensorCP
    block = 0
    #units in nJ/um^3 1111 1122 1133 2222 2233 3333 2323 3131 1212
    C_ijkl = '215 46.5 21.8 199 108 267 124 75.4 74.3'
    fill_method = symmetric9
    read_prop_user_object = prop_read
  [../]
[]

[UserObjects]
  [./prop_read]
    type = ElementPropertyReadFile
    prop_file_name = 'euler_angles.txt'
    #NB: euler angles must be supplied in degrees and internally converted to radians.
    #Random grain orientation.
    nprop = 3
    read_type = element
  [../]
  [./slip_rate]
    type = CrystalPlasticityDislocSlipRate
    variable_size = 8 #eight slip systems
    slip_sys_file_name = 'alphaU_slip_sys.txt'
    slip_sys_flow_prop_file_name = 'DislocSlipRate.txt'
    disloc_slip_resistance_uo_name = 'slip_resistance'
    uo_state_var_name = forest_disloc_density
  [../]
  [./twin_rate]
    type = CrystalPlasticityTwinSlipRate
    variable_size = 6 #six twin systems
    slip_sys_file_name = 'alpha_U_twin_sys.txt'
    slip_sys_flow_prop_file_name = 'TwinSlipRate.txt'
    twin_slip_resistance = 'twin_resistance'
    uo_state_var_name = forest_disloc_density
  [../]
  [./slip_resistance]
    type = CrystalPlasticityDislocSlipResistance
    #needs to know forest and substructure dislocations
    forest_dislocation_density = 'forest_disloc_density'
    substruc_dislocation_density = 'substruc_disloc_density'
    dislocation_info_filename = 'DislocSlipResistance.txt'
    variable_size = 8
    #temperature = 300
    reference_temperature = 293
    B = 350
  [../]
  [./twin_resistance]
    type = CrystalPlasticityTwinSlipResistance
    variable_size = 6 #six twin systems
    number_slip_systems = 8 #eight slip systems
    dislocation_info_filename = 'DislocSlipResistance.txt'
    twin_info_filename = 'TwinSlipResistance.txt'
    forest_dislocation_density = 'forest_disloc_density'
  [../]
  [./forest_disloc_density]
    type = CrystalPlasticityStateVariable
    variable_size = 8 #8 slip systems

    groups = '0 1 2 4 8' #0 is wall, 1 is floor, 2-3 is chimney, 4-8 is roof slip
    group_values = '0.01 0.01 0.01 0.01' # initial dislocation density in 1/microns^2
    uo_state_var_evol_rate_comp_name = 'forest_disloc_rate_comp'
    scale_factor = 1.0
  [../]
  [./substruc_disloc_density]
    type = CrystalPlasticityStateVariable
    variable_size = 1 #one substructure dislocation density
    groups = '0 1'
    group_values = '0.01' #initial substructure dislocation density in 1/microns^2
    uo_state_var_evol_rate_comp_name = 'substruc_disloc_rate_comp'
    scale_factor = 1.0
  [../]
  [./forest_disloc_rate_comp]
    type = CrystalPlasticityForestDislocRateComp
    variable_size = 8 #eight slip systems, each has a forest dislocation density
    strain_rate = 1e-3
    strain_rate_reference = 1e7
    boltzmann_constant = 1.38e-14 # nJ/K
    #temperature = 300
    dislocation_slip_rate = 'slip_rate'
    forest_dislocation_density = 'forest_disloc_density'
    dislocation_info_filename = 'DislocSlipResistance.txt'
  [../]
  [./substruc_disloc_rate_comp]
    type = CrystalPlasticitySubstrucDislocRateComp
    variable_size = 8
    forest_dislocation_density = 'forest_disloc_density'
    substruc_dislocation_density = 'substruc_disloc_density'
#    #d_rho/d_gamma * d_gamma_dt
    dislocation_slip_rate = 'slip_rate'
    boltzmann_constant = 1.38e-14 # nJ/K
    #temperature = 300
    strain_rate_reference = 1e7
    strain_rate = 1e-3
    dislocation_info_filename = 'DislocSlipResistance.txt'
  [../]
[]

[Preconditioning]
  [./smp]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient

  solve_type = 'PJFNK'

  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -ksp_gmres_restart -snes_ksp_ew_rtol0 -snes_ksp_ew_rtolmax -snes_ksp_ew_gamma -snes_ksp_ew_alpha -snes_ksp_ew_alpha2 -snes_ksp_ew_threshold'
  petsc_options_value = 'lu superlu_dist 51 0.5 0.9 1 2 2 0.1'
  petsc_options = '-snes_converged_reason'

  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-8

  l_max_its = 10
  nl_max_its = 10

  dtmin = 1e-14
  num_steps = 10

   [./TimeStepper]
     type = ConstantDT
     dt = 1
  [../]
[]

[BCs]
  [./fix_y]
    type = DirichletBC
    variable = disp_y
    boundary = bottom
    value = 0
    preset = true
  [../]
  [./fix_x]
    type = DirichletBC
    variable = disp_x
    boundary = left
    value = 0
    preset = true
  [../]
  [./fix_z]
    type = DirichletBC
    variable = disp_z
    boundary = back
    value = 0
    preset = true
  [../]
  [./pull]
    type = FunctionDirichletBC
    variable = disp_z
    boundary = front
    function = '0.001*t'
    preset = true
  [../]
[]

[Outputs]
  csv = false
  file_base = front_dispZ
  [./exo]
    type = Exodus
    interval = 1
  [../]
[]

[AuxVariables]
  [./substruc_disloc_density]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./forest_disloc_density_1]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./forest_disloc_density_2]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./forest_disloc_density_3]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./forest_disloc_density_4]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./forest_disloc_density_5]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./forest_disloc_density_6]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./forest_disloc_density_7]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./forest_disloc_density_8]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./substruc_disloc_rate]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./forest_disloc_rate_1]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./forest_disloc_rate_2]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./forest_disloc_rate_3]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./forest_disloc_rate_4]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./forest_disloc_rate_5]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./forest_disloc_rate_6]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./forest_disloc_rate_7]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./forest_disloc_rate_8]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./slip_rate_1]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./slip_rate_2]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./slip_rate_3]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./slip_rate_4]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./slip_rate_5]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./slip_rate_6]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./slip_rate_7]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./slip_rate_8]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./twin_rate_1]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./twin_rate_2]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./twin_rate_3]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./twin_rate_4]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./twin_rate_5]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./twin_rate_6]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./slip_resistance_1]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./slip_resistance_2]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./slip_resistance_3]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./slip_resistance_4]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./slip_resistance_5]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./slip_resistance_6]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./slip_resistance_7]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./slip_resistance_8]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./twin_resistance_1]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./twin_resistance_2]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./twin_resistance_3]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./twin_resistance_4]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./twin_resistance_5]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./twin_resistance_6]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[AuxKernels]
 [./substruc_disloc_density]
   type = MaterialStdVectorAux
   variable = substruc_disloc_density
   property = substruc_disloc_density
   index = 0
   execute_on = timestep_end
  [../]
  [./forest_disloc_density1]
    type = MaterialStdVectorAux
    variable = forest_disloc_density_1
    property = forest_disloc_density
    index = 0
    execute_on = timestep_end
  [../]
  [./forest_disloc_density2]
    type = MaterialStdVectorAux
    variable = forest_disloc_density_2
    property = forest_disloc_density
    index = 1
    execute_on = timestep_end
  [../]
  [./forest_disloc_density3]
    type = MaterialStdVectorAux
    variable = forest_disloc_density_3
    property = forest_disloc_density
    index = 2
    execute_on = timestep_end
  [../]
  [./forest_disloc_density4]
    type = MaterialStdVectorAux
    variable = forest_disloc_density_4
    property = forest_disloc_density
    index = 3
    execute_on = timestep_end
  [../]
  [./forest_disloc_density5]
    type = MaterialStdVectorAux
    variable = forest_disloc_density_5
    property = forest_disloc_density
    index = 4
    execute_on = timestep_end
  [../]
  [./forest_disloc_density6]
    type = MaterialStdVectorAux
    variable = forest_disloc_density_6
    property = forest_disloc_density
    index = 5
    execute_on = timestep_end
  [../]
  [./forest_disloc_density7]
    type = MaterialStdVectorAux
    variable = forest_disloc_density_7
    property = forest_disloc_density
    index = 6
    execute_on = timestep_end
  [../]
  [./forest_disloc_density8]
    type = MaterialStdVectorAux
    variable = forest_disloc_density_8
    property = forest_disloc_density
    index = 7
    execute_on = timestep_end
  [../]
  [./substruc_disloc_rate]
    type = MaterialStdVectorAux
    variable = substruc_disloc_rate
    property = substruc_disloc_rate_comp
    index = 0
    execute_on = timestep_end
   [../]
   [./forest_disloc_rate_1]
     type = MaterialStdVectorAux
     variable = forest_disloc_rate_1
     property = forest_disloc_rate_comp
     index = 0
     execute_on = timestep_end
   [../]
   [./forest_disloc_rate_2]
     type = MaterialStdVectorAux
     variable = forest_disloc_rate_2
     property = forest_disloc_rate_comp
     index = 1
     execute_on = timestep_end
   [../]
   [./forest_disloc_rate_3]
     type = MaterialStdVectorAux
     variable = forest_disloc_rate_3
     property = forest_disloc_rate_comp
     index = 2
     execute_on = timestep_end
   [../]
   [./forest_disloc_rate_4]
     type = MaterialStdVectorAux
     variable = forest_disloc_rate_4
     property = forest_disloc_rate_comp
     index = 3
     execute_on = timestep_end
   [../]
   [./forest_disloc_rate_5]
     type = MaterialStdVectorAux
     variable = forest_disloc_rate_5
     property = forest_disloc_rate_comp
     index = 4
     execute_on = timestep_end
   [../]
   [./forest_disloc_rate_6]
     type = MaterialStdVectorAux
     variable = forest_disloc_rate_6
     property = forest_disloc_rate_comp
     index = 5
     execute_on = timestep_end
   [../]
   [./forest_disloc_rate_7]
     type = MaterialStdVectorAux
     variable = forest_disloc_rate_7
     property = forest_disloc_rate_comp
     index = 6
     execute_on = timestep_end
   [../]
   [./forest_disloc_rate_8]
     type = MaterialStdVectorAux
     variable = forest_disloc_rate_8
     property = forest_disloc_rate_comp
     index = 7
     execute_on = timestep_end
   [../]
   [./slip_rate_1]
     type = MaterialStdVectorAux
     variable = slip_rate_1
     property = slip_rate
     index = 0
     execute_on = timestep_end
   [../]
   [./slip_rate_2]
     type = MaterialStdVectorAux
     variable = slip_rate_2
     property = slip_rate
     index = 1
     execute_on = timestep_end
   [../]
   [./slip_rate_3]
     type = MaterialStdVectorAux
     variable = slip_rate_3
     property = slip_rate
     index = 2
     execute_on = timestep_end
   [../]
   [./slip_rate_4]
     type = MaterialStdVectorAux
     variable = slip_rate_4
     property = slip_rate
     index = 3
     execute_on = timestep_end
   [../]
   [./slip_rate_5]
     type = MaterialStdVectorAux
     variable = slip_rate_5
     property = slip_rate
     index = 4
     execute_on = timestep_end
   [../]
   [./slip_rate_6]
     type = MaterialStdVectorAux
     variable = slip_rate_6
     property = slip_rate
     index = 5
     execute_on = timestep_end
   [../]
   [./slip_rate_7]
     type = MaterialStdVectorAux
     variable = slip_rate_7
     property = slip_rate
     index = 6
     execute_on = timestep_end
   [../]
   [./slip_rate_8]
     type = MaterialStdVectorAux
     variable = slip_rate_8
     property = slip_rate
     index = 7
     execute_on = timestep_end
   [../]
   [./twin_rate_1]
     type = MaterialStdVectorAux
     variable = twin_rate_1
     property = twin_rate
     index = 0
     execute_on = timestep_end
   [../]
   [./twin_rate_2]
     type = MaterialStdVectorAux
     variable = twin_rate_2
     property = twin_rate
     index = 1
     execute_on = timestep_end
   [../]
   [./twin_rate_3]
     type = MaterialStdVectorAux
     variable = twin_rate_3
     property = twin_rate
     index = 2
     execute_on = timestep_end
   [../]
   [./twin_rate_4]
     type = MaterialStdVectorAux
     variable = twin_rate_4
     property = twin_rate
     index = 3
     execute_on = timestep_end
   [../]
   [./twin_rate_5]
     type = MaterialStdVectorAux
     variable = twin_rate_5
     property = twin_rate
     index = 4
     execute_on = timestep_end
   [../]
   [./twin_rate_6]
     type = MaterialStdVectorAux
     variable = twin_rate_6
     property = twin_rate
     index = 5
     execute_on = timestep_end
   [../]
   [./slip_resistance_1]
     type = MaterialStdVectorAux
     variable = slip_resistance_1
     property = slip_resistance
     index = 0
     execute_on = timestep_end
   [../]
   [./slip_resistance_2]
     type = MaterialStdVectorAux
     variable = slip_resistance_2
     property = slip_resistance
     index = 1
     execute_on = timestep_end
   [../]
   [./slip_resistance_3]
     type = MaterialStdVectorAux
     variable = slip_resistance_3
     property = slip_resistance
     index = 2
     execute_on = timestep_end
   [../]
   [./slip_resistance_4]
     type = MaterialStdVectorAux
     variable = slip_resistance_4
     property = slip_resistance
     index = 3
     execute_on = timestep_end
   [../]
   [./slip_resistance_5]
     type = MaterialStdVectorAux
     variable = slip_resistance_5
     property = slip_resistance
     index = 4
     execute_on = timestep_end
   [../]
   [./slip_resistance_6]
     type = MaterialStdVectorAux
     variable = slip_resistance_6
     property = slip_resistance
     index = 5
     execute_on = timestep_end
   [../]
   [./slip_resistance_7]
     type = MaterialStdVectorAux
     variable = slip_resistance_7
     property = slip_resistance
     index = 6
     execute_on = timestep_end
   [../]
   [./slip_resistance_8]
     type = MaterialStdVectorAux
     variable = slip_resistance_8
     property = slip_resistance
     index = 7
     execute_on = timestep_end
   [../]
   [./twin_resistance_1]
     type = MaterialStdVectorAux
     variable = twin_resistance_1
     property = twin_resistance
     index = 0
     execute_on = timestep_end
   [../]
   [./twin_resistance_2]
     type = MaterialStdVectorAux
     variable = twin_resistance_2
     property = twin_resistance
     index = 1
     execute_on = timestep_end
   [../]
   [./twin_resistance_3]
     type = MaterialStdVectorAux
     variable = twin_resistance_3
     property = twin_resistance
     index = 2
     execute_on = timestep_end
   [../]
   [./twin_resistance_4]
     type = MaterialStdVectorAux
     variable = twin_resistance_4
     property = twin_resistance
     index = 3
     execute_on = timestep_end
   [../]
   [./twin_resistance_5]
     type = MaterialStdVectorAux
     variable = twin_resistance_5
     property = twin_resistance
     index = 4
     execute_on = timestep_end
   [../]
   [./twin_resistance_6]
     type = MaterialStdVectorAux
     variable = twin_resistance_6
     property = twin_resistance
     index = 5
     execute_on = timestep_end
   [../]
[]
