/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_DEFERRED_TEMPORAL
  #define INTERNAL_INCLUDED_DEFERRED_TEMPORAL

  void getTemporalSmoothing(out float blend, in vec2 screenCoord) {
    // SMOOTHED LUMA
    cv(float) exposureSpeed = 0.5;
    cv(float) exposureBias = 0.75;
    cv(vec3) exposureBias3 = vec3(exposureBias);

    float smoothedLuma = mix(
      readFromTile(colortex3, TILE_TEMPORAL_SMOOTHED_LUMA, 5).a,
      _luma(_pow(max(vec3(0.0), texture2DLod(colortex0, vec2(0.5), 100).rgb), exposureBias3)),
      clamp(frameTime * exposureSpeed, 0.01, 0.99)
    );
    
    blend = (canWriteTo(screenCoord, TILE_TEMPORAL_SMOOTHED_LUMA, 5)) ? smoothedLuma : blend;

    // SMOOTHED CENTER DEPTH
    cv(float) centerDepthSpeed = 1.0;

    float smoothedCenterDepth = mix(
      readFromTile(colortex3, TILE_TEMPORAL_SMOOTHED_CENTER_DEPTH, 5).a,
      texture2D(depthtex1, vec2(0.5)).x,
      clamp(frameTime * centerDepthSpeed, 0.01, 0.99)
    );

    blend = (canWriteTo(screenCoord, TILE_TEMPORAL_SMOOTHED_CENTER_DEPTH, 5)) ? smoothedCenterDepth : blend;
  }

#endif /* INTERNAL_INCLUDED_DEFERRED_TEMPORAL */
