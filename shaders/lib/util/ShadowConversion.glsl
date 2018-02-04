/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_UTIL_SHADOWCONVERSION
  #define INTERNAL_INCLUDED_UTIL_SHADOWCONVERSION

  mat4 shadowMVP = shadowProjection * shadowModelView;

  vec3 worldToShadow(in vec3 world) {
    vec3 shadow = _transMAD(shadowMVP, world);
    shadow.z *= shadowDepthMult;
    return shadow * 0.5 + 0.5;
  }

  vec2 distortShadowPosition(in vec2 shadow, cin(bool) rangeConversion) {
    cv(float) distortFactor = SHADOW_DISTORTION_FACTOR;
    cv(float) distortFactorInverse = 1.0 - distortFactor;

    if(rangeConversion) shadow = shadow * 2.0 - 1.0;

    shadow /= _length(shadow) * distortFactor + distortFactorInverse;

    if(rangeConversion) shadow = shadow * 0.5 + 0.5;
    
    return shadow;
  }

  vec3 distortShadowPosition(in vec3 shadow, cin(bool) rangeConversion) {
    return vec3(distortShadowPosition(shadow.xy, rangeConversion), shadow.z);
  }

#endif /* INTERNAL_INCLUDED_UTIL_SHADOWCONVERSION */
