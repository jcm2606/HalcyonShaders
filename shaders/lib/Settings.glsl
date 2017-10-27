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
    const int colortex3Format = RGBA16;
    const int colortex4Format = RGBA16F;
    const int colortex5Format = RGBA16;

    const bool colortex3Clear = false;
  */

  // OPTIFINE OPTIONS
  const int shadowMapResolution = 2048; // [512 1024 2048 3072 4096 8192]

  // OPTION FILES
  #include "/lib/option/Post.glsl"
  #include "/lib/option/Parallax.glsl"

  // OPTIONS
  #define TEXTURE_RESOLUTION 128.0 // [16.0 32.0 64.0 128.0 256.0 512.0 1024.0 2048.0 4096.0 8192.0]

  c(float) screenGammaCurve = GAMMA;
  cRCP(float, screenGammaCurve);

  c(float) actualSaturation = 1.0 - SATURATION;

  c(float) dynamicRangeFog = 48.0;
  cRCP(float, dynamicRangeFog);

  c(float) dynamicRangeShadow = 4.0;
  cRCP(float, dynamicRangeShadow);

#endif /* INTERNAL_INCLUDED_SETTINGS */
