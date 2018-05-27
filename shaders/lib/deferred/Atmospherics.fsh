/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_DEFERRED_ATMOSPHERICS
    #define INCLUDED_DEFERRED_ATMOSPHERICS

    #include "/lib/util/ShadowTransform.glsl"

    #include "/lib/util/Noise.glsl"

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

    const AtmosphereLayerMie atmosphericsLayerFog = AtmosphereLayerMie(
        fogScatterCoeff,
        fogTransmittanceCoeff
    );

    const AtmosphereLayerMie atmosphericsLayerWater = AtmosphereLayerMie(
        waterScatterCoeff,
        waterTransmittanceCoeff
    );

    const vec3 waterAbsorption = atmosphericsLayerWater.transmittanceCoeff * ATMOSPHERICS_WATER_DENSITY;

    #define partialWaterAbsorption \
        ( (!isBackPass && underWater) ? exp2(-waterAbsorption * distFront) : vec3(1.0) )

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
    void CalculateVolumeLighting(io vec2 visibility, io vec3 shadowColour, io float materialID, io bool isTransparentShadow, vec3 shadowPosition, vec3 worldPosition, vec2 dither, bool isSkyPixel, bool isWaterPixel) {
        shadowPosition.xy = DistortShadowPositionProj(shadowPosition.xy);

        float depthFront = texture2D(shadowtex0, shadowPosition.xy).x;

        visibility.x = float(texture2D(shadowtex1, shadowPosition.xy).x > shadowPosition.z);
        visibility.y = float(depthFront > shadowPosition.z);

        #if CAUSTICS_MODEL == 3
            visibility.x *= CalculateCaustics(worldPosition, dither);
        #endif

        if(isSkyPixel && ( any(greaterThan(shadowPosition.xy, vec2(1.0))) || any(lessThan(shadowPosition.xy, vec2(0.0))) ))
            visibility = vec2(1.0);

        shadowColour = vec3(1.0);

        isTransparentShadow = visibility.x - visibility.y > 0.0;

        if(!isTransparentShadow)
            return;

        vec4 shadowColourSample = texture2D(shadowcolor0, shadowPosition.xy);
        shadowColour = ToLinear(DecodeShadow(shadowColourSample.rgb)) * shadowColourSample.a;

        if(!isWaterPixel)
            return;

        float waterDepth = depthFront * 8.0 - 4.0;
              waterDepth = waterDepth * shadowProjectionInverse[2].z + shadowProjectionInverse[3].z;
              waterDepth = (transMAD(shadowModelView, worldPosition)).z - waterDepth;

        if(waterDepth < 0.0) {
            //shadowColour = min(pow(shadowColour, vec3(max(1.0e-3, abs(waterDepth) * 0.5))), 1000.0) * exp2(waterDepth * 0.7);
            shadowColour *= exp2(waterAbsorption * waterDepth);
        }
    }

    // Optical Depth Functions.
    float OpticalDepthAir(vec3 worldPosition) {
        const float height = rcp(ATMOSPHERICS_AIR_HEIGHT);

        return exp(-worldPosition.y * height) * ATMOSPHERICS_AIR_DENSITY;
    }

    float OpticalDepthFog(vec3 worldPosition) {
        float opticalDepth = 0.0;

        float seaLevelHeight = worldPosition.y - SEA_LEVEL;

        #ifdef ATMOSPHERICS_HEIGHT_FOG
            opticalDepth += exp(-worldPosition.y / ATMOSPHERICS_HEIGHT_FOG_HEIGHT) * ATMOSPHERICS_HEIGHT_FOG_DENSITY;
        #endif

        #ifdef ATMOSPHERICS_MIST_FOG
            opticalDepth += exp(-max0(seaLevelHeight) / ATMOSPHERICS_MIST_FOG_HEIGHT) * ATMOSPHERICS_MIST_FOG_DENSITY;
        #endif
        
        #ifdef ATMOSPHERICS_GROUND_FOG
            #ifdef ATMOSPHERICS_GROUND_FOG_ROLLING
                const float rotAmount = cRadians(30.0);
                cRotateMat2(rotAmount, rot);

                const vec2 move = vec2(-1.0, 0.0) * 0.4;
                vec2 movement = move * TIME;

                vec3 groundFogPosition    = worldPosition * 0.8;

                float groundFogNoise  = 0.0;

                      groundFogPosition.xz *= rot;
                      groundFogNoise += noise3D(groundFogPosition + movement.xyy);

                      groundFogPosition.zy *= rot;
                      groundFogNoise += noise3D(groundFogPosition * 2.0 + movement.xxy * 2.0) * 0.5;

                      groundFogPosition.xz *= rot;
                      groundFogNoise += noise3D(groundFogPosition * 4.0 + movement.yxy * 4.0) * 0.25;

                      groundFogPosition.zy *= rot;
                      groundFogNoise += noise3D(groundFogPosition * 8.0 + movement.yxx * 8.0) * 0.125;

                      groundFogPosition.xz *= rot;
                      groundFogNoise += noise3D(groundFogPosition * 16.0 + movement.xxx * 16.0) * 0.0625;

                      groundFogNoise *= 0.3;
                      groundFogNoise -= 0.17;
                      groundFogNoise  = max0(groundFogNoise);
            #else
                const float groundFogNoise = 0.25;
            #endif

            opticalDepth += exp(-abs(seaLevelHeight) / ATMOSPHERICS_GROUND_FOG_HEIGHT) * fogGroundDensity * groundFogNoise;
        #endif

        #ifdef ATMOSPHERICS_RAIN_FOG
            if(rainStrength > 0.01)
                opticalDepth += saturate(exp(-worldPosition.y / ATMOSPHERICS_RAIN_FOG_HEIGHT)) * ATMOSPHERICS_RAIN_FOG_DENSITY * rainStrength;
        #endif

        #ifdef ATMOSPHERICS_NIGHT_FOG
            opticalDepth += saturate(exp(-worldPosition.y / ATMOSPHERICS_HEIGHT_FOG_HEIGHT)) * ATMOSPHERICS_NIGHT_FOG_DENSITY * timeNight;
        #endif

        return opticalDepth;
    }

    // Volume Function.
    // This returns the raw scatter and absorb values in a matrix, which is useful if you need them to render another layer of atmospherics.
    mat2x3 CalculateAtmosphericsVolume(mat2x3 atmosphereLighting, vec3 start, vec3 end, vec3 existingAbsorb, vec2 screenCoord, vec2 dither, float VoL, float distFront, bool isBackPass, bool isSkyPixel, bool isWaterPixel, bool isTransparentPixel) {
        #ifndef ATMOSPHERICS
            return mat2x3(vec3(0.0), vec3(1.0));
        #endif

        #ifndef VOLUMETRICS
            return mat2x3(vec3(0.0), vec3(1.0));
        #endif

        const int   steps    = ATMOSPHERICS_STEPS;
        const float stepsRCP = rcp(steps);

        if(isBackPass && underWater)
            existingAbsorb = vec3(1.0);

        vec3 scatter = vec3(0.0);
        vec3 absorb  = vec3(1.0);

        vec2 phaseWater = vec2(PhaseG(VoL, 0.8) * 4.0 + 1.0, PhaseG0());
        vec3 phaseAir = vec3(phaseRayleigh(VoL), PhaseG(VoL, 0.8) + PhaseG(VoL, -0.8), PhaseG0());
        vec2 phaseFog = vec2(PhaseG(VoL, 0.8) + PhaseG(VoL, -0.8) + PhaseG(VoL, 0.2), 1.0);

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

            CalculateVolumeLighting(visibility, shadowColour, materialID, isTransparentShadow, shadowPosition, worldPosition - cameraPosition, dither, isSkyPixel, isWaterPixel);

            light[0] *= shadowColour * visibility.x * CalculateCloudShadow(worldPosition, lightDirectionWorld, CLOUDS_SHADOW_DENSITY_MULT);
            light[1] *= shadowColour;

            #if   ATMOSPHERICS_LIGHTING_SKY_SHADOW == 0
                light[1] *= float(!isWaterPixel);
            #elif ATMOSPHERICS_LIGHTING_SKY_SHADOW == 1
                light[1] *= visibility.x;                
            #endif

            // Layers.
            // Water.
            #ifdef ATMOSPHERICS_WATER
                if(isWaterPixel)
                    CalculateLayerContribution(atmosphericsLayerWater, scatter, absorb, light, existingAbsorb, phaseWater, ATMOSPHERICS_WATER_DENSITY * stepSize, distFront, isBackPass);
            #endif

            if(isBackPass && isWaterPixel)
                continue;

            // Air.
            #ifdef ATMOSPHERICS_AIR
                CalculateLayerContribution(atmosphericsLayerAir, scatter, absorb, light, existingAbsorb, phaseAir, OpticalDepthAir(worldPosition) * stepSize, distFront, isBackPass);
            #endif

            // Fog.
            #ifdef ATMOSPHERICS_FOG
                CalculateLayerContribution(atmosphericsLayerFog, scatter, absorb, light, existingAbsorb, phaseFog, OpticalDepthFog(worldPosition) * stepSize, distFront, isBackPass);
            #endif
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
