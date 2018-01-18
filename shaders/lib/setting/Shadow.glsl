/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_SETTING_SHADOW
  #define INTERNAL_INCLUDED_SETTING_SHADOW

  cv(float) shadowDepthBlocks = 1024.0;
  cv(float) shadowDepthMult = 256.0 / shadowDepthBlocks;

  const float shadowDistance = 128.0; // [128.0 256.0 384.0 512.0]
  cRCP(float, shadowDistance);
  cv(float) shadowDistanceScale = 128.0 / shadowDistance;

  const int shadowMapResolution = 2048;
  cRCP(float, shadowMapResolution);

  #define _cutShadow ceil // [floor ceil sign]

  #define SHADOW_QUALITY 12

  #define SHADOW_DISTORTION_FACTOR 0.9

#endif /* INTERNAL_INCLUDED_SETTING_SHADOW */
