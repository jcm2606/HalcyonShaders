/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_COMMON_CLOUDS
  #define INTERNAL_INCLUDED_COMMON_CLOUDS

  #if PROGRAM == COMPOSITE0
    vec3 drawClouds(in BufferList bufferList, in vec3 background, in vec2 screenCoord, in vec2 hitCoord, in bool isTransparent) {
      vec4 clouds = texture2DLod(colortex4, (isTransparent) ? hitCoord : screenCoord, 1);
      
      #define scattering clouds.rgb
      #define transmittance clouds.a

      return background * transmittance + scattering;

      #undef scattering
      #undef transmittance
    }
  #endif

  #if PROGRAM == DEFERRED1 || PROGRAM == DEFERRED2 || PROGRAM == COMPOSITE0
    cv(float) cloudHeight = 128.0;
    cRCP(float, cloudHeight);
    cv(float) cloudStartAltitude = CLOUD_ALTITUDE;
    cv(float) cloudEndAltitude = cloudStartAltitude + cloudHeight;

    cv(float) cloudStepSize = cloudHeight * cloudStepsRCP;

    cv(float) cloudDensityScale = cloudOctavesRCP * cloudHeightRCP;
    float cloudDensity = mix(
      CLOUDS_DENSITY_CLEAR,
      CLOUDS_DENSITY_RAIN,
      rainStrength
    ) * cloudDensityScale;

    vec3 cloudScatterAbsorbCoeff = vec3(0.02, 0.05, 0.02) * vec3(1.0, cloudDensity, cloudDensity); // x = scatter, y = view absorb, z = light absorb

    #include "/lib/util/Noise.glsl"

    float cloudFBM(in vec3 world) {
      float cloud = 0.0;

      world *= cloudScaleMultiplier;

      cv(mat2) rot = rotate2(-0.7);

      float weight = 1.0;

      cv(vec2) windDir = vec2(0.0, 1.0) * 0.04;
      vec3 wind = windDir.xxy * globalTime;

      for(int i = 0; i < cloudOctaves; ++i) {
        cloud = texnoise3D(noisetex, wind + world) * weight + cloud;

        world *= 2.2;
        world.xy *= rot;
        world.yz *= rot;
        wind *= 1.4;
        weight *= 0.5;
      }

      float coverage = mix(
        cloudCoverageClear,
        cloudCoverageRain,
        rainStrength
      );

      cloud -= coverage;
      cloud  = _max0(cloud);
      //cloud *= 1.3;

      return saturate(cloud);
    }

    float getCloudShadow(in vec3 world, in vec3 direction) {
      #ifndef CLOUDS
        return 1.0;
      #endif

      #define sampleDirection ( direction * ((cloudEndAltitude - world.y) / direction.y) + world )

      float opticalDepth  = cloudFBM(sampleDirection);

      //if(opticalDepth <= 0.0) return 1.0; // Early out when no cloud.

            opticalDepth *= 8.0;

      #undef sampleDirection

      float horizon = smoothstep(0.0, cloudHorizonFade, dot(direction, vec3(0.0, 1.0, 0.0)));

      //return exp(-cloudScatterAbsorbCoeff.z * cloudStepSize * opticalDepth) * horizon + (1.0 - horizon);
      return mix(1.0, exp(-cloudScatterAbsorbCoeff.z * cloudStepSize * opticalDepth), horizon);
    }
  #endif

  #if PROGRAM == DEFERRED2
    float cloud_visibility(in vec3 ray, in vec3 dir, in float odAtStart, in vec2 dither, cin(float) density, cin(int) steps) {
      cv(float) stepSize = cloudHeight / (float(steps) + 0.5);

      dir *= stepSize;
      ray = dir * dither.x + ray;

      odAtStart *= 0.5;

      for(int i = 0; i < steps; ++i, ray += dir) {
        float falloff = 1.0 - saturate((ray.y - cloudStartAltitude) / (cloudEndAltitude - cloudStartAltitude));

        odAtStart -= cloudFBM(ray);
      }

      return exp(cloudScatterAbsorbCoeff.z * density * odAtStart * stepSize);
    }

    vec4 computeClouds(in PositionData positionData, in mat2x3 atmosphereLighting, in vec2 dither) {
      #ifndef CLOUDS
        return vec4(0.0, 0.0, 0.0, 1.0);
      #endif

      if(_getLandMask(positionData.depthBack)) return vec4(0.0, 0.0, 0.0, 1.0);

      vec4 clouds = vec4(0.0, 0.0, 0.0, 1.0);

      #define scattering    clouds.rgb
      #define transmittance clouds.a

      vec3 nView = _normalize(positionData.viewBack);
      vec3 world = viewToWorld(positionData.viewBack);
      vec3 nWorld = _normalize(world);

      vec3 start = world * (cloudStartAltitude - cameraPosition.y) / world.y;

      float horizon = smoothstep(0.0, cloudHorizonFade, dot(nWorld, vec3(0.0, 1.0, 0.0)));

      if(cameraPosition.y >= cloudStartAltitude && cameraPosition.y <= cloudEndAltitude) {
        start = vec3(0.0);
        horizon = 1.0;
      } else if(cameraPosition.y >= cloudEndAltitude) {
        start = world * (cloudEndAltitude - cameraPosition.y) / world.y;
        horizon = smoothstep(0.0, cloudHorizonFade, dot(nWorld, -vec3(0.0, 1.0, 0.0)));
      }

      vec3 incr = (nWorld / nWorld.y) * cloudStepSize;

      vec3 ray = (incr * dither.x + start) + cameraPosition;

      for(int i = 0; i < cloudSteps; ++i, ray += incr) {
        // COMPUTE OPTICAL DEPTH
        float opticalDepth = cloudFBM(ray);

        // SKIP THE REST OF THIS ITERATION IF THERE IS NO CLOUD
        if(opticalDepth <= 0.0) continue;

        // COMPUTE LIGHTING VISIBILITY CHECKS
        #if CLOUDS_LIGHTING_DIRECT_STEPS > 0
          float visibilityDirect = cloud_visibility(ray, wLightDirection, opticalDepth, dither, CLOUDS_LIGHTING_DIRECT_WEIGHT, CLOUDS_LIGHTING_DIRECT_STEPS);
        #else
          float visibilityDirect = 1.0;
        #endif

        #if CLOUDS_LIGHTING_SKY_STEPS > 0
          float visibilitySky = cloud_visibility(ray, vec3(0.0, 1.0, 0.0), opticalDepth, dither, CLOUDS_LIGHTING_SKY_WEIGHT, CLOUDS_LIGHTING_SKY_STEPS);
        #else
          float visibilitySky = 1.0;
        #endif

        #if CLOUDS_LIGHTING_BOUNCED_STEPS > 0
          float visibilityBounced = cloud_visibility(ray, vec3(0.0, -1.0, 0.0), opticalDepth, dither, CLOUDS_LIGHTING_BOUNCED_WEIGHT, CLOUDS_LIGHTING_BOUNCED_STEPS);
        #else
          float visibilityBounced = 1.0;
        #endif

        // COMPUTE LIGHTING
        vec3 lightingDirect  = atmosphereLighting[0] * cloudLightDirectIntensity * visibilityDirect;
        vec3 lightingSky     = atmosphereLighting[1] * cloudLightSkyIntensity * visibilitySky;
        vec3 lightingBounced = atmosphereLighting[0] * cloudLightBouncedIntensity * visibilityBounced;

        vec3 lighting = (lightingDirect + lightingSky + lightingBounced) * 0.3;

        // COMPUTE SCATTERING/ABSORPTION
        scattering = (lighting * transmittedScatteringIntegral(opticalDepth * cloudStepSize, cloudScatterAbsorbCoeff.x)) * transmittance + scattering;
        transmittance *= exp(-cloudScatterAbsorbCoeff.y * opticalDepth * cloudStepSize);
      }

      //scattering *= cloudStepsRCP;

      #undef scattering
      #undef transmittance

      return mix(vec4(0.0, 0.0, 0.0, 1.0), clouds, horizon);
    }
  #endif

#endif /* INTERNAL_INCLUDED_COMMON_CLOUDS */
