/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_SYNTAX_FUNCTIONS
  #define INTERNAL_INCLUDED_SYNTAX_FUNCTIONS

  #define toGamma_(type) type toGamma(type x) { return _pow(x, type(gammaCurveScreenRCP)); }
  DEFINE_genFType(toGamma_)

  #define toLinear_(type) type toLinear(type x) { return _pow(x, type(gammaCurveScreen)); }
  DEFINE_genFType(toLinear_)

  #define toLDR_(type) type toLDR(type x, const in float range) { return toLinear(x) * range; }
  DEFINE_genFType(toLDR_)

  #define toHDR_(type) type toHDR(type x, const in float range) { return toLinear(x) * range; }
  DEFINE_genFType(toHDR_)

  cv(vec3) lumaCoeff = vec3(0.2125, 0.7154, 0.0721);
  float luma(in vec3 x) { return dot(x, lumaCoeff); }
  #define _luma(x) ( dot(x, lumaCoeff) )

  vec3 saturation(in vec3 x, in float s) { return mix(x, vec3(dot(x, lumaCoeff)), s); }
  #define _saturation(x, s) ( mix(x, vec3(dot(x, lumaCoeff)), s) )
  
  bool compare(in float a, in float b, cin(float) width) { return abs(a - b) < width; }
  bool compare(in float a, in float b) { return abs(a - b) < ubyteMaxRCP; }

  float compareShadowDepth(in float depth, in float comparison) { return saturate(1.0 - _max0(comparison - depth) * float(shadowMapResolution)); }

  #define flatten_(type) type flatten(type x, const in float weight) { \
    const float a = 1.0 - weight; \
    return x * weight + a; \
  }
  DEFINE_genFType(flatten_)

  cv(float) ebsRCP = 1.0 / 240.0;
  #define _getEBS() ( eyeBrightnessSmooth * ebsRCP )

  float transmittedScatteringIntegral(in float od, cin(float) coeff) {
    cv(float) a = -coeff / log(2.0);
    cv(float) b = -1.0 / coeff;
    cv(float) c =  1.0 / coeff;

    return exp2(a * od) * b + c;
  }

  vec3 transmittedScatteringIntegral(in float od, cin(vec3) coeff) {
    cv(vec3) a = -coeff / log(2.0);
    cv(vec3) b = -1.0 / coeff;
    cv(vec3) c =  1.0 / coeff;

    return exp2(a * od) * b + c;
  }

#endif /* INTERNAL_INCLUDED_SYNTAX_FUNCTIONS */
