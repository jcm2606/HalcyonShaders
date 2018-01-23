/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_SETTING_SHADOW
  #define INTERNAL_INCLUDED_SETTING_SHADOW

  cv(float) shadowDepthBlocks = 1024.0;
  cv(float) shadowDepthMult = 256.0 / shadowDepthBlocks;

  const float shadowDistance = 160.0; // What render distance should the shadow map use?. Set this to whatever render distance is above or equal to the game's render distance. [160.0 288.0 416.0 544.0 672.0 800.0 928.0 1056.0]
  cRCP(float, shadowDistance);
  cv(float) shadowDistanceScale = 160.0 / shadowDistance;

  const float shadowRenderDistanceMult = 1.0;

  const int shadowMapResolution = 2048; // What resolution should be used for the shadow map?. Higher resolutions greatly improve the quality of shadows by reducing aliasing, but significantly impacts performance. // [1024 2048 3072 4096 8192]
  cRCP(float, shadowMapResolution);

  #define _cutShadow ceil // What function should be used for the shadow cut?. Don't touch unless you know what you're doing! [floor ceil sign nullop]

  #define SHADOW_QUALITY 6 // How many samples should be used for shadows?. Higher samples reduces the grain in shadows, at the expense of performance. [6 8 10 12 14 16 18 20 22 24 26 28 30 32]

  #define SHADOW_DISTORTION_FACTOR 0.9 // How detailed should shadows be near the player?. Higher values increases detail near the player, at the expense of detail away from the player. This does not impact performance. [0.8 0.85 0.9 0.95]

#endif /* INTERNAL_INCLUDED_SETTING_SHADOW */
