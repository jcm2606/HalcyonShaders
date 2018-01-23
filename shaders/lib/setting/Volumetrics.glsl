/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_SETTING_VOLUMETRICS
  #define INTERNAL_INCLUDED_SETTING_VOLUMETRICS

  /*
    Height:
      20.0 - 1 block
      10.0 - 2 blocks
      5.0 - 4 blocks
  */

  // GENERAL
  #define VOLUMETRICS

  // ATMOSPHERIC SCATTERING
  #define ATMOSPHERIC_SCATTERING

  #define ATMOSPHERIC_SCATTERING_HEIGHT 256.0
  #define ATMOSPHERIC_SCATTERING_DENSITY 10.0

  cv(float) atmosphericScatteringHeight = 1.0 / ATMOSPHERIC_SCATTERING_HEIGHT;

  // FOG
  #define VOLUMETRIC_FOG

  #define VOLUMETRIC_FOG_HEIGHT 64.0
  #define VOLUMETRIC_FOG_DENSITY 0.002

  cv(float) volumetricFogHeight = 1.0 / VOLUMETRIC_FOG_HEIGHT;
  cv(float) volumetricFogDensity = VOLUMETRIC_FOG_DENSITY;

  // WATER
  #define VOLUMETRIC_WATER

  cv(vec3) waterScatterCoeff = vec3(0.002) / log(2.0);
  cv(vec3) waterAbsorptionCoeff = vec3(0.4510, 0.0867, 0.0476) * 1.0 / log(2.0);
  cv(vec3) waterTransmittanceCoeff = waterScatterCoeff + waterAbsorptionCoeff;

  #define VOLUMETRIC_WATER_DENSITY 1.0

#endif /* INTERNAL_INCLUDED_SETTING_VOLUMETRICS */
