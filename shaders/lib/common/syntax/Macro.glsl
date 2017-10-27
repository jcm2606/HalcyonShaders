/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_SYNTAX_MACRO
  #define INTERNAL_INCLUDED_SYNTAX_MACRO

  #define io inout
  
  #define c(type) const type
  #define cin(type) const in type
  #define cRCP(type, name) const type name##RCP = 1.0 / name

  #define flat(type) flat varying type
  #define attr(type) attribute type

  #define clamp01(x) clamp(x, 0.0, 1.0)
  #define max0(x) max(x, 0.0)
  #define max1(x) max(x, 1.0)
  #define min0(x) min(x, 0.0)
  #define min1(x) min(x, 1.0)

  #define random(x) fract(sin(dotx, vec2(12.9898, 4.1414)) * 43758.5453)
  
  #define getLandMask(x) (x < 1.0 - near / far / far)

  #define getSunVector()   ( sunVector   = fnormalize( sunPosition) )
  #define getMoonVector()  ( moonVector  = fnormalize(-sunPosition) )
  #define getLightVector() ( lightVector = (sunAngle > 0.5) ? moonVector : sunVector )

  #define getSmoothedMoonPhase() ( (float(moonPhase) * 24000.0 + float(worldTime)) * 0.00000595238095238 )

  #define upVector gbufferModelView[1].xyz

  #define timeNoon    timeVector.x
  #define timeNight   timeVector.y
  #define timeHorizon timeVector.z
  #define timeMorning timeVector.w

#endif /* INTERNAL_INCLUDED_SYNTAX_MACRO */
