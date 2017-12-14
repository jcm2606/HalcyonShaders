/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_DEFERRED_CAMERA
  #define INTERNAL_INCLUDED_DEFERRED_CAMERA

  vec3 getExposedFrame(out float averageLuma, in vec3 frame, in vec2 screenCoord) {
    cv(float) speed = 0.5;
    cv(float) bias = 0.65;
    cv(vec3) bias3 = vec3(bias);

    float prevLuma = readFromTile(colortex3, TILE_TEMPORAL_AVERAGE_LUMA, 5).a;
    float currLuma = getLuma(pow(texture2DLod(colortex0, vec2(0.5), 100).rgb, bias3));
    float avgLuma = mix(prevLuma, currLuma, clamp(frameTime * speed, 0.01, 0.99));

    averageLuma = writeToTile(avgLuma, prevLuma, screenCoord, TILE_TEMPORAL_AVERAGE_LUMA, 5);

    return frame * (EXPOSURE / max(avgLuma, mix(0.00001, 0.06, timeNight)));
  }

  vec3 cameraExposure(out float averageLuma, in vec3 frame, in vec2 screenCoord) {
    float prevLuma = texture2D(colortex3, screenCoord).a;
    float currLuma = getLuma(pow(texture2DLod(colortex0, vec2(0.5), 100).rgb, vec3(0.65)));
    float avgLuma = mix(prevLuma, currLuma, clamp(frameTime * 0.5, 0.01, 0.99));

    averageLuma = avgLuma;

    return frame * (EXPOSURE / max(avgLuma, mix(0.00001, 0.06, timeNight)));
  }
  
#endif /* INTERNAL_INCLUDED_DEFERRED_CAMERA */
