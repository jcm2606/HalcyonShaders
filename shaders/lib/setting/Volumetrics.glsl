/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_SETTING_VOLUMETRICS
  #define INTERNAL_INCLUDED_SETTING_VOLUMETRICS

  // GENERAL
  #define VOLUMETRICS

  // LAYERS
  // ATMOSPHERIC SCATTERING / AIR
  #define ATMOSPHERIC_SCATTERING

  // VOLUMETRIC FOG
  #define VOLUMETRIC_FOG

  cv(vec3) fogScatterCoeff = vec3(0.01) / log(2.0);
  cv(vec3) fogAbsorbCoeff  = vec3(0.01) / log(2.0);
  cv(vec3) fogTransmittanceCoeff = fogScatterCoeff + fogAbsorbCoeff;

  // VOLUMETRIC WATER
  #define VOLUMETRIC_WATER

  #define VOLUMETRIC_WATER_TURBIDITY 0.25 // [0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]
  #define VOLUMETRIC_WATER_ABSORPTION 1.0

  cv(vec3) waterScatterCoeff = vec3(1.0) * VOLUMETRIC_WATER_TURBIDITY * 0.025 / log(2.0);
  cv(vec3) waterAbsorbCoeff = vec3(0.4510, 0.0867, 0.0476) * VOLUMETRIC_WATER_ABSORPTION / log(2.0);
  cv(vec3) waterTransmittanceCoeff = waterScatterCoeff + waterAbsorbCoeff;

#endif /* INTERNAL_INCLUDED_SETTING_VOLUMETRICS */
