/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_SETTINGS
  #define INTERNAL_INCLUDED_SETTINGS

  /* BUFFER OPTIONS */
  /*
    const int colortex0Format = RGBA16F;
    const int colortex1Format = RGB32F;
    const int colortex2Format = RGB32F;
    const int colortex3Format = RGBA16F;
    const int colortex4Format = RGBA16F;
    const int colortex5Format = RGB16;
    const int colortex6Format = RGB16;
    const int colortex7Format = RGBA16F;

    const bool colortex3Clear = false;

    const bool shadowtex0Mipmap = false;
    const bool shadowtex1Mipmap = false;
    const bool shadowcolor0Mipmap = false;
    const bool shadowcolor1Mipmap = false;
  */
  
  /* OPTIFINE OPTIONS */
  const float sunPathRotation = -40.5; // This controls the tilt angle of the sun's path across the sky. [-88.5 -87.0 -85.5 -84.0 -82.5 -81.0 -79.5 -78.0 -76.5 -75.0 -73.5 -72.0 -70.5 -69.0 -67.5 -66.0 -64.5 -63.0 -61.5 -60.0 -58.5 -57.0 -55.5 -54.0 -52.5 -51.0 -49.5 -48.0 -46.5 -45.0 -43.5 -42.0 -40.5 -39.0 -37.5 -36.0 -34.5 -33.0 -31.5 -30.0 -28.5 -27.0 -25.5 -24.0 -22.5 -21.0 -19.5 -18.0 -16.5 -15.0 -13.5 -12.0 -10.5 -9.0 -7.5 -6.0 -4.5 -3.0 -1.5 0.0 1.5 3.0 4.5 6.0 7.5 9.0 10.5 12.0 13.5 15.0 16.5 18.0 19.5 21.0 22.5 24.0 25.5 27.0 28.5 30.0 31.5 33.0 34.5 36.0 37.5 39.0 40.5 42.0 43.5 45.0 46.5 48.0 49.5 51.0 52.5 54.0 55.5 57.0 58.5 60.0 61.5 63.0 64.5 66.0 67.5 69.0 70.5 72.0 73.5 75.0 76.5 78.0 79.5 81.0 82.5 84.0 85.5 87.0 88.5]

  const int noiseTextureResolution = 64; // How large should the noise texture provided by Optifine be?. Larger resolutions reduce tiling, at the cost of performance. [128 256 512 1024 2048 4096]
  cRCP(float, noiseTextureResolution);

  const float ambientOcclusionLevel = 0.5; // How intense should Minecraft's built-in vertex AO be?. [0.0 0.25 0.5 0.75 1.0]

  const float wetnessHalflife = 600.0; // How long should the transition from wet to dry take?. [200.0 240.0 280.0 320.0 360.0 400.0 440.0 480.0 520.0 560.0 600.0 640.0 680.0 720.0 760.0 800.0 840.0 880.0 920.0 960.0 1000.0 1040.0 1080.0 1120.0 1160.0 1200.0]
  const float drynessHalflife = 60.0; // How long should the transition from dry to wet take?. [20.0 40.0 60.0 80.0 100.0 120.0 140.0 160.0 180.0 200.0]

  /* INCLUDES */
  #include "/lib/setting/Post.glsl"
  #include "/lib/setting/Volumetrics.glsl"
  #include "/lib/setting/Bloom.glsl"
  #include "/lib/setting/Sky.glsl"
  #include "/lib/setting/Lighting.glsl"
  #include "/lib/setting/Shadow.glsl"
  #include "/lib/setting/Parallax.glsl"
  #include "/lib/setting/Materials.glsl"
  #include "/lib/setting/Normals.glsl"
  #include "/lib/setting/Clouds.glsl"
  #include "/lib/setting/Refraction.glsl"

  /* SETTINGS */
  #define TEXTURE_RESOLUTION 128 // [16 32 64 128 256 512 1024 2048 4096]

  #define SPECULAR_FORMAT 2 // [0 1 2 3 4]

  #define GLOBAL_SPEED 1.0 // [0.0 0.083333 0.090909 0.1 0.111111 0.125 0.142857 0.166666 0.2 0.25 0.333333 0.5 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0]

  #define SEA_LEVEL 63.0

  cv(float) gammaCurveScreen = 2.2;
  cRCP(float, gammaCurveScreen);

  cv(float) dynamicRangeShadow = 4.0;
  cRCP(float, dynamicRangeShadow);

#endif /* INTERNAL_INCLUDED_SETTINGS */
