/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_COMMON_SKY
  #define INTERNAL_INCLUDED_COMMON_SKY

  #ifndef INTERNAL_INCLUDED_COMMON_ATMOSPHERE
    #include "/lib/common/Atmosphere.glsl"
  #endif

  vec3 drawSky(in vec3 view, in int mode) {
    vec3 sky = getAtmosphere(vec3(0.0), normalize(view), mode);

    return sky;
  }

#endif /* INTERNAL_INCLUDED_COMMON_SKY */
