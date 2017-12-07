/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_OPTION_VOLUMETRICS
  #define INTERNAL_INCLUDED_OPTION_VOLUMETRICS

  #define VOLUMETRICS

  // FOG LIGHTING
  //#define FOG_LIGHTING_DIRECT // When enabled, fog can self-shadow for direct light, ie sun or moon light. THIS IS EXTREMELY HEAVY ON PERFORMANCE!
  #define FOG_LIGHTING_DIRECT_STEPS 2 // How many steps should be taken for direct light self-shadowing?. More steps means more accurate shadows, at the cost of a huge performance impact. [1 2 3 4 5 6 7 8]

  //#define FOG_LIGHTING_SKY // When enabled, fog can self-shadow for sky light. THIS IS EXTREMELY HEAVY ON PERFORMANCE!
  #define FOG_LIGHTING_SKY_STEPS 1 // How many steps should be taken for sky light self-shadowing?. More steps means more accurate shadows, at the cost of a huge performance impact. [1 2 3 4 5 6 7 8]

  #define FOG_OCCLUSION_SKY 1 // Which method of occlusion should sky lighting use?. [0 1]

  // FOG LAYERS
  #define FOG_LAYER_HEIGHT // When enabled, height fog is included in the fog function. Height fog is a thin layer of fog that gets thicker as it approaches sea level. Height fog is an analytical layer of fog, and as such is fairly cheap.
  #define FOG_LAYER_HEIGHT_DENSITY 0.15 // How dense should height fog be?. [0.0 0.025 0.05 0.075 0.1 0.125 0.15 0.175 0.2 0.225 0.25 0.275 0.3 0.325 0.35 0.375 0.4]
  #define FOG_LAYER_HEIGHT_FALLOFF 0.01 // How quick should height fog get thinner, relative to world height?. The higher this value is, the quicker the fog gets thinner. [0.01]

  //#define FOG_LAYER_SHEET // When enabled, sheet fog is included in the fog function. Sheet fog is a thick layer of mist that exists in a thin sheet across sea level. Sheet fog is a volumetric layer of fog, and as such does impact performance.
  #define FOG_LAYER_SHEET_DENSITY 8.0 // How dense should height fog be?. [2.0 4.0 8.0 16.0 32.0 64.0 128.0 256.0]
  #define FOG_LAYER_SHEET_FALLOFF 0.5 // How quick should height fog get thinner, relative to world height?. The higher this value is, the quicker the fog gets thinner. [1.0]
  #define FOG_LAYER_SHEET_HQ // When enabled, uses noise to vary the density of the sheet fog.
  #define FOG_LAYER_SHEET_OCTAVES 3 // How many octaves of noise should sheet fog use? [1 2 3 4 5 6 7 8 9]

  //#define FOG_LAYER_VOLUME // When enabled, volume fog is included in the fog function. Volume fog is a very thick layer of fog that exists in volumes near sea level. Volume fog is a volumetric layer of fog, and as such does impact performance.

  #define FOG_LAYER_RAIN // When enabled, rain fog is included in the fog function. Rain fog is a very thick layer of fog that builds up during rain. Rain fog is an analytical layer of fog, and as such is fairly cheap.
  #define FOG_LAYER_RAIN_MULTIPLIER 0.4

  #define FOG_LAYER_WATER // When enabled, water fog is included in the fog function. Water fog is a thick layer of fog that exists specifically in volumes of water. Water fog is an analytical layer of fog, and is very cheap.
  #define FOG_LAYER_WATER_DENSITY 2.0 // How dense should height fog be?.

#endif /* INTERNAL_INCLUDED_OPTION_VOLUMETRICS */
