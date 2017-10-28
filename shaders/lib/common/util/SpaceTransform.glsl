/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_UTIL_SPACETRANSFORM
  #define INTERNAL_INCLUDED_UTIL_SPACETRANSFORM

  float fovScale = gbufferProjection[1][1] * tan(atan(1.0 / gbufferProjection[1][1]) * 0.85);

  vec3 clipToView(in vec2 screenCoord, in float depth) {
    vec4 vpos = projMAD4(gbufferProjectionInverse, (vec3(screenCoord, depth) * 2.0 - 1.0).xyzz);
    vpos /= vpos.w;

    if(isEyeInWater == 1) vpos.xy *= fovScale;

    return vpos.xyz;
  }

  vec3 viewToClip(in vec3 view) {
    return projMAD3(gbufferProjection, view) / -view.z * 0.5 + 0.5;
  }

  vec3 viewToWorld(in vec3 view) {
    return transMAD(gbufferModelViewInverse, view);
  }

  vec3 worldToView(in vec3 view) {
    return transMAD(gbufferModelView, view);
  }

  #ifdef INTERNAL_INCLUDED_STRUCT_STRUCTPOSITION

    void populateFrontViewPosition(io PositionObject position, in vec2 screenCoord) {
      position.viewPositionFront = clipToView(screenCoord, position.depthFront);
    }

    void populateBackViewPosition(io PositionObject position, in vec2 screenCoord) {
      position.viewPositionBack = clipToView(screenCoord, position.depthBack);
    }

    void populateViewPositions(io PositionObject position, in vec2 screenCoord) {
      populateFrontViewPosition(position, screenCoord);
      populateBackViewPosition(position, screenCoord);
    }

  #endif

#endif /* INTERNAL_INCLUDED_UTIL_SPACETRANSFORM */
