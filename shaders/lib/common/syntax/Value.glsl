/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_SYNTAX_VALUE
  #define INTERNAL_INCLUDED_SYNTAX_VALUE

  c(float) pi = 3.14159265358979;
  cRCP(float, pi);

  c(float) tau = 2.0 * pi;
  cRCP(float, tau);

  c(float) phi = 1.61803398875;
  cRCP(float, phi);

  c(float) ubyteMax = exp2(8);
  cRCP(float, ubyteMax);

  c(float) uhalfMax = exp2(16);
  cRCP(float, uhalfMax);

  c(float) uintMax = exp2(32);
  cRCP(float, uintMax);

  c(float) ulongMax = exp2(64);
  cRCP(float, ulongMax);

  c(float) iorAir = 1.0003;
  c(float) iorWater = 1.333;

  c(float) refractInterfaceAirWater = iorAir / iorWater;
  c(float) refractInterfaceWaterAir = iorWater / iorAir;

#endif /* INTERNAL_INCLUDED_SYNTAX_VALUE */
