/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_UTIL_TIME
  #define INTERNAL_INCLUDED_UTIL_TIME

  vec4 getTimeVector() {
    vec4 vector = vec4(0.0);

    vec2 noonNight = vec2(
      (0.25 - clamp(sunAngle, 0.0, 0.5)),
      (0.75 - clamp(sunAngle, 0.5, 1.0))
    );

    // NOON
    vector.x = 1.0 - clamp01(pow2(abs(noonNight.x) * 4.0));
    // NIGHT
    vector.y = 1.0 - clamp01(pow(abs(noonNight.y) * 4.0, 128.0));
    // SUNRISE/SUNSET
    vector.z = 1.0 - (vector.x + vector.y);
    // MORNING
    vector.w = 1.0 - ((1.0 - clamp01(pow2(max0(noonNight.x) * 4.0))) + (1.0 - clamp01(pow(max0(noonNight.y) * 4.0, 128.0))));

    return vector;
  }
  
#endif /* INTERNAL_INCLUDED_UTIL_TIME */
