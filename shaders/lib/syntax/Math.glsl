/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_SYNTAX_MATH
  #define INTERNAL_INCLUDED_SYNTAX_MATH

  #define saturate(x) clamp(x, 0.0, 1.0)

  #define max_(type) type _max(type x, type y) { return 0.5 * (x + y + abs(x - y)); }
  DEFINE_genFType(max_)

  #define min_(type) type _min(type x, type y) { return 0.5 * (x + y - abs(x - y)); }
  DEFINE_genFType(min_)

  #define _max0(x) _max(x, 0.0)
  #define _max1(x) _max(x, 1.0)
  #define _min0(x) _min(x, 0.0)
  #define _min1(x) _min(x, 1.0)

  #define _pow(x, y) exp2(log2((x)) * y)

  #define sqr_(type) type _sqr(type x) { return x * x; }
  DEFINE_genFType(sqr_)
  DEFINE_genIType(sqr_)

  #define lengthsqr_(type) float _lengthsqr(type x) { return dot(x, x); }
  DEFINE_genFType(lengthsqr_)

  #define length_(type) float _length(type x) { return sqrt(dot(x, x)); }
  DEFINE_genFType(length_)

  #define inverseLength_(type) float _inverseLength(type x) { return inversesqrt(dot(x, x)); }
  DEFINE_genFType(inverseLength_)

  #define normalize_(type) type _normalize(type x) { return x * _inverseLength(x); }
  DEFINE_genVType(normalize_)

  #define length8_(type) float length8(type x) { \
    x *= x; \
    x *= x; \
    return _pow(dot(x, x), 0.125); \
  }
  DEFINE_genFType(length8_)

  #define _distance(x, y) _length(x - y)
  #define _distanceRCP(x, y) _inverseLength(x - y)

  #define _transMAD(mat, v) (mat3(mat) * (v) + (mat)[3].xyz)

  #define _diagonal2(mat) vec2((mat)[0].x, (mat)[1].y)
  #define _diagonal3(mat) vec3(_diagonal2(mat), (mat)[2].z)
  #define _diagonal4(mat) vec4(_diagonal3(mat), (mat)[2].w)

  #define _projMAD3(mat, v) (_diagonal3(mat) * (v) + (mat)[3].xyz )
  #define _projMAD4(mat, v) (_diagonal4(mat) * (v) + (mat)[3].xyzw)

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

  vec2 rotatec(in vec2 vector, cin(float) rad) {
    cv(float) rad_c = cos(rad);
    cv(float) rad_s = sin(rad);
    return vector * mat2(rad_c, -rad_s, rad_s, rad_c);
  }
  vec2 rotate(in vec2 vector, in float rad) {
    return vector * mat2(cos(rad), -sin(rad), sin(rad), cos(rad));
  }

#endif /* INTERNAL_INCLUDED_SYNTAX_MATH */
