/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_UTIL_SPACETRANSFORM
    #define INCLUDED_UTIL_SPACETRANSFORM
    
    vec3 ClipToViewPosition(const vec2 screenCoord, const float depth) {
        vec3 screenPosition = vec3(screenCoord, depth) * 2.0 - 1.0;

        return projMAD3(gbufferProjectionInverse, screenPosition) / (screenPosition.z * gbufferProjectionInverse[2].w + gbufferProjectionInverse[3].w);
    }

    vec3 ViewToClipPosition(const vec3 viewPosition) {
        return projMAD3(gbufferProjection, viewPosition) / -viewPosition.z * 0.5 + 0.5;
    }

    vec3 ViewToWorldPosition(const vec3 viewPosition) {
        return transMAD(gbufferModelViewInverse, viewPosition);
    }

    vec4 ProjectViewPosition(vec3 viewPosition) {
        return vec4(projMAD3(gbufferProjection, viewPosition), viewPosition.z * gbufferProjection[2].w);
    }

#endif
