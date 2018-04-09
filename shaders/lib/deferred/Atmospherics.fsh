/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_DEFERRED_ATMOSPHERICS
    #define INCLUDED_DEFERRED_ATMOSPHERICS

    #include "/lib/util/ShadowTransform.glsl"

    // Layers.
    struct AtmosphereLayerRayleighMie {
        mat2x3 scatterCoeff;
        mat2x3 transmittanceCoeff;
    };

    struct AtmosphereLayerMie {
        vec3 scatterCoeff;
        vec3 transmittanceCoeff;
    };

    const AtmosphereLayerRayleighMie atmosphericsLayerAir = AtmosphereLayerRayleighMie(
        mat2x3(rayleighCoeff, vec3(mieCoeff)),
        mat2x3(rayleighCoeff + ozoneCoeff, vec3(mieCoeff) * 1.11)
    );

    const AtmosphereLayerMie atmospericsLayerFog = AtmosphereLayerMie(
        fogScatterCoeff,
        fogTransmittanceCoeff
    );

    const AtmosphereLayerMie atmosphericsLayerWater = AtmosphereLayerMie(
        waterScatterCoeff,
        waterTransmittanceCoeff
    );

    #define partialWaterAbsorption \
        ( (!isBackPass && underWater) ? exp2(-atmosphericsLayerWater.transmittanceCoeff * ATMOSPHERICS_WATER_DENSITY * distFront) : vec3(1.0) )

    // Layer Functions.
    void CalculateLayerContribution(const AtmosphereLayerRayleighMie atmosphereLayer, io vec3 scatter, io vec3 absorb, mat2x3 light, vec3 existingAbsorb, vec3 phase, float opticalDepth, float distFront, bool isBackPass) {
        mat2x3 scatterCoeff = mat2x3(
            atmosphereLayer.scatterCoeff[0] * TransmittedScatteringIntegral(opticalDepth, atmosphereLayer.transmittanceCoeff[0]),
            atmosphereLayer.scatterCoeff[1] * TransmittedScatteringIntegral(opticalDepth, atmosphereLayer.transmittanceCoeff[1])
        );

        light[0] = light[0] * (scatterCoeff * phase.xy);
        light[1] = light[1] * (scatterCoeff * phase.zz);

        scatter += (light[0] + light[1]) * absorb * existingAbsorb * partialWaterAbsorption;
        absorb  *= exp2(-atmosphereLayer.transmittanceCoeff * vec2(opticalDepth));
    }

    void CalculateLayerContribution(const AtmosphereLayerMie atmosphereLayer, io vec3 scatter, io vec3 absorb, mat2x3 light, vec3 existingAbsorb, vec2 phase, float opticalDepth, float distFront, bool isBackPass) {
        vec3 scatterCoeff = atmosphereLayer.scatterCoeff * TransmittedScatteringIntegral(opticalDepth, atmosphereLayer.transmittanceCoeff);

        light[0] = light[0] * scatterCoeff * phase.x;
        light[1] = light[1] * scatterCoeff * phase.y;

        scatter += (light[0] + light[1]) * absorb * existingAbsorb * partialWaterAbsorption;
        absorb  *= exp2(-atmosphereLayer.transmittanceCoeff * opticalDepth);
    }

    // Lighting Function.
    void CalculateVolumeLighting(io vec2 visibility, io vec3 shadowColour, io float materialID, io bool isTransparentShadow, vec3 shadowPosition, vec3 worldPosition, bool isSkyPixel, bool isWaterPixel) {
        shadowPosition.xy = DistortShadowPositionProj(shadowPosition.xy);

        float depthFront = texture2D(shadowtex0, shadowPosition.xy).x;

        visibility.x = float(texture2D(shadowtex1, shadowPosition.xy).x > shadowPosition.z);
        visibility.y = float(depthFront > shadowPosition.z);

        if(isSkyPixel && ( any(greaterThan(shadowPosition.xy, vec2(1.0))) || any(lessThan(shadowPosition.xy, vec2(0.0))) ))
            visibility = vec2(1.0);

        shadowColour = vec3(1.0);

        isTransparentShadow = visibility.y - visibility.x > 0.0;

        if(!isWaterPixel)
            return;

        float waterDepth = depthFront * 8.0 - 4.0;
              waterDepth = waterDepth * shadowProjectionInverse[2].z + shadowProjectionInverse[3].z;
              waterDepth = (transMAD(shadowModelView, worldPosition)).z - waterDepth;

        if(waterDepth < 0.0)
            shadowColour *= exp2(atmosphericsLayerWater.transmittanceCoeff * ATMOSPHERICS_WATER_DENSITY * waterDepth);
    }

    // Optical Depth Functions.
    float OpticalDepthAir(vec3 worldPosition) {
        return exp(-worldPosition.y * rcp(ATMOSPHERICS_AIR_HEIGHT)) * ATMOSPHERICS_AIR_DENSITY;
    }

    // Volume Function.
    // This returns the raw scatter and absorb values in a matrix, which is useful if you need them to render another layer of atmospherics.
    mat2x3 CalculateAtmosphericsVolume(mat2x3 atmosphereLighting, vec3 start, vec3 end, vec3 existingAbsorb, vec2 screenCoord, vec2 dither, float VoL, float distFront, bool isBackPass, bool isSkyPixel, bool isWaterPixel, bool isTransparentPixel) {
        #ifndef ATMOSPHERICS
            return mat2x3(vec3(0.0), vec3(1.0));
        #endif

        const int   steps    = ATMOSPHERICS_STEPS;
        const float stepsRCP = rcp(steps);

        vec3 scatter = vec3(0.0);
        vec3 absorb  = vec3(1.0);

        const vec2 phaseWater = vec2(1.0, PhaseG0());
        vec3 phaseAir = vec3(phaseRayleigh(VoL), PhaseG(VoL, 0.8) + PhaseG(VoL, -0.8), PhaseG0());

        vec3 worldStep     = (end - start) * stepsRCP;
        vec3 worldPosition = worldStep * dither.x + start;

        float stepSize = fLength(worldStep);
        
        vec3 shadowStart    = WorldToShadowPosition(start);
        vec3 shadowEnd      = WorldToShadowPosition(end);
        vec3 shadowStep     = (shadowEnd - shadowStart) * stepsRCP;
        vec3 shadowPosition = shadowStep * dither.x + shadowStart;
        
        const float shadowBias = 2.5e-1 * shadowMapResolutionRCP;
        shadowPosition.z -= shadowBias;

        worldPosition += cameraPosition;

        for(int i = 0; i < steps; ++i, worldPosition += worldStep, shadowPosition += shadowStep) {
            // Lighting.
            mat2x3 light = atmosphereLighting; // 0 = directLight, 1 = skyLight

            vec3 shadowColour = vec3(0.0);
            vec2 visibility = vec2(0.0); // x = visibilityBack, y = visibilityFront
            float materialID = 0.0;
            bool isTransparentShadow = false;

            CalculateVolumeLighting(visibility, shadowColour, materialID, isTransparentShadow, shadowPosition, worldPosition - cameraPosition, isSkyPixel, isWaterPixel);

            light[0] *= shadowColour * visibility.x;
            light[1] *= shadowColour * visibility.x;

            // TODO: Atmospherics lighting.

            // Layers.
            // Water.
            if(isWaterPixel) {
                CalculateLayerContribution(atmosphericsLayerWater, scatter, absorb, light, existingAbsorb, phaseWater, ATMOSPHERICS_WATER_DENSITY * stepSize, distFront, isBackPass);
            }

            if(isBackPass && isWaterPixel)
                continue;

            // Air.
            CalculateLayerContribution(atmosphericsLayerAir, scatter, absorb, light, existingAbsorb, phaseAir, OpticalDepthAir(worldPosition) * stepSize, distFront, isBackPass);
        }

        return mat2x3(scatter, absorb);
    }

    // Interaction Function.
    vec3 CalculateAtmosphericsInteraction(mat2x3 atmosphereLighting, vec3 background, vec3 start, vec3 end, vec3 existingAbsorb, vec2 screenCoord, vec2 dither, float VoL, float distFront, bool isBackPass, bool isSkyPixel, bool isWaterPixel, bool isTransparentPixel) {
        #ifndef ATMOSPHERICS
            return background;
        #endif

        mat2x3 volume = CalculateAtmosphericsVolume(atmosphereLighting, start, end, existingAbsorb, screenCoord, dither, VoL, distFront, isBackPass, isSkyPixel, isWaterPixel, isTransparentPixel);

        return background * volume[1] + volume[0];
    }

#endif
