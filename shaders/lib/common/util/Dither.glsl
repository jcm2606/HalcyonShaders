/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_UTIL_DITHER
  #define INTERNAL_INCLUDED_UTIL_DITHER

  float bayer2(vec2 a){
    a = floor(a);
    return fract( dot(a, vec2(.5, a.y * .75)) );
  }
  #define bayer4(a)   (bayer2( .5*(a))*.25+bayer2(a))
  #define bayer8(a)   (bayer4( .5*(a))*.25+bayer2(a))
  #define bayer16(a)  (bayer8( .5*(a))*.25+bayer2(a))
  #define bayer32(a)  (bayer16(.5*(a))*.25+bayer2(a))
  #define bayer64(a)  (bayer32(.5*(a))*.25+bayer2(a))
  #define bayer128(a) (bayer64(.5*(a))*.25+bayer2(a))

#endif /* INTERNAL_INCLUDED_UTIL_DITHER */
