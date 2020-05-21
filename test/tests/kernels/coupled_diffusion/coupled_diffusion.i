[Mesh]
  type = GeneratedMesh
  dim = 1
  xmax = 65
  nx = 100
  elem_type = EDGE
[]

[Variables]
  [./c_a]

  [../]
  [./c_v]

  [../]
  [./c_i]

  [../]
[]

[AuxVariables]
  [./c_b]

  [../]
[]

[ICs]
  [./c_a_IC]
    type = BoundingBoxIC
    variable = c_a
    x1 = 0
    x2 = 65
    y1 = 0
    y2 = 0
    inside = 0.2
  [../]
  [./c_b_IC]
    type = BoundingBoxIC
    variable = c_b
    x1 = 0
    x2 = 65
    y1 = 0
    y2 = 0
    inside = 0.8
  [../]
  [./c_v_IC]
    type = BoundingBoxIC
    variable = c_v
    x1 = 0
    x2 = 65
    y1 = 0
    y2 = 0
    inside = 1.16e-8
  [../]
  [./c_i_IC]
    type = BoundingBoxIC
    variable = c_i
    x1 = 0
    x2 = 65
    y1 = 0
    y2 = 0
    inside = 8.08e-24
  [../]
[]

[Kernels]
  [./c_v_dot]
    type = TimeDerivative
    variable = c_v
  [../]
  [./c_v_diffusion]
    type = MatDiffusion
    variable = c_v
    diffusivity = D_v
    args = 'c_a'
  [../]
  [./c_v_RIS_diffusion]
    type = CoupledDiffusion
    variable = c_v
    diffusivity = D_bv_av
    chi = chi
    omega = omega
    v = c_a
  [../]
  [./c_v_production]
    type = BodyForce
    variable = c_v
    value = 1e-6
  [../]
  [./c_v_recombinatin]
    type = BodyForce
    variable = c_v
    value = -84.1
  [../]

  [./c_i_dot]
    type = TimeDerivative
    variable = c_i
  [../]
  [./c_i_diffusion]
    type = MatDiffusion
    variable = c_i
    diffusivity = D_i
    args = 'c_a'
  [../]
  [./c_i_RIS_diffusion]
    type = CoupledDiffusion
    variable = c_i
    diffusivity = D_ai_bi
    chi = chi
    omega = omega
    v = c_a
  [../]
  [./c_i_production]
    type = BodyForce
    variable = c_i
    value = 1e-6
  [../]
  [./c_i_recombinatin]
    type = BodyForce
    variable = c_i
    value = -84.1
  [../]

  [./c_a_dot]
    type = TimeDerivative
    variable = c_a
  [../]
  [./c_a_diffusion]
    type = MatDiffusion
    variable = c_a
    diffusivity = D_a
  [../]
  [./c_a_RIS_diffusion_c_i]
    type = CoupledDiffusion
    variable = c_a
    diffusivity = d_ai
    chi = 1
    omega = omega
    v = c_i
  [../]
  [./c_a_RIS_diffusion_c_v]
    type = CoupledDiffusion
    variable = c_a
    diffusivity = d_av
    chi = -1
    omega = omega
    v = c_v
  [../]
[]

[AuxKernels]
  [./c_b_function]
    type = ParsedAux
    variable = c_b
    args = c_a
    function = '1 - c_a'
  [../]
[]

[Materials]
  [./constants]
    type = GenericConstantMaterial
    prop_names =  'd_av   d_bv  d_ai    d_bi  chi omega'
    prop_values = '0.49e6 5.4e6 4.05e10 3.7e9 1   9e-3'
  [../]
  [./D_v]
    type = ParsedMaterial
    f_name = D_v
    function = 'd_av * c_a + d_bv * c_b'
    material_property_names = 'd_av d_bv'
    args = 'c_a c_b'
  [../]
  [./D_i]
    type = ParsedMaterial
    f_name = D_i
    function = 'd_ai * c_a + d_bi * c_b'
    material_property_names = 'd_ai d_bi'
    args = 'c_a c_b'
  [../]
  [./D_a]
    type = ParsedMaterial
    f_name = D_a
    function = 'd_av * c_v + d_ai * c_i'
    material_property_names = 'd_av d_ai'
    args = 'c_v c_i'
  [../]
  [./D_b]
    type = ParsedMaterial
    f_name = D_b
    function = 'd_bv * c_v + d_bi * c_i'
    material_property_names = 'd_bv d_bi'
    args = 'c_v c_i'
  [../]
  [./D_bv_av]
    type = ParsedMaterial
    f_name = D_bv_av
    function = 'd_bv - d_av'
    material_property_names = 'd_bv d_av'
  [../]
  [./D_ai_bi]
    type = ParsedMaterial
    f_name = D_ai_bi
    function = 'd_ai - d_bi'
    material_property_names = 'd_ai d_bi'
  [../]
[]

[BCs]
  [./c_v_bc_left]
    type = DirichletBC
    variable = c_v
    value = 1.16e-8
    boundary = left
  [../]
  [./c_i_bc_left]
    type = DirichletBC
    variable = c_i
    value = 8.08e-24
    boundary = left
  [../]
  [./c_a_bc_left]
    type = NeumannBC
    variable = c_a
    value = 0
    boundary = left
  [../]

  [./c_v_bc_right]
    type = NeumannBC
    variable = c_v
    value = 0
    boundary = right
  [../]
  [./c_i_bc_right]
    type = NeumannBC
    variable = c_i
    value = 0
    boundary = right
  [../]
  [./c_a_bc_right]
    type = NeumannBC
    variable = c_a
    value = 0
    boundary = right
  [../]
[]


[Preconditioning]
  [./off_diag_coupling]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = NEWTON

  petsc_options_iname = '-pc_type -pc_factor_mat_solving_package'
  petsc_options_value = 'lu       superlu_dist'

  # petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  # petsc_options_value = 'asm         31   preonly   lu      1'

  l_max_its = 30
  l_tol = 1e-4

  nl_max_its = 15
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-9

  num_steps = 2

  dt = 1
[]

[Outputs]
  exodus = true
[]
