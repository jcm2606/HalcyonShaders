/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_COMMON_ATMOSPHERELIGHTING
  #define INTERNAL_INCLUDED_COMMON_ATMOSPHERELIGHTING

  #ifndef INTERNAL_INCLUDED_COMMON_SKY
    #include "/lib/common/Sky.glsl"
  #endif

  mat2x3 getAtmosphereLighting() {
    mat2x3 atmosphereLighting = mat2x3(0.0);

    // DIRECT
    atmosphereLighting[0]  = drawSky(lightVector, 1) * 0.03;
    atmosphereLighting[0] *= mix(1.0, 0.3, rainStrength);

    // AMBIENT
    atmosphereLighting[1] = drawSky(upVector, 1) * 8.0;

    return atmosphereLighting;
  }

#endif /* INTERNAL_INCLUDED_COMMON_ATMOSPHERELIGHTING */
