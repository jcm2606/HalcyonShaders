/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_GBUFFER_PARALLAXWATER
    #define INCLUDED_GBUFFER_PARALLAXWATER

    #include "/lib/common/WaterNormals.fsh"

    vec3 CalculateWaterParallax(vec3 worldPosition, vec3 viewDirection) {
        #ifndef PARALLAX_WATER
            return worldPosition;
        #endif

        const int   steps    = PARALLAX_WATER_STEPS;
        const float stepsRCP = rcp(steps);

        const float height = PARALLAX_WATER_HEIGHT;

        const float incrementLength = stepsRCP * 4.0;

        //viewDirection.xy = viewDirection.xy * fInverseLength(viewDirection) * incrementLength;

        float waveHeight = CalculateWaterHeight(worldPosition) * height;

        int i = steps;
        while(--i > 0) {
            worldPosition.xz = waveHeight * viewDirection.xy - worldPosition.xz;

            waveHeight = CalculateWaterHeight(worldPosition) * height;
        }

        return worldPosition;
    }

#endif
