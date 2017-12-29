/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_DEFERRED_TEMPORALBLENDING
  #define INTERNAL_INCLUDED_DEFERRED_TEMPORALBLENDING

  void getTemporalBlending(out float blend, in vec2 screenCoord) {
    // AVERAGE LUMA
    cv(float) exposureSpeed = 0.5;
    cv(float) exposureBias = 0.65;
    cv(vec3) exposureBias3 = vec3(exposureBias);

    float prevLuma = readFromTile(colortex3, TILE_TEMPORAL_AVERAGE_LUMA, 5).a;
    float currLuma = getLuma(pow(texture2DLod(colortex0, vec2(0.5), 100).rgb, exposureBias3));
    float avgLuma = mix(prevLuma, currLuma, clamp(frameTime * exposureSpeed, 0.01, 0.99));

    blend = (canWriteTo(screenCoord, TILE_TEMPORAL_AVERAGE_LUMA, 5)) ? avgLuma : blend;

    // CENTER DEPTH
    cv(float) depthSpeed = 2.0;
    
    float prevDepth = readFromTile(colortex3, TILE_TEMPORAL_CENTER_DEPTH, 5).a;
    float currDepth = texture2D(depthtex0, vec2(0.5)).x;
    float centerDepth = mix(prevDepth, currDepth, clamp(frameTime * depthSpeed, 0.01, 0.99));

    blend = (canWriteTo(screenCoord, TILE_TEMPORAL_CENTER_DEPTH, 5)) ? centerDepth : blend;
  }

#endif /* INTERNAL_INCLUDED_DEFERRED_TEMPORALBLENDING */
