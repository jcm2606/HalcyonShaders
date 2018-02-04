/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_SYNTAX_VALUES
  #define INTERNAL_INCLUDED_SYNTAX_VALUES

  // CONSTANTS
  cv(float) pi = 3.14159265358979;
  cRCP(float, pi);

  cv(float) tau = 2.0 * pi;
  cRCP(float, tau);

  cv(float) phi = 1.61803398875;
  cRCP(float, phi);

  cv(float) ubyteMax = exp2(8);
  cRCP(float, ubyteMax);

  cv(float) uhalfMax = exp2(16);
  cRCP(float, uhalfMax);

  cv(float) uintMax = exp2(32);
  cRCP(float, uintMax);

  cv(float) ulongMax = exp2(64);
  cRCP(float, ulongMax);

  // SKY DRAW MODES
  #define SKY_MODE_DRAW 0
  #define SKY_MODE_LIGHTING 1
  #define SKY_MODE_REFLECT 2

  // TILE COORDINATES
  #define TILE_TEMPORAL_SMOOTHED_LUMA ivec2(0, 0)
  #define TILE_TEMPORAL_SMOOTHED_CENTER_DEPTH ivec2(0, 1)

#endif /* INTERNAL_INCLUDED_SYNTAX_VALUES */
