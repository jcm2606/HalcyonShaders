/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_UTIL_TIME
    #define INCLUDED_UTIL_TIME

    vec4 CalculateTimeVector() {
        vec2 noonNight = vec2(
            0.25 - clamp(sunAngle, 0.0, 0.5),
            0.75 - clamp(sunAngle, 0.5, 1.0)
        );

        vec4 timeVector = vec4(0.0);

        // Noon.
        timeVector.x = 1.0 - saturate(pow(abs(noonNight.x) * 4.0, 2.0));

        // Night.
        timeVector.y = 1.0 - saturate(pow(abs(noonNight.y) * 4.0, 128.0));

        // Sunrise/Sunset.
        timeVector.z = 1.0 - (timeVector.x + timeVector.y);

        // Morning.
        timeVector.w = 1.0 - (
            (1.0 - saturate(pow(max0(noonNight.x) * 4.0, 2.0))) +
            (1.0 - saturate(pow(max0(noonNight.y) * 4.0, 128.0)))
        );

        return timeVector;
    }

#endif
