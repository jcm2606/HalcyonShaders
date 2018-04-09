/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_UTIL_SHADOWTRANSFORM
    #define INCLUDED_UTIL_SHADOWTRANSFORM

    vec3 WorldToShadowPosition(const vec3 worldPosition) {
        vec3 shadowPosition    = transMAD(shadowModelView, worldPosition);
             shadowPosition    = projMAD3(shadowProjection, shadowPosition);
             shadowPosition.z *= shadowDepthMult;

        return shadowPosition * 0.5 + 0.5;
    }

    vec2 DistortShadowPosition(const vec2 shadowPosition) {
        return shadowPosition / (length(shadowPosition) * SHADOW_DISTORTION_FACTOR + (1.0 - SHADOW_DISTORTION_FACTOR));
    }

    vec2 DistortShadowPositionProj(vec2 shadowPosition) {
        shadowPosition  = shadowPosition * 2.0 - 1.0;
        shadowPosition /= length(shadowPosition) * SHADOW_DISTORTION_FACTOR + (1.0 - SHADOW_DISTORTION_FACTOR);
        shadowPosition  = shadowPosition * 0.5 + 0.5;

        return shadowPosition;
    }

#endif
