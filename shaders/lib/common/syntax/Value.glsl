/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_SYNTAX_VALUE
  #define INTERNAL_INCLUDED_SYNTAX_VALUE

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

  cv(float) iorAir = 1.0003;
  cv(float) iorWater = 1.333;

  cv(float) refractInterfaceAirWater = iorAir / iorWater;
  cv(float) refractInterfaceWaterAir = iorWater / iorAir;

#endif /* INTERNAL_INCLUDED_SYNTAX_VALUE */
