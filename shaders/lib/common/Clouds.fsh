/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_COMMON_CLOUDS
    #define INCLUDED_COMMON_CLOUDS

    #include "/lib/util/Noise.glsl"

    const float cloudMinAltitude = CLOUDS_ALTITUDE;
    const float cloudHeight = CLOUDS_HEIGHT;
    const float cloudMidAltitude = cloudMinAltitude + cloudHeight * 0.5;
    const float cloudMaxAltitude = cloudMinAltitude + cloudHeight;
    const float cloudScale = (2048.0 / cloudMinAltitude) * 0.0003 * CLOUDS_SCALE;

    const vec3 cloudMaterial = vec3(0.02, 0.05, 0.05) / log(2.0); // (Scatter, View Absorb, Light Absorb)

    float CloudFBM(vec3 worldPosition) {
        float opticalDepth = 0.0;

        float rounding = pow(1.0 - abs(((worldPosition.y - cloudMinAltitude) / cloudHeight) * 2.0 - 1.0), 0.125);

        worldPosition *= cloudScale;

        const float rotAmount = cRadians(97.0);
        cRotateMat2(rotAmount, rot);

        const vec2 windDirection = vec2(-1.0, 0.0) * 0.07 * CLOUDS_SPEED;
        vec3 movement = windDirection.xyy * TIME;

        float weight = 1.0;

        for(int i = 0; i < CLOUDS_DETAIL; ++i) {
            opticalDepth += noise3D(worldPosition + movement) * weight;

            worldPosition *= 2.4;
            worldPosition.xy *= rot;
            worldPosition.zy *= rot;
            movement *= 1.4;
            weight *= 0.5;
        }

        opticalDepth -= mix(CLOUDS_COVERAGE_CLEAR, CLOUDS_COVERAGE_RAIN, rainStrength);
        opticalDepth  = saturate(opticalDepth);

        return opticalDepth * mix(cloudDensityClear, cloudDensityRain, rainStrength) * saturate(rounding);
    }

    float CalculateCloudDensity(vec3 worldPosition, const vec3 direction, const int steps) {
        #if !defined CLOUDS
            return 0.0;
        #endif

        if(steps <= 1) {
            #define rayDirection direction * ((cloudMidAltitude - worldPosition.y) / direction.y)

            return CloudFBM(rayDirection + worldPosition) * cloudHeight;

            #undef rayDirection
        } else {
            float stepsRCP = rcp(steps);

            float stepSize = cloudHeight * stepsRCP;

            vec3 increment = direction * (stepSize / direction.y);

            worldPosition += direction * ((cloudMinAltitude - worldPosition.y) / direction.y);

            float opticalDepth = 0.0;

            for(int i = 0; i < steps; ++i, worldPosition += increment)
                opticalDepth += CloudFBM(worldPosition);

            return opticalDepth * stepSize;
        }
    }

    float CalculateCloudShadow(vec3 worldPosition, const vec3 direction, const float density) {
        #if !defined CLOUDS || !defined CLOUDS_SHADOW
            return 1.0;
        #endif
        
        #if CLOUDS_SHADOW_STEPS <= 1
            #define rayDirection direction * ((cloudMidAltitude - worldPosition.y) / direction.y)

            float opticalDepth = CloudFBM(rayDirection + worldPosition) * cloudHeight;

            #undef rayDirection
        #else
            const int   steps    = CLOUDS_SHADOW_STEPS;
            const float stepsRCP = rcp(steps);

            const float stepSize = cloudHeight * stepsRCP;

            vec3 increment = direction * (stepSize / direction.y);

            worldPosition += direction * ((cloudMinAltitude - worldPosition.y) / direction.y);

            float opticalDepth = 0.0;

            for(int i = 0; i < steps; ++i, worldPosition += increment)
                opticalDepth += CloudFBM(worldPosition);

            opticalDepth *= stepSize;
        #endif

        #define horizon smoothstep(0.0, CLOUDS_HORIZON_FADE, dot(direction, worldPositionUp))

        return mix(1.0, exp2(-cloudMaterial.y * opticalDepth * density), horizon);

        #undef horizon
    }

    #if PROGRAM == COMPOSITE0

        float CalculatePowder(float opticalDepth, float VoL) {
            float powd = 1.0 - exp2(-opticalDepth * 0.02);
            return powd;//mix(1.0, powd, saturate(-VoL * 0.5 + 0.5));
        }

        float CalculateCloudSelfOcclusion(vec3 worldPosition, vec3 increment, float opticalDepth, const vec2 dither, float density, const int steps) {
            if(steps <= 0) {
                opticalDepth = ((cloudMaxAltitude - worldPosition.y) / cloudHeight);

                return exp2(-cloudMaterial.z * opticalDepth * density * 0.3);
            } else {
                density /= steps;

                float stepSize = cloudHeight / (float(steps) + 0.5);

                increment *= stepSize;
                worldPosition = increment * dither.x + worldPosition;

                opticalDepth = 0.0;

                for(int i = 0; i < steps; ++i, worldPosition += increment)
                    opticalDepth += CloudFBM(worldPosition);

                return exp2(-cloudMaterial.z * opticalDepth * density);
            }
        }

        vec3 CalculateClouds(mat2x3 atmosphereLighting, const vec3 background, const vec3 viewPosition, vec3 worldPosition, const float depth, const vec2 dither) {
            #ifndef CLOUDS
                return background;
            #endif

            const float curvature = earthRadius;
            worldPosition.y -= sqrt(pow2(curvature) - pow2(fLength(worldPosition.xz))) - curvature;

            if((normalize(worldPosition).y < 0.01 && cameraPosition.y <= cloudMinAltitude) || normalize(worldPosition).y > -0.01 && cameraPosition.y >= cloudMaxAltitude)
                return background;

            atmosphereLighting[0] *= CLOUDS_LIGHTING_GLOBAL_DIRECT_BRIGHTNESS;
            atmosphereLighting[1] *= CLOUDS_LIGHTING_GLOBAL_SKY_BRIGHTNESS;

            const int   steps    = CLOUDS_STEPS;
            const float stepsRCP = rcp(steps);

            const float stepSize = cloudHeight * stepsRCP;

            float VoL = dot(normalize(viewPosition), lightDirection);

            float miePhase = Phase2Lobes(VoL);//(PhaseG(VoL, 0.8) + PhaseG(VoL, -0.5));

            vec3 nWorldPosition = normalize(worldPosition);

            vec3 startPosition = worldPosition * (cloudMinAltitude - cameraPosition.y) / worldPosition.y;

            if(cameraPosition.y >= cloudMinAltitude && cameraPosition.y <= cloudMaxAltitude) {
                startPosition = vec3(0.0);
            } else if(cameraPosition.y >= cloudMaxAltitude) {
                startPosition = worldPosition * (cloudMaxAltitude - cameraPosition.y) / worldPosition.y;
            }

            vec3 increment = (nWorldPosition / nWorldPosition.y) * cloudHeight * stepsRCP;

            vec3 position = (increment * dither.x + startPosition) + cameraPosition;

            vec3 scatter = vec3(0.0);
            float transmittance = 1.0;

            for(int i = 0; i < steps; ++i, position += increment) {
                float opticalDepth = CloudFBM(position) * stepSize;

                if(opticalDepth <= 0.0)
                    continue; // Skip this iteration if there is no cloud at the current step.

                float powder = CalculatePowder(opticalDepth, VoL);

                vec3 directLight  = atmosphereLighting[0] * CalculateCloudSelfOcclusion(position, lightDirectionWorld, opticalDepth, dither, cloudLightingDensityDirect, CLOUDS_LIGHTING_DIRECT_STEPS) * powder * miePhase;

                vec3 skyLight = atmosphereLighting[1] * CalculateCloudSelfOcclusion(position, worldPositionUp, opticalDepth, dither, cloudLightingDensitySky, CLOUDS_LIGHTING_SKY_STEPS);

                vec3 bouncedLight = atmosphereLighting[0] * CalculateCloudSelfOcclusion(position, -worldPositionUp, opticalDepth, dither, cloudLightingDensityBounced, CLOUDS_LIGHTING_BOUNCED_STEPS) * CLOUDS_LIGHTING_BOUNCED_BRIGHTNESS * abs(dot(lightDirection, -viewDirectionUp));

                scatter += (directLight + skyLight + bouncedLight) * cloudMaterial.x * TransmittedScatteringIntegral(opticalDepth, cloudMaterial.y) * transmittance;
                transmittance *= exp2(-cloudMaterial.y * opticalDepth);
            }

            float horizon = smoothstep(0.0, CLOUDS_HORIZON_FADE, dot(nWorldPosition, (cameraPosition.y >= cloudMaxAltitude) ? -worldPositionUp : worldPositionUp));

            if(cameraPosition.y >= cloudMinAltitude && cameraPosition.y <= cloudMaxAltitude)
                horizon = 1.0;

            scatter *= horizon;
            transmittance = mix(1.0, transmittance, horizon);

            return background * transmittance + scatter;
        }

    #endif

#endif
