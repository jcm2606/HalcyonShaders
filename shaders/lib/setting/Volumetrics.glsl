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

  #define HEIGHT_FOG
  #define HEIGHT_FOG_HEIGHT 64.0
  #define HEIGHT_FOG_DENSITY 0.01 // [0.001 0.0025 0.005 0.0075 0.01 0.025 0.05 0.075 0.1 0.125 0.15 0.175 0.2]

  cv(vec2) heightFogParameters = vec2(1.0 / HEIGHT_FOG_HEIGHT, HEIGHT_FOG_DENSITY);

  //#define SHEET_FOG
  #define SHEET_FOG_HEIGHT 4.0 // [2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0 13.0 14.0 15.0 16.0]
  #define SHEET_FOG_DENSITY 0.1 // [0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5]

  cv(vec2) sheetFogParameters = vec2(1.0 / SHEET_FOG_HEIGHT, SHEET_FOG_DENSITY);

  // WATER
  #define VOLUMETRIC_WATER

  #define VOLUMETRIC_WATER_DENSITY 1.0 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

  #define VOLUMETRIC_WATER_ABSORPTION_STRENGTH 1.0 // How strong should absorption be?. In reality,  [0.5 0.75 1.0 1.25 1.5 1.75 2.0 2.25 2.5 2.75 3.0]
  #define VOLUMETRIC_WATER_TURBIDITY 0.25 // How turbid should water be?. Turbidity is the measure of how much light a given volume of fluid scatters. Pure water does not scatter light, it only absorbs light, so most of the "fog" you see in water is caused by other particles trapped in the water. [0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]

  #define VOLUMETRIC_WATER_SCATTER_COLOUR 0 // [0 1]

  #if   VOLUMETRIC_WATER_SCATTER_COLOUR == 0
    cv(vec3) waterScatterColour = vec3(1.0);
  #elif VOLUMETRIC_WATER_SCATTER_COLOUR == 1
    cv(vec3) waterScatterColour = vec3(1.0, 0.75, 0.5);
  #endif

  cv(vec3) waterScatterCoeff = waterScatterColour * (VOLUMETRIC_WATER_TURBIDITY * 0.02) / log(2.0);
  cv(vec3) waterAbsorptionCoeff = vec3(0.4510, 0.0867, 0.0476) * VOLUMETRIC_WATER_ABSORPTION_STRENGTH / log(2.0);
  cv(vec3) waterTransmittanceCoeff = waterScatterCoeff * 4.0 + waterAbsorptionCoeff;

#endif /* INTERNAL_INCLUDED_SETTING_VOLUMETRICS */
