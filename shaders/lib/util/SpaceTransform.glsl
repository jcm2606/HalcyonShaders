/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_UTIL_SPACETRANSFORM
    #define INCLUDED_UTIL_SPACETRANSFORM

    #include "/lib/util/Matrix.glsl"

    vec3 ClipToViewPosition(const vec2 screenCoord, const float depth) {
        vec3 screenPosition = vec3(screenCoord, depth) * 2.0 - 1.0;

        return projMAD3(projMatrixInverse, screenPosition) / (screenPosition.z * projMatrixInverse[2].w + projMatrixInverse[3].w);
    }

    vec3 ViewToClipPosition(const vec3 viewPosition) {
        return (projMAD3(projMatrix, viewPosition) / -viewPosition.z) * 0.5 + 0.5;
    }

    vec3 ViewToWorldPosition(const vec3 viewPosition) {
        return transMAD(gbufferModelViewInverse, viewPosition);
    }

    vec4 ProjectViewPosition(vec3 viewPosition) {
        return vec4(projMAD3(projMatrix, viewPosition), viewPosition.z * projMatrix[2].w);
    }

    float ClipToViewDepth(float clipDepth) {
        clipDepth = clipDepth * 2.0 - 1.0;
        vec2 x = projMatrixInverse[2].zw * clipDepth + projMatrixInverse[3].zw;

        return x.x / x.y;
    }

#endif
