/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_UTIL_TIME
  #define INTERNAL_INCLUDED_UTIL_TIME

  void getTimeVector(io vec4 timeVector) {
    vec2 noonNight = vec2(
      0.25 - clamp(sunAngle, 0.0, 0.5),
      0.75 - clamp(sunAngle, 0.5, 1.0)
    );

    // NOON
    timeVector.x = 1.0 - saturate(_pow(abs(noonNight.x) * 4.0, 2.0));

    // NIGHT
    timeVector.y = 1.0 - saturate(_pow(abs(noonNight.y) * 4.0, 128.0));

    // SUNRISE/SUNSET
    timeVector.z = 1.0 - (timeVector.x + timeVector.y);

    // MORNING
    timeVector.w = 1.0 - ((1.0 - saturate(_pow(_max0(noonNight.x) * 4.0, 2.0))) + (1.0 - saturate(_pow(_max0(noonNight.y) * 4.0, 128.0))));
  }

#endif /* INTERNAL_INCLUDED_UTIL_TIME */
