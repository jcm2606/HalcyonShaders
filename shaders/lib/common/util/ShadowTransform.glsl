/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_UTIL_SHADOWTRANSFORM
  #define INTERNAL_INCLUDED_UTIL_SHADOWTRANSFORM

  mat4 shadowMVP = shadowProjection * shadowModelView;

  vec3 worldToShadow(in vec3 world) {
    vec3 shadow = transMAD(shadowMVP, world);
    shadow.z *= shadowDepthMult;
    shadow = shadow * 0.5 + 0.5;
    return shadow;
  }

  cv(float) distortFactor = SHADOW_DISTORTION_FACTOR;
  cv(float) distortFactorInverse = 1.0 - distortFactor;

  vec2 distortShadowPosition(in vec2 shadow, in int rangeConversion) {
    shadow = (rangeConversion == 0) ? shadow : shadow * 2.0 - 1.0;

    shadow /= flength(shadow) * distortFactor + distortFactorInverse;

    shadow = (rangeConversion == 0) ? shadow : shadow * 0.5 + 0.5;

    return shadow;
  }

#endif /* INTERNAL_INCLUDED_UTIL_SHADOWTRANSFORM */
