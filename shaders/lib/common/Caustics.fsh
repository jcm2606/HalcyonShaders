/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_COMMON_CAUSTICS
    #define INCLUDED_COMMON_CAUSTICS

    vec2 DistributeSamples(float i, float n) {
        float angle = pow(16, 2.0) * n * 0.5 * goldenAngle;
        vec2 p = sincos(i * angle);

        return p * (sqrt(i * 0.97 + 0.03) * sign(p.x));
    }

    float CalculateCaustics(vec3 worldPosition, vec2 dither) {
        #if CAUSTICS_MODEL < 2
            return 1.0;
        #endif

        const int   samples    = CAUSTICS_AREA_SAMPLES;
        const float samplesRCP = rcp(samples);

        const float radius = 1.0;
        const float defocus = 1.0;
        const float distanceThreshold = sqrt(samples / pi) / (radius * defocus);
        const float resultPower = 2.0;

        const float depthScale = 2.0;

        vec3 shadowPosition    = WorldToShadowPosition(worldPosition);
             shadowPosition.xy = DistortShadowPositionProj(shadowPosition.xy);

        vec3 shadowWorldPosition = transMAD(shadowModelView, worldPosition);

        float waterDepth = texture2D(shadowtex0, shadowPosition.xy).x * 8.0 - 4.0;
              waterDepth = waterDepth * shadowProjectionInverse[2].z + shadowProjectionInverse[3].z;
              waterDepth = shadowWorldPosition.z - waterDepth;
              waterDepth *= depthScale;

        if(waterDepth > 0.0)
            return 1.0;

        worldPosition += cameraPosition;

        vec4 shadowNormalCenter = texture2D(shadowcolor1, shadowPosition.xy);

        if(shadowNormalCenter.a < 0.5)
            return 1.0;

        vec3 lightVector = mat3(gbufferModelViewInverse) * -lightDirection;
        vec3 flatRefractVector = refract(lightVector, vec3(0.0, 1.0, 0.0), 0.75);
        float surfDistUp = waterDepth * abs(lightVector.y);
        dither.x *= samplesRCP;

        vec3 refractCorrection = flatRefractVector * (surfDistUp / flatRefractVector.y);
        vec3 surfacePosition = worldPosition - refractCorrection;

        float result = 0.0;
        for(int i = 0; i < samples; ++i) {
            vec3 samplePos = surfacePosition;
            samplePos.xz += DistributeSamples(i * samplesRCP + dither.x, samples);

            vec3 shadowPos = WorldToShadowPosition(samplePos - cameraPosition + refractCorrection);
            shadowPos.xy = DistortShadowPositionProj(shadowPos.xy);

            vec4 shadowNormal     = texture2D(shadowcolor1, shadowPos.xy);
                 shadowNormal.xyz = shadowNormal.xyz * 2.0 - 1.0;

            vec3 refractVector = refract(lightVector, shadowNormal.xyz, 0.75);
            
            samplePos = refractVector * (surfDistUp / refractVector.y) + samplePos;

            result += 1.0 - saturate(fDistance(worldPosition, samplePos) * distanceThreshold);
        }

        return pow(result / pow2(defocus), resultPower);
    }

#endif
