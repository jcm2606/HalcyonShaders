/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_SETTING_LIGHTING
  #define INTERNAL_INCLUDED_SETTING_LIGHTING

  // ATMOSPHERE LIGHTING
  #define ATMOS_LIGHTING_DIRECT_INTENSITY 0.0005
  #define ATMOS_LIGHTING_SKY_INTENSITY 4.0

  #define SUN_LIGHT_INTENSITY 32768.0
  #define SUN_SPOT_MULTIPLIER 0.25

  #define MOON_LIGHT_INTENSITY 8.0
  #define MOON_SPOT_MULTIPLIER 1.0

  // BLOCK LIGHTMAP
  #define BLOCK_LIGHT_ANISOTROPY 0.46 // [0.0 0.4 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.5 0.6 0.7 0.8 0.9 1.0]
  #define BLOCK_LIGHT_ATTENUATION 2.5
  #define BLOCK_LIGHT_INTENSITY 1.0

  #define BLOCK_LIGHT_COLOUR 0

  cv(vec3) blockLightColour = vec3(1.0, 0.45, 0.2);

  // SKY LIGHTMAP
  #define SKY_LIGHT_ANISOTROPY 0.45 // [0.0 0.4 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.5]
  #define SKY_LIGHT_ATTENUATION 2.0
  #define SKY_LIGHT_INTENSITY 1.0

  // SPECULAR LIGHTING
  //#define SPECULAR_DUAL_LAYER // When enabled, specular lighting will be calculated for opaque and transparent geometry simultaneously. This will allow reflections on opaque blocks to appear through transparent blocks, at a significant impact to performance.

  #define SPECULAR_SAMPLES 4 // How many samples should be taken for specular lighting?. More samples reduces the grain in reflections, at the cost of performance. [4 6 8 10 12 14 16 18 20 22 24 26 28 30 32]
  #define SPECULAR_QUALITY 4.0 // How accurate should specular lighting be?. Higher accuracy reduces the amount of artifacts in reflections, at the cost of performance. [2.0 4.0 6.0 8.0 10.0 12.0 14.0 16.0]
  #define SPECULAR_REFINEMENTS 4 // [2 4 6 8 10 12 14 16]

#endif /* INTERNAL_INCLUDED_SETTING_LIGHTING */
