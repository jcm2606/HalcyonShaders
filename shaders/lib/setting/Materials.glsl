/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_SETTING_MATERIALS
  #define INTERNAL_INCLUDED_SETTING_MATERIALS

  #define F0_DIELECTRIC 0.02
  #define F0_METAL 0.8

  /*
    Material Format: vec4(smoothness, f0, emission, pourosity)
  */

  #define MATERIAL_DEFAULT vec4(0.0, 0.02, 0.0, 0.0)

  #define MATERIAL_WATER vec4(0.93, 0.05, 0.0, 0.0)
  #define MATERIAL_STAINED_GLASS vec4(0.96, 0.05, 0.0, 0.0)

#endif /* INTERNAL_INCLUDED_SETTING_MATERIALS */
