/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_COMMON_SKY
  #define INTERNAL_INCLUDED_COMMON_SKY

  #include "/lib/util/SpaceConversion.glsl"

  #include "/lib/common/Atmosphere.glsl"

  vec3 drawSky(in vec3 view, in int mode) {
    return getAtmosphere(vec3(0.0), normalize(view), mode);
  }

#endif /* INTERNAL_INCLUDED_COMMON_SKY */
