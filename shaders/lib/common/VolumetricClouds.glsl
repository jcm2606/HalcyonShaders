/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_COMMON_VOLUMETRICCLOUDS
  #define INTERNAL_INCLUDED_COMMON_VOLUMETRICCLOUDS

  #if   PROGRAM == COMPOSITE0 || PROGRAM == DEFERRED1 || PROGRAM == DEFERRED2
    #include "/lib/common/util/Noise.glsl"

    #include "/lib/common/util/WeatherCycle.glsl"

    cv(int) cloudSteps = VC_QUALITY;
    cRCP(float, cloudSteps);
    cv(int) cloudOctaves = VC_OCTAVES;
    cRCP(float, cloudOctaves);

    cv(float) cloudAltitudeLower = VC_ALTITUDE;
    cv(float) cloudHeight = VC_HEIGHT;
    cRCP(float, cloudHeight);
    cv(float) cloudHeightHalf = cloudHeight * 0.5;
    cv(float) cloudAltitudeUpper = cloudAltitudeLower + cloudHeight;
    cv(float) cloudAltitudeCenter = cloudAltitudeLower + cloudHeightHalf;
    cv(float) cloudDensityScale = cloudOctavesRCP * cloudHeightRCP;

    float cloudDensity = mix(VC_DENSITY_CLEAR + weatherCycle * cloudOvercastOffsetDensity, VC_DENSITY_RAIN, rainStrength) * cloudDensityScale;

    cv(float) stepSize = cloudHeight * cloudStepsRCP;

    float getCloudFBM(in vec3 world) {
      float fbm = 0.0;

      world *= cloudScale;

      cv(mat2) rot = rot2(-0.7);

      float weight = 1.0;

      cv(vec2) windDir = vec2(0.0, 1.0);
      vec3 wind = vec3(windDir.x, 0.0, windDir.y) * frametime;
      float windSpeed = 0.04;

      for(int i = 0; i < cloudOctaves; i++) {
        float noiseSample = texnoise3D(noisetex, wind * windSpeed + world) * weight;

        if(mod(i, 2) == 0)
          fbm += noiseSample;
        else
          fbm -= noiseSample;

        world *= 2.2;
        world.xz *= rot;
        //world.yz *= rot;
        windSpeed *= 1.4;
        weight *= 0.55;
      }

      //float coverageScale = mix(1.0, 1.0, smoothstep(0.0, 0.1, dot(normalize(world), normalize(vec3(0.0, 1.0, 0.0)))));
      float coverage = mix(VC_COVERAGE_CLEAR - pow2(weatherCycle) * cloudOvercastOffsetCoverage, VC_COVERAGE_RAIN, rainStrength);

      fbm -= coverage;
      fbm  = max0(fbm);
      fbm *= 1.3;

      return clamp01(fbm);
    }

    float getCloudShadow(in vec3 world, in vec3 light) {
      #ifndef VOLUMETRIC_CLOUDS
        return 1.0;
      #endif

      vec3 sampleDirection = light * ((cloudAltitudeUpper - world.y) / light.y) + world;

      float opticalDepth  = getCloudFBM(sampleDirection);
            opticalDepth *= 2.0;
            //opticalDepth *= smoothstep(0.0, 0.1, dot(normalize(light), normalize(vec3(0.0, 1.0, 0.0))));

      return exp(-0.02 * stepSize * opticalDepth * cloudDensity);
    }
  #endif

  #if   PROGRAM == COMPOSITE0
    float vcVisibilityCheck(in vec3 ray, in vec3 dir, in float odAtStart, in float visDensity, in float dither, const int samples) {
      const float visStepSize = cloudHeight / (float(samples) + 0.5);

      dir *= visStepSize;
      ray += dither * dir;

      float opticalDepth = 0.5 * odAtStart;

      for(int i = 0; i < samples; i++, ray += dir) {
        float falloff = 1.0 - clamp01((ray.y - cloudAltitudeLower) / (cloudAltitudeUpper - cloudAltitudeLower));

        opticalDepth -= getCloudFBM(ray);
      }

      return exp((0.02 * visDensity) * visStepSize * opticalDepth * cloudDensity);
    }

    float vc_miePhase(in float theta, cin(float) G) {
      cv(float) gg = G * G;
      cv(float) p1 = (0.75 * (1.0 - gg)) / (tau * (2.0 + gg));
      float p2 = (theta * theta + 1.0) * pow(1.0 + gg - 2.0 * G * theta, -1.5);
    
      return p1 * p2;
    }

    vec4 getVolumetricClouds(io GbufferObject gbuffer, io PositionObject position, in mat2x3 atmosphereLighting) {
      #ifndef VOLUMETRIC_CLOUDS
        return vec4(0.0, 0.0, 0.0, 1.0);
      #endif

      vec4 clouds = vec4(0.0, 0.0, 0.0, 1.0);

      if(getLandMask(position.depthBack)) return clouds;

      atmosphereLighting[1] *= 1.5;
      atmosphereLighting[0] *= 4.0;

      #define scattering clouds.rgb
      #define transmittance clouds.a

      vec3 view = position.viewBack;

      //view += refract(view, gbuffer.normal, refractInterfaceAirWater) * 100.0;

      //float refractDist = 0.0;
      //view = refractView(refractDist, position.viewFront, view, gbuffer.normal, refractInterfaceAirWater);

      vec3 nView = normalize(view);
      vec3 world = viewToWorld(view);
      if(position.depthBack > position.depthFront) world += refract(normalize(world), normalize(mat3(gbufferModelView) * gbuffer.normal), refractInterfaceAirWater);
      vec3 nWorld = normalize(world);

      vec3 start = world * (cloudAltitudeLower - cameraPosition.y) / world.y;

      float horizonFade = smoothstep(0.0, 0.02, dot(nView, upVector));

      if(cameraPosition.y >= cloudAltitudeLower && cameraPosition.y <= cloudAltitudeUpper) {
        start = vec3(0.0);
        horizonFade = 1.0;
      } else if(cameraPosition.y >= cloudAltitudeUpper) {
        start = world * (cloudAltitudeUpper - cameraPosition.y) / world.y;
        horizonFade = smoothstep(0.0, 0.02, dot(nView, -upVector));
      }

      vec3 incr = (nWorld / nWorld.y) * stepSize;

      float dither = bayer128(gl_FragCoord.xy);
      vec3 ray = incr * dither + start + cameraPosition;

      float miePhase = vc_miePhase(dot(nWorld, normalize(wLightVector)), 0.8) * 8.0 + 0.8;

      for(int i = 0; i < cloudSteps; i++, ray += incr) {
        float opticalDepth = getCloudFBM(ray);

        if(opticalDepth <= 0.0) continue;

        #if VC_LIGHTING_QUALITY_DIRECT > 0
          float visibilityLight = vcVisibilityCheck(ray, wLightVector, opticalDepth, 1.3, dither, VC_LIGHTING_QUALITY_DIRECT);
        #else
          float visibilityLight = 1.0;
        #endif

        #if VC_LIGHTING_QUALITY_SKY > 0
          float visibilitySky = vcVisibilityCheck(ray, vec3(0.0, 1.0, 0.0), opticalDepth, 0.5, dither, VC_LIGHTING_QUALITY_SKY);
        #else
          float visibilitySky = 1.0;
        #endif

        #if VC_LIGHTING_QUALITY_BOUNCED > 0
          float visibilityBounced = vcVisibilityCheck(ray, vec3(0.0, -1.0, 0.0), opticalDepth, 0.5, dither, VC_LIGHTING_QUALITY_BOUNCED);
        #else
          float visibilityBounced = 1.0;
        #endif

        vec3 lightingDirect = atmosphereLighting[0] * visibilityLight * miePhase;
        vec3 lightingSky = atmosphereLighting[1] * visibilitySky;
        vec3 lightingBounced = (atmosphereLighting[0] * max0(dot(lightVector, upVector)) + atmosphereLighting[1]) * 0.05 * visibilityBounced;

        vec3 lighting = lightingDirect + lightingSky + lightingBounced;

        if(position.depthBack > position.depthFront) lighting *= gbuffer.albedo;

        scattering += lighting * transmittedScatteringIntegral(opticalDepth, 0.02) * transmittance;
        transmittance *= exp(-0.07 * stepSize * opticalDepth * cloudDensity);
      }

      scattering *= cloudStepsRCP;

      #undef scattering
      #undef transmittance

      clouds = mix(
        vec4(0.0, 0.0, 0.0, 1.0),
        clouds,
        horizonFade
      );

      return clouds;
    }
  #endif

#endif /* INTERNAL_INCLUDED_COMMON_VOLUMETRICCLOUDS */
