/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_DEFERRED_VOLUMETRICCLOUDS
  #define INTERNAL_INCLUDED_DEFERRED_VOLUMETRICCLOUDS

  #if   PROGRAM == COMPOSITE0 || PROGRAM == DEFERRED1 || PROGRAM == DEFERRED2
    #include "/lib/common/util/Noise.glsl"

    #include "/lib/common/util/WeatherCycle.glsl"

    c(int) cloudSteps = VC_QUALITY;
    cRCP(float, cloudSteps);
    c(int) cloudOctaves = VC_OCTAVES;
    cRCP(float, cloudOctaves);

    c(float) cloudAltitudeLower = VC_ALTITUDE;
    c(float) cloudHeight = VC_HEIGHT;
    cRCP(float, cloudHeight);
    c(float) cloudHeightHalf = cloudHeight * 0.5;
    c(float) cloudAltitudeUpper = cloudAltitudeLower + cloudHeight;
    c(float) cloudAltitudeCenter = cloudAltitudeLower + cloudHeightHalf;
    c(float) cloudDensityScale = cloudOctavesRCP * cloudHeightRCP;

    float cloudDensity = mix(VC_DENSITY_CLEAR + weatherCycle * cloudOvercastOffsetDensity, VC_DENSITY_RAIN, rainStrength) * cloudDensityScale;

    c(float) stepSize = cloudHeight * cloudStepsRCP;

    float getCloudFBM(in vec3 world) {
      float fbm = 0.0;

      world *= 0.0003;

      mat2 rot = rot2(-0.7);

      float weight = 1.0;

      c(vec2) windDir = vec2(0.0, 1.0);
      vec3 wind = vec3(windDir.x, 0.0, windDir.y) * frametime;
      float windSpeed = 0.04;

      for(int i = 0; i < cloudOctaves; i++) {
        fbm += texnoise3D(noisetex, wind * windSpeed + world) * weight;

        world *= 2.2;
        world.xz *= rot;
        world.yz *= rot;
        windSpeed *= 1.4;
        weight *= 0.6;
      }

      float coverage = mix(VC_COVERAGE_CLEAR - pow2(weatherCycle) * cloudOvercastOffsetCoverage, VC_COVERAGE_RAIN, rainStrength);

      fbm -= coverage;
      fbm  = max0(fbm);
      fbm *= 1.2;

      return clamp01(fbm);
    }

    float getCloudShadow(in vec3 world) {
      float opticalDepth = getCloudFBM(wLightVector * ((cloudAltitudeUpper - world.y) / wLightVector.y) + world) * 1.5 * smoothstep(0.0, 0.1, dot(normalize(wLightVector), vec3(0.0, 1.0, 0.0)));

      return exp(-0.02 * stepSize * opticalDepth * cloudDensity);
    }
  #endif

  #if   PROGRAM == COMPOSITE0
    float vcVisibilityCheck(in vec3 ray, in vec3 dir, in float odAtStart, in float visDensity, in float dither, const in int samples) {
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

    vec4 getVolumetricClouds(in vec3 view, in float backDepth, in mat2x3 atmosphereLighting) {
      #ifndef VOLUMETRIC_CLOUDS
        return vec4(0.0, 0.0, 0.0, 1.0);
      #endif

      vec4 clouds = vec4(0.0, 0.0, 0.0, 1.0);

      if(getLandMask(backDepth)) return clouds;

      atmosphereLighting[1] *= 1.5;

      #define scattering clouds.rgb
      #define transmittance clouds.a

      vec3 world = viewToWorld(view);
      vec3 nWorld = normalize(world);

      vec3 start = world * (cloudAltitudeLower - cameraPosition.y) / world.y;

      if(cameraPosition.y >= cloudAltitudeLower && cameraPosition.y <= cloudAltitudeUpper) {
        start = vec3(0.0);
      } else if(cameraPosition.y >= cloudAltitudeUpper) {
        start = world * (cloudAltitudeUpper - cameraPosition.y) / world.y;
      }

      vec3 incr = (nWorld / nWorld.y) * stepSize;

      float dither = bayer128(gl_FragCoord.xy);
      vec3 ray = incr * dither + start + cameraPosition;

      float miePhase = phaseMie(dot(nWorld, wLightVector));

      for(int i = 0; i < cloudSteps; i++, ray += incr) {
        float opticalDepth = getCloudFBM(ray);

        if(opticalDepth <= 0.0) continue;

        float visibilityLight = vcVisibilityCheck(ray, wLightVector, opticalDepth, 0.7, dither, VC_LIGHTING_QUALITY_DIRECT);
        float visibilitySky = vcVisibilityCheck(ray, vec3(0.0, 1.0, 0.0), opticalDepth, 0.2, dither, VC_LIGHTING_QUALITY_SKY);
        float visibilityBounced = vcVisibilityCheck(ray, vec3(0.0, -1.0, 0.0), opticalDepth, 0.5, dither, VC_LIGHTING_QUALITY_BOUNCED);

        vec3 lightingDirect = atmosphereLighting[0] * visibilityLight;
        vec3 lightingSky = atmosphereLighting[1] * visibilitySky;
        vec3 lightingBounced = (atmosphereLighting[0] * max0(dot(lightVector, upVector)) + atmosphereLighting[1]) * 0.2 * visibilityBounced;

        vec3 lighting = lightingDirect + lightingSky + lightingBounced;

        scattering += lighting * transmittedScatteringIntegral(opticalDepth, 0.02) * transmittance;
        transmittance *= exp(-0.02 * stepSize * opticalDepth * cloudDensity);
      }

      scattering *= cloudStepsRCP;

      #undef scattering
      #undef transmittance

      clouds = mix(vec4(0.0, 0.0, 0.0, 1.0), clouds, smoothstep(0.0, 0.02, dot(normalize(view), upVector)));

      return clouds;
    }
  #elif PROGRAM == COMPOSITE1
    vec3 drawVolumetricClouds(io PositionObject position, in vec3 frame, in vec2 screenCoord) {
      #ifndef VOLUMETRIC_CLOUDS
        return frame;
      #endif

      c(int) samples = 1;
      cRCP(float, samples);
      c(float) filterRadius = 0.001;
      c(vec2) filterOffset = vec2(filterRadius) * samplesRCP;
      c(float) weight = 1.0 / pow(float(samples) * 2.0 + 1.0, 2.0);

      vec4 clouds = vec4(0.0);

      for(int i = -samples; i <= samples; i++) {
        for(int j = -samples; j <= samples; j++) {
          vec2 offset = vec2(i, j) * filterOffset + screenCoord;

          clouds += texture2DLod(colortex5, offset, 1);
        }
      }

      clouds *= weight;

      return frame * clouds.a + clouds.rgb;
    }
  #endif

#endif /* INTERNAL_INCLUDED_DEFERRED_VOLUMETRICCLOUDS */
