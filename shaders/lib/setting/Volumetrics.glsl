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

  #define ATMOSPHERIC_SCATTERING_HEIGHT 384.0 // [64.0 128.0 192.0 256.0 320.0 384.0 448.0 512.0]
  #define ATMOSPHERIC_SCATTERING_DENSITY 10.0 // [2.5 5.0 7.5 10.0 12.5 15.0 17.5 20.0 22.5 25.0 27.5 30.0]

  cv(float) vol_airHeight = 1.0 / ATMOSPHERIC_SCATTERING_HEIGHT;
  cv(float) vol_airDensity = ATMOSPHERIC_SCATTERING_DENSITY;

  // VOLUMETRIC FOG
  #define VOLUMETRIC_FOG

  #define VOLUMETRIC_FOG_HEIGHT
  #define VOLUMETRIC_FOG_HEIGHT_HEIGHT 48.0 // [8.0 16.0 24.0 32.0 40.0 48.0 56.0 64.0 72.0 80.0 88.0 96.0 104.0 112.0 120.0 128.0]
  #define VOLUMETRIC_FOG_HEIGHT_DENSITY 0.025 // [0.025 0.05 0.075 0.1 0.125 0.15 0.175 0.2 0.225 0.25 0.275 0.3]

  cv(float) vol_fogHeightHeight = 1.0 / VOLUMETRIC_FOG_HEIGHT_HEIGHT;
  cv(float) vol_fogHeightDensity = VOLUMETRIC_FOG_HEIGHT_DENSITY;

  //#define VOLUMETRIC_FOG_SHEET
  #define VOLUMETRIC_FOG_SHEET_HEIGHT 2.0 // [1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0 13.0 14.0 15.0 16.0]
  #define VOLUMETRIC_FOG_SHEET_DENSITY 1.0 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

  cv(float) vol_fogSheetHeight = 1.0 / VOLUMETRIC_FOG_SHEET_HEIGHT;
  cv(float) vol_fogSheetDensity = VOLUMETRIC_FOG_SHEET_DENSITY;

  #define VOLUMETRIC_FOG_RAIN
  #define VOLUMETRIC_FOG_RAIN_HEIGHT 48.0
  #define VOLUMETRIC_FOG_RAIN_DENSITY 0.2

  cv(float) vol_fogRainHeight = 1.0 / VOLUMETRIC_FOG_RAIN_HEIGHT;
  cv(float) vol_fogRainDensity = VOLUMETRIC_FOG_RAIN_DENSITY;

  cv(vec3) fogScatterCoeff = vec3(0.01) / log(2.0);
  cv(vec3) fogAbsorbCoeff  = vec3(0.02) / log(2.0);
  cv(vec3) fogTransmittanceCoeff = fogScatterCoeff + fogAbsorbCoeff;

  // VOLUMETRIC WATER
  #define VOLUMETRIC_WATER

  #define VOLUMETRIC_WATER_TURBIDITY 0.25 // [0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]
  #define VOLUMETRIC_WATER_ABSORPTION 0.5 // [0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]

  #define VOLUMETRIC_WATER_SCATTER_COLOUR 0 // [0]

  #if   VOLUMETRIC_WATER_SCATTER_COLOUR == 0
    cv(vec3) waterScatterColour = vec3(1.0);
  #elif VOLUMETRIC_WATER_SCATTER_COLOUR == 1
    cv(vec3) waterScatterColour = _rgb_from255(vec3(127, 255, 212));
  #endif

  cv(vec3) waterScatterCoeff = waterScatterColour * VOLUMETRIC_WATER_TURBIDITY * 0.025 / log(2.0);
  cv(vec3) waterAbsorbCoeff = vec3(0.4510, 0.0867, 0.0476) * 2.0 * VOLUMETRIC_WATER_ABSORPTION / log(2.0);
  cv(vec3) waterTransmittanceCoeff = waterScatterCoeff + waterAbsorbCoeff;

  // VOLUMETRIC ICE
  cv(vec3) iceScatterCoeff = vec3(0.01) / log(2.0);
  cv(vec3) iceAbsorbCoeff = vec3(0.4510, 0.0867, 0.0476) / log(2.0);
  cv(vec3) iceTransmittanceCoeff = iceScatterCoeff + iceAbsorbCoeff;

#endif /* INTERNAL_INCLUDED_SETTING_VOLUMETRICS */
