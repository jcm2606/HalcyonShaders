/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_SETTING_VOLUMETRICS
  #define INTERNAL_INCLUDED_SETTING_VOLUMETRICS

  // GENERAL
  #define VOLUMETRICS

  // ATMOSPHERIC SCATTERING
  #define ATMOSPHERIC_SCATTERING

  // FOG
  #define VOLUMETRIC_FOG

  // WATER
  #define VOLUMETRIC_WATER

  cv(vec3) waterScatterCoeff = vec3(0.003) / log(2.0);
  cv(vec3) waterAbsorptionCoeff = vec3(0.4510, 0.0867, 0.0476) * 1.0 / log(2.0);
  cv(vec3) waterTransmittanceCoeff = waterScatterCoeff + waterAbsorptionCoeff;

  #define VOLUMETRIC_WATER_DENSITY 1.0

#endif /* INTERNAL_INCLUDED_SETTING_VOLUMETRICS */
