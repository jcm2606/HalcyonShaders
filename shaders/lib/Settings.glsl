/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_SETTINGS
  #define INTERNAL_INCLUDED_SETTINGS

  // BUFFER OPTIONS
  /*
    const int colortex0Format = RGBA16F;
    const int colortex1Format = RGB32F;
    const int colortex2Format = RGB32F;
    const int colortex3Format = R11F_G11F_B10F;
    const int colortex4Format = RGBA16F;
    const int colortex5Format = RGBA16F;
    const int colortex6Format = RGBA16;
    const int colortex7Format = RGBA16F;

    const bool colortex0Clear = true;
    const bool colortex1Clear = true;
    const bool colortex2Clear = true;
    const bool colortex3Clear = false;
    const bool colortex4Clear = true;
    const bool colortex5Clear = true;
    const bool colortex6Clear = true;
    const bool colortex7Clear = true;
  */

  // OPTIFINE OPTIONS
  const int shadowMapResolution = 2048; // [512 1024 2048 3072 4096 8192]
  const float shadowDistance = 16.0 * 32.0;

  const float sunPathRotation = 24.0; // [-88.5 -87.0 -85.5 -84.0 -82.5 -81.0 -79.5 -78.0 -76.5 -75.0 -73.5 -72.0 -70.5 -69.0 -67.5 -66.0 -64.5 -63.0 -61.5 -60.0 -58.5 -57.0 -55.5 -54.0 -52.5 -51.0 -49.5 -48.0 -46.5 -45.0 -43.5 -42.0 -40.5 -39.0 -37.5 -36.0 -34.5 -33.0 -31.5 -30.0 -28.5 -27.0 -25.5 -24.0 -22.5 -21.0 -19.5 -18.0 -16.5 -15.0 -13.5 -12.0 -10.5 -9.0 -7.5 -6.0 -4.5 -3.0 -1.5 0.0 1.5 3.0 4.5 6.0 7.5 9.0 10.5 12.0 13.5 15.0 16.5 18.0 19.5 21.0 22.5 24.0 25.5 27.0 28.5 30.0 31.5 33.0 34.5 36.0 37.5 39.0 40.5 42.0 43.5 45.0 46.5 48.0 49.5 51.0 52.5 54.0 55.5 57.0 58.5 60.0 61.5 63.0 64.5 66.0 67.5 69.0 70.5 72.0 73.5 75.0 76.5 78.0 79.5 81.0 82.5 84.0 85.5 87.0 88.5]

  const int noiseTextureResolution = 256;
  cRCP(float, noiseTextureResolution);

  // OPTION FILES
  #include "/lib/option/Post.glsl"
  #include "/lib/option/Parallax.glsl"
  #include "/lib/option/Material.glsl"
  #include "/lib/option/Normals.glsl"
  #include "/lib/option/Shadows.glsl"
  #include "/lib/option/Lighting.glsl"
  #include "/lib/option/Debugging.glsl"
  #include "/lib/option/Water.glsl"
  #include "/lib/option/Volumetrics.glsl"
  #include "/lib/option/VolumetricClouds.glsl"

  // OPTIONS
  #define GLOBAL_SPEED 1.0 // Influences how fast the shader runs. All values are multiples of the normal speed. [0.08333 0.09090909 0.1 0.111 0.125 0.142857 0.1666 0.2 0.25 0.333 0.5 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0]
  #define frametime ( GLOBAL_SPEED * frameTimeCounter )

  #define TEXTURE_RESOLUTION 128.0 // [16.0 32.0 64.0 128.0 256.0 512.0 1024.0 2048.0 4096.0 8192.0]

  #define MC_SEA_LEVEL 63.0

  #define SUN_BRIGHTNESS 8192.0

  #define SUN_SIZE 0.25
  #define MOON_SIZE 1.0

  c(float) sunSpotSize = SUN_SIZE;
  cRCP(float, sunSpotSize);

  c(float) screenGammaCurve = GAMMA;
  cRCP(float, screenGammaCurve);

  c(float) actualSaturation = 1.0 - SATURATION;

  c(float) dynamicRangeFog = 48.0;
  cRCP(float, dynamicRangeFog);

  c(float) dynamicRangeShadow = 4.0;
  cRCP(float, dynamicRangeShadow);

  c(float) objectIDRange = 255.0;
  cRCP(float, objectIDRange);

  c(float) shadowDepthBlocks = 256.0;
  c(float) shadowDepthMult = 256.0 / shadowDepthBlocks;

#endif /* INTERNAL_INCLUDED_SETTINGS */
