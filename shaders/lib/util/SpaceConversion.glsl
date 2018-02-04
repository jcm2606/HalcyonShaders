/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_UTIL_SPACECONVERSION
  #define INTERNAL_INCLUDED_UTIL_SPACECONVERSION

  float fovScale = gbufferProjection[1][1] * tan(atan(1.0 / gbufferProjection[1][1]) * 0.85);

  vec3 clipToView(in vec2 screenCoord, in float depth) {
    /*
    vec4 vpos = _projMAD4(gbufferProjectionInverse, (vec3(screenCoord, depth) * 2.0 - 1.0).xyzz);
    vpos /= vpos.w;

    if(underWater) vpos.xy *= fovScale;

    return vpos.xyz;
    */

    vec3 screen = vec3(screenCoord, depth) * 2.0 - 1.0;
    return _projMAD3(gbufferProjectionInverse, screen) / (screen.z * gbufferProjectionInverse[2].w + gbufferProjectionInverse[3].w) * vec3(vec2(mix(1.0, fovScale, float(isEyeInWater))), 1.0);
  }

  vec3 viewToClip(in vec3 view) {
    return _projMAD3(gbufferProjection, view) / -view.z * 0.5 + 0.5;
  }

  vec3 viewToWorld(in vec3 view) {
    return _transMAD(gbufferModelViewInverse, view);
  }

  #ifdef INTERNAL_INCLUDED_STRUCT_POSITION

    void populateFrontViewPosition(io PositionData positionData, in vec2 screenCoord) {
      positionData.viewFront = clipToView(screenCoord, positionData.depthFront);
    }

    void populateBackViewPosition(io PositionData positionData, in vec2 screenCoord) {
      positionData.viewBack = clipToView(screenCoord, positionData.depthBack);
    }

    void populateViewPositions(io PositionData positionData, in vec2 screenCoord) {
      populateFrontViewPosition(positionData, screenCoord);
      populateBackViewPosition(positionData, screenCoord);
    }

  #endif

#endif /* INTERNAL_INCLUDED_UTIL_SPACECONVERSION */
