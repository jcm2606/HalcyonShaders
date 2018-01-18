/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_COMMON_ATMOSPHERELIGHTING
  #define INTERNAL_INCLUDED_COMMON_ATMOSPHERELIGHTING

  #include "/lib/common/Atmosphere.glsl"

  mat2x3 getAtmosphereLighting() {
    mat2x3 atmosphereLighting = mat2x3(0.0);

    atmosphereLighting[0] = getLightColour(lightDirection) * ATMOS_LIGHTING_DIRECT_INTENSITY;

    atmosphereLighting[1] = getAtmosphere(vec3(0.0), upDirection, SKY_MODE_LIGHTING) * ATMOS_LIGHTING_SKY_INTENSITY;

    return atmosphereLighting;
  }

#endif /* INTERNAL_INCLUDED_COMMON_ATMOSPHERELIGHTING */
