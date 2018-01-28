/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_SETTING_CLOUDS
  #define INTERNAL_INCLUDED_SETTING_CLOUDS

  #define CLOUDS

  // MAIN
  #define CLOUDS_STEPS 3 // [2 3 4 5 6 7 8 9 10 11 12 13 14 15 16]
  #define CLOUDS_OCTAVES 4 // [3 4 5 6]

  cv(int) cloudSteps = CLOUDS_STEPS;
  cRCP(float, cloudSteps);
  cv(int) cloudOctaves = CLOUDS_OCTAVES;
  cRCP(float, cloudOctaves);

  cv(float) cloudHorizonFade = 0.1;

  // LIGHTING
  #define CLOUDS_LIGHTING_DIRECT_INTENSITY 5.0
  #define CLOUDS_LIGHTING_SKY_INTENSITY 4.0
  #define CLOUDS_LIGHTING_BOUNCED_INTENSITY 0.125

  #define CLOUDS_LIGHTING_DIRECT_STEPS 2 // [0 1 2 3 4 5 6 7 8]
  #define CLOUDS_LIGHTING_SKY_STEPS 1 // [0 1 2 3 4 5 6 7 8]
  #define CLOUDS_LIGHTING_BOUNCED_STEPS 0 // [0 1 2 3 4 5 6 7 8]

  #define CLOUDS_LIGHTING_DIRECT_WEIGHT 1.0
  #define CLOUDS_LIGHTING_SKY_WEIGHT 1.25
  #define CLOUDS_LIGHTING_BOUNCED_WEIGHT 1.25

  cv(float) cloudLightDirectIntensity = CLOUDS_LIGHTING_DIRECT_INTENSITY * cloudOctavesRCP;
  cv(float) cloudLightSkyIntensity = CLOUDS_LIGHTING_SKY_INTENSITY * cloudOctavesRCP;
  cv(float) cloudLightBouncedIntensity = CLOUDS_LIGHTING_BOUNCED_INTENSITY * cloudOctavesRCP;

  // CLOUD SHADOWING
  #define CLOUD_SHADOW

  #define CLOUD_SHADOW_SKY // When enabled, sky light is shadowed by cloud directly overhead.
  #define CLOUD_SHADOW_SKY_INTENSITY 0.75
 
  cv(float) cloudShadowSkyIntensityInverse = 1.0 - CLOUD_SHADOW_SKY_INTENSITY;

#endif /* INTERNAL_INCLUDED_SETTING_CLOUDS */
