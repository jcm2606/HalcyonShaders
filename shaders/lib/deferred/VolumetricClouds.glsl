/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_DEFERRED_VOLUMETRICCLOUDS
  #define INTERNAL_INCLUDED_DEFERRED_VOLUMETRICCLOUDS

  c(int) cloudSteps = 8;
  cRCP(float, cloudSteps);

  c(float) cloudAltitudeLower = VC_ALTITUDE;
  c(float) cloudHeight = VC_HEIGHT;
  c(float) cloudHeightHalf = cloudHeight * 0.5;
  c(float) cloudAltitudeUpper = cloudAltitudeLower + cloudHeight;
  c(float) cloudAltitudeCenter = cloudAltitudeLower + cloudHeightHalf;

  c(float) stepSize = cloudHeight * cloudStepsRCP;

  #if   PROGRAM == COMPOSITE0 || PROGRAM == DEFERRED1
    #include "/lib/common/util/Noise.glsl"

    float getCloudFBM(in vec3 world) {
      float fbm = 0.0;

      world *= 0.0003;

      mat2 rot = rot2(-0.7);

      c(int) octaves = 5;
      cRCP(float, octaves);

      float weight = 1.0;

      c(vec2) windDir = vec2(0.0, 1.0);
      vec3 wind = vec3(windDir.x, 0.0, windDir.y) * frametime;
      float windSpeed = 0.04;

      for(int i = 0; i < octaves; i++) {
        fbm += texnoise3D(noisetex, wind * windSpeed + world) * weight;

        world *= 2.2;
        world.xz *= rot;
        windSpeed *= 1.4;
        weight *= 0.6;
      }

      float coverage = mix(1.1, 0.9, rainStrength);

      fbm -= coverage;
      fbm  = max0(fbm);

      return clamp01(fbm);
    }
  #endif

  #if   PROGRAM == DEFERRED1 || PROGRAM == COMPOSITE0
    float getCloudShadow(in vec3 world) {
      float opticalDepth = getCloudFBM(wLightVector * ((cloudAltitudeUpper - world.y) / wLightVector.y) + world) * 6.0;

      return exp(-0.02 * stepSize * opticalDepth);
    }
  #endif

  #if   PROGRAM == COMPOSITE0
    float vcVisibilityCheck(in vec3 ray, in vec3 dir, float odAtStart, cin(float) range, cin(int) samples) {
      c(float) visStepSize = range / (float(samples) + 0.5);

      dir *= visStepSize;
      ray += dir * 0.5;

      float opticalDepth = 0.5 * odAtStart;

      for(int i = 0; i < samples; i++, ray += dir) {
        float falloff = 1.0 - clamp01((ray.y - cloudAltitudeLower) / (cloudAltitudeUpper - cloudAltitudeLower));

        opticalDepth -= getCloudFBM(ray) * falloff;
      }

      return exp((0.02 * 1.11) * visStepSize * opticalDepth);
    }

    vec4 getVolumetricClouds(in vec3 view, in float backDepth, in mat2x3 atmosphereLighting) {
      #ifndef VOLUMETRIC_CLOUDS
        return vec4(0.0, 0.0, 0.0, 1.0);
      #endif

      vec4 clouds = vec4(0.0, 0.0, 0.0, 1.0);

      if(getLandMask(backDepth)) return clouds;

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

      vec3 ray = incr * bayer128(gl_FragCoord.xy) + start + cameraPosition;

      float miePhase = phaseMie(dot(nWorld, wLightVector));

      for(int i = 0; i < cloudSteps; i++, ray += incr) {
        float opticalDepth = getCloudFBM(ray);

        if(opticalDepth <= 0.0) continue;

        float visibilityLight = vcVisibilityCheck(ray, wLightVector, opticalDepth, cloudHeight, 2);

        vec3 lightingDirect = atmosphereLighting[0] * visibilityLight;
        vec3 lightingSky = atmosphereLighting[1];

        vec3 lighting = lightingDirect + lightingSky;

        scattering += lighting * transmittedScatteringIntegral(opticalDepth, 0.02) * transmittance;
        transmittance *= exp(-0.02 * stepSize * opticalDepth);
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
