/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_COMMON_ATMOSPHERE
    #define INCLUDED_COMMON_ATMOSPHERE

    const float atmosphereHeight = 8000.0;
    const float earthRadius = 6371000.0;
    const float mieMultiplier = 1.3;
    const float ozoneMultiplier = 1.0;
    const float rayleighDistribution = 8.0;
    const float rayleighDistributionRCP = rcp(rayleighDistribution);
    const float mieDistribution = 1.8;
    const vec3  rayleighCoeff = vec3(5.8e-6, 1.35e-5, 3.31e-5);
    const vec3  ozoneCoeff = vec3(3.426, 8.298, 0.356) * 6.0e-5 / 100.0;
    const float mieCoeff = 3.0e-6 * mieMultiplier;

    const vec3 moonColour = saturationMod(vec3(0.0, 0.0, 1.0), 0.06);

    vec2 GetSkyThickness(vec3 direction) {
        vec2 sr = earthRadius + vec2(atmosphereHeight, atmosphereHeight * mieDistribution * rayleighDistributionRCP);

        vec3 ro = -viewDirectionUp * earthRadius;

        float b = dot(direction, ro);

        return b + sqrt(sr * sr + (b * b - dot(ro, ro)));
    }

    #define getEarth(x) ( smoothstep(-0.1, 0.1, dot(viewDirectionUp, x)) )
    #define phaseRayleigh(x) ( 0.4 * x + 1.14 )

    float PhaseMie(float x) {
        const vec3 c = vec3(0.25609, 0.132268, 0.010016);
        const vec3 d = vec3(-1.5, -1.74, -1.98);
        const vec3 e = vec3(1.5625, 1.7569, 1.9801);

        return dot((x * x + 1.0) * c * pow(d * x + e, -vec3(1.5)), vec3(0.33333));
    }

    vec3 Absorb(vec2 a) {
        return exp(-a.x * (ozoneCoeff * ozoneMultiplier + rayleighCoeff) - 1.11 * a.y * mieCoeff);
    }

    vec3 CalculateLightScatter(vec3 direction) {
        return Absorb(GetSkyThickness(direction)) * getEarth(direction) * ((sunAngle <= 0.5) ? vec3(LIGHT_SUN_INTENSITY) : LIGHT_MOON_INTENSITY * moonColour);
    }

    float GetBodyMask(float VoL, const float sizeDegrees) {
        return step(pi - radians(sizeDegrees), acos(-VoL));
    }

    vec3 CalculateScatter(vec3 space, vec3 viewDirection, int mode) {
        const int steps = 8;
        const float stepsRCP = rcp(steps);

        vec2 thickness = GetSkyThickness(viewDirection) * stepsRCP;

        float VoS = dot(viewDirection, sunDirection);
        float VoM = dot(viewDirection, moonDirection);

        vec3 viewAbsorb = Absorb(thickness);
        vec4 scatterCoeff = 1.0 - exp(-thickness.xxxy * vec4(rayleighCoeff, mieCoeff));

        vec3 scatterS = scatterCoeff.xyz * phaseRayleigh(VoS) + (scatterCoeff.w * PhaseMie((mode > 0) ? 0.0 : VoS));
        vec3 scatterM = scatterCoeff.xyz * phaseRayleigh(VoM) + (scatterCoeff.w * PhaseMie((mode > 0) ? 0.0 : VoM));

        const float sunScatterIntensity = LIGHT_SUN_INTENSITY * 0.05;
        const float moonScatterIntensity = LIGHT_MOON_INTENSITY * 0.05;

        vec3 absorbS = Absorb(GetSkyThickness(sunDirection) * stepsRCP) * getEarth(sunDirection) * sunScatterIntensity;
        vec3 absorbM = Absorb(GetSkyThickness(moonDirection) * stepsRCP) * getEarth(moonDirection) * moonScatterIntensity;

        const float sunSpotIntensity = LIGHT_SUN_INTENSITY * SUN_SPOT_MULTIPLIER;
        const vec3 moonSpotIntensity = LIGHT_MOON_INTENSITY * MOON_SPOT_MULTIPLIER * moonColour;

        vec3 skyS = (vec3(float(mode == 0)) * GetBodyMask(VoS, SUN_SIZE)) * sunSpotIntensity + space;
        vec3 skyM = (vec3(float(mode == 0)) * GetBodyMask(VoM, MOON_SIZE)) * moonSpotIntensity + space;

        for(int i = 0; i < steps; ++i) {
            scatterS *= absorbS;
            scatterM *= absorbM;

            skyS = skyS * viewAbsorb + scatterS;
            skyM = skyM * viewAbsorb + scatterM;
        }

        return skyS + skyM;
    }

    mat2x3 CalculateAtmosphereLighting() {
        return mat2x3(
            CalculateLightScatter(lightDirection),
            CalculateScatter(vec3(0.0), viewDirectionUp, 1) * 2.0
        );
    }

#endif
