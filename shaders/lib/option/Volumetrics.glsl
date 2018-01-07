/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_OPTION_VOLUMETRICS
  #define INTERNAL_INCLUDED_OPTION_VOLUMETRICS

  #define VOLUMETRICS

  // INTERNAL OPTIONS
  cv(int) vfSteps = 8;
  cRCP(float, vfSteps);

  cv(float) vfAbsorptionCoeffAir = 4.0;
  cv(float) vfAbsorptionCoeffWater = 16.0;

  // FOG LIGHTING
  //#define FOG_LIGHTING_DIRECT // When enabled, fog can self-shadow for direct light, ie sun or moon light. THIS IS EXTREMELY HEAVY ON PERFORMANCE!
  #define FOG_LIGHTING_DIRECT_STEPS 2 // How many steps should be taken for direct light self-shadowing?. More steps means more accurate shadows, in exchange for a huge impact to performance. [1 2 3 4 5 6 7 8]

  //#define FOG_LIGHTING_SKY // When enabled, fog can self-shadow for sky light. THIS IS EXTREMELY HEAVY ON PERFORMANCE!
  #define FOG_LIGHTING_SKY_STEPS 1 // How many steps should be taken for sky light self-shadowing?. More steps means more accurate shadows, in exchange for a huge impact to performance. [1 2 3 4 5 6 7 8]

  #define FOG_OCCLUSION_SKY 1 // Which method of occlusion should sky lighting use?. [0 1]

  //#define FOG_OCCLUSION_SKY_CLOUD // When enabled, clouds project shadows through the sky light in fog.

  // FOG LAYERS
  #define FOG_LAYER_HEIGHT // Height fog is a layer of fog that gets thicker as it gets lower into the world.
  #define FOG_LAYER_HEIGHT_DENSITY 0.05 // How dense should height fog be?. [0.0 0.025 0.05 0.075 0.1 0.125 0.15 0.175 0.2 0.225 0.25 0.275 0.3 0.325 0.35 0.375 0.4]
  #define FOG_LAYER_HEIGHT_FALLOFF 0.01 // How tall should height fog be?. The lower this number is, the taller height fog becomes. [0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.125 0.15 0.175 0.2]
  #define FOG_LAYER_HEIGHT_OFFSET 0.0 // What offset should be applied to sea level to obtain the height that height fog targets?.
  //#define FOG_LAYER_HEIGHT_EXPONENTIAL

  //#define FOG_LAYER_SHEET // SHeet fog is a dense layer of fog that exists in a thin sheet near sea level.
  #define FOG_LAYER_SHEET_DENSITY 3.0 // How dense should height fog be?. [0.5 1.0 1.5 2.0 2.5 3.0 3.5 4.0 4.5 5.0 5.5 6.0 6.5 7.0 7.5 8.0 12.0 16.0 24.0 32.0 48.0 64.0]
  #define FOG_LAYER_SHEET_FALLOFF 0.5 // How tall should sheet fog be?. The lower this number is, the taller sheet fog becomes. [0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
  #define FOG_LAYER_SHEET_HQ // When enabled, uses noise to vary the density of the sheet fog.
  #define FOG_LAYER_SHEET_OCTAVES 3 // How many octaves of noise should sheet fog use?. Higher numbers give a better shape to sheet fog, at the expense of performance. [1 2 3 4 5 6 7 8 9]

  //#define FOG_LAYER_ROLLING // Rolling fog is a very dense layer of fog that exists in huge volumes near sea level.
  #define FOG_LAYER_ROLLING_DENSITY 16.0 // How dense should height fog be?. [2.0 4.0 8.0 16.0 32.0 64.0 128.0]
  #define FOG_LAYER_ROLLING_FALLOFF 0.2 // How tall should height fog be?. The lower this number is, the taller height fog becomes. [0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5]
  #define FOG_LAYER_ROLLING_PRIMARY_OCTAVES 2 // How many octaves of noise should the main rolling volume use?. Higher numbers give a better shape to the volume, at the expense of performance. [1 2 3 4 5]
  #define FOG_LAYER_ROLLING_MIST_OCTAVES 5 // How many octaves of noise should the smaller rolling mist use?. Higher numbers give a better shape to mist, at the expense of performance. [1 2 3 4 5 6 7 8 9]
  #define FOG_LAYER_ROLLING_COVERAGE 0.4

  #define FOG_LAYER_RAIN // Rain fog is a thick layer of fog that occurs during rain.
  #define FOG_LAYER_RAIN_DENSITY 2.0 // How dense should rain fog be?. [0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0 4.0 8.0 16.0 32.0]

  #define FOG_LAYER_WATER // Water fog is a thick layer of fog that only occurs within volumes of water.
  #define FOG_LAYER_WATER_DENSITY 2.0 // How dense should water fog be?. [0.5 0.75 1.0 1.25 1.5 1.75 2.0 2.25 2.5 2.75 3.0 3.25 3.5 3.75 4.0 4.25 4.5 4.75 5.0]

  #define FOG_LAYER_NIGHT
  #define FOG_LAYER_NIGHT_DENSITY 0.1

#endif /* INTERNAL_INCLUDED_OPTION_VOLUMETRICS */
