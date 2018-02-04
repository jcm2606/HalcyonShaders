/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_DEFERRED_CAMERA
  #define INTERNAL_INCLUDED_DEFERRED_CAMERA

  vec3 getExposedFrame(in vec3 frame, in vec2 screenCoord) {
    return frame * (EXPOSURE / _max(readFromTile(colortex3, TILE_TEMPORAL_SMOOTHED_LUMA, 5).a, mix(0.1, 0.06, timeNight)));
  }

#endif /* INTERNAL_INCLUDED_DEFERRED_CAMERA */
