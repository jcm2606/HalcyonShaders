/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_DEFERRED_CAMERA
    #define INCLUDED_DEFERRED_CAMERA

    // Exposure.
    #if PROGRAM == COMPOSITE1
        vec3 CalculateExposedImage(const vec3 image, const float averageLuma) {
            float exposure = EXPOSURE / (averageLuma * 6.0 + mix(0.001, 0.1, timeNight));

            return image * exposure;
        }
    #endif

#endif
