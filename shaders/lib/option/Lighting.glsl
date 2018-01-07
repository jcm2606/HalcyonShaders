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
  #define SKY_LIGHT_STRENGTH 8.0

  // DIRECTIONAL LIGHTMAPS
  #define DIRECTIONAL_LIGHTMAP_STEEPNESS 0.45

  cv(float) dlSteepnessA = DIRECTIONAL_LIGHTMAP_STEEPNESS;
  cv(float) dlSteepnessB = 1.0 - dlSteepnessA;

#endif /* INTERNAL_INCLUDED_OPTION_LIGHTING */
