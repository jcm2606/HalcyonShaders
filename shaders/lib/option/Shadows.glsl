/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_OPTION_SHADOWS
  #define INTERNAL_INCLUDED_OPTION_SHADOWS

  #define SHADOW_DISTORTION_FACTOR 0.9

  #define LIGHT_SOURCE_DISTANCE 2048.0 // How far from the world should the light source be?. This influences how soft shadows appear. The lower the distance, the softer shadows will appear. [1.0 2.0 4.0 8.0 16.0 32.0 64.0 128.0 256.0 512.0 1024.0 2048.0 4096.0 8192.0 16384.0 32768.0 65536.0]

  c(float) lightSourceDistanceScaled = LIGHT_SOURCE_DISTANCE / 512.0;

  #define SHADOW_FILTER_QUALITY 2 // How large should the filter be?. Larger sizes give smoother penumbras to shadows, but significantly impact performance. [1 2 3 4 5 6]
  #define SHADOW_FILTER_MIN_WIDTH 0.25 // What should the minimum width of the shadow penumbra be?. This is mostly used to combat aliasing on contact shadows.
  #define SHADOW_FILTER_MAX_WIDTH 2.0 // What should the maximum width of the shadow penumbra be?. This is mostly used to hide sampling artifacts and improve performance when the penumbra gets very wide.

  #define CutShadow ceil // Which method should shadows use for the cut?. This is an internal variable, do not change unless you know what you're doing. [ceil floor round sign]

  /*

    Shadow Distance Key:
      shadowDistance = (renderDistance * 16.0) + 32.0

    Shadow Distances:
      4 chunks = 96.0
      8 chunks = 160.0
      12 chunks = 224.0
      16 chunks = 288.0
      20 chunks = 352.0
      24 chunks = 416.0
      28 chunks = 480.0
      32 chunks = 544.0
      36 chunks = 608.0
      40 chunks = 672.0
      44 chunks = 736.0
      48 chunks = 800.0
      52 chunks = 862.0
      56 chunks = 928.0
      60 chunks = 992.0
      64 chunks = 1056.0

  */

  const float shadowDistance = 160.0; // This controls the render distance used for shadows. Set this to whatever render distance is equal to or below the render distance you've select in video settings. [96.0 160.0 224.0 288.0 352.0 416.0 480.0 544.0 608.0 672.0 736.0 800.0 862.0 928.0 992.0 1056.0]
  cRCP(float, shadowDistance);
  c(float) shadowDistanceScale = 160.0 / shadowDistance;
  cRCP(float, shadowDistanceScale);

  const int shadowMapResolution = 2048; // This controls the resolution of the shadow map. Higher resolutions mean higher detailed shadows, but can significantly impact performance. [512 1024 2048 3072 4096 8192]
  cRCP(float, shadowMapResolution);

#endif /* INTERNAL_INCLUDED_OPTION_SHADOWS */
