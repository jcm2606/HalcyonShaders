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

  #include "/lib/common/util/Noise.glsl"

  vec3 getStars(in vec3 view) {
    #define move (frametime * vec3(1.0, 0.0, 0.0)) * 0.001

    vec3 world = (move + normalize(viewToWorld(view))) * 128.0;

    return vec3(0.5) * pow16(simplex3D(world));

    #undef move
  }

  vec3 drawSky(in vec3 view, in int mode) {
    vec3 sky = getAtmosphere(getStars(view), normalize(view), mode);

    return sky;
  }

#endif /* INTERNAL_INCLUDED_COMMON_SKY */
