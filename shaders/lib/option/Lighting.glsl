/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_OPTION_LIGHTING
  #define INTERNAL_INCLUDED_OPTION_LIGHTING

  // BLOCK LIGHT
  #define BLOCK_LIGHT_STRENGTH 2.0
  #define BLOCK_LIGHT_ATTENUATION 4.0

  #define BLOCK_LIGHT_COLOUR 0 // [0]

  #if   BLOCK_LIGHT_COLOUR == 0
    cv(vec3) blockLightColour = vec3(1.0, 0.6, 0.3);
  #else
    cv(vec3) blockLightColour = vec3(1.0, 0.1, 0.0);
  #endif

  // SKY LIGHT
  #define SKY_LIGHT_STRENGTH 4.0

  // DIRECTIONAL LIGHTMAPS
  #define DL_BLOCK_STEEPNESSS 0.5

  cv(float) dlBlSteepnessA = DL_BLOCK_STEEPNESSS;
  cv(float) dlBlSteepnessB = 1.0 - dlBlSteepnessA;

  #define DL_SKY_STEEPNESSS 0.4

  cv(float) dlSlSteepnessA = DL_SKY_STEEPNESSS;
  cv(float) dlSlSteepnessB = 1.0 - dlSlSteepnessA;

#endif /* INTERNAL_INCLUDED_OPTION_LIGHTING */
