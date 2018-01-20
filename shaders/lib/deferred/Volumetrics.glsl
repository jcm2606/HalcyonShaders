/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_DEFERRED_VOLUMETRICS
  #define INTERNAL_INCLUDED_DEFERRED_VOLUMETRICS

  // FILTER
  #if PROGRAM == COMPOSITE1
    #include "/lib/common/Reflections.glsl"

    #include "/lib/sampler/Bicubic.glsl"

    vec3 drawVolumetricEffects(in GbufferData gbufferData, in PositionData positionData, in BufferList bufferList, in vec3 background, in vec2 screenCoord, in mat2x3 atmosphereLighting, in float highlightOcclusion, in vec2 dither) {
      cv(int) samples = 9; // 4, 9, 16, 25
      cRCP(float, samples);

      cv(float) radius = 4.5 / samples;

      cv(float) volumetricsLOD = 0;
      cv(float) depthLookupScale = volumetricsLOD * 0.0;
      cv(int) cloudLOD = 0;

      vec2 scale = radius * (1.0 / viewWidth) * vec2(1.0, aspectRatio);

      /*
        Buffer key:
          colortex4.rgb = volumetrics scattering
          colortex5.rgb = volumetrics front absorption (air + fog + other layers)
          colortex6.rgb = volumetrics back absorption (water)

        Order:
          volumetrics back absorption
          transparent reflections
          volumetrics front absorption
          volumetrics scattering
      */

      mat3 volumetrics = mat3(0.0);

      float centerDepth = _linearDepth(positionData.depthFront);
      bool centerSkyMask = !_getLandMask(positionData.depthFront);

      for(int i = 0; i < samples; i++) {
        vec2 offset = to2D(i, samples);

        float sampleDepthIn = texture2D(depthtex0, offset * -3.0 * scale + screenCoord).x;
        float sampleDepthOut = texture2D(depthtex0, offset * 3.0 * scale + screenCoord).x;

        cv(float) threshold = 0.1;
        float weight  = float( abs(centerDepth - _linearDepth(sampleDepthIn)) > threshold || abs(centerDepth - _linearDepth(sampleDepthOut)) > threshold );
        
        volumetrics[0] = texture2DLod(colortex4, offset * scale + screenCoord, volumetricsLOD).rgb * samplesRCP + volumetrics[0];
        volumetrics[1] = mix(texture2DLod(colortex5, offset * scale + screenCoord, volumetricsLOD).rgb, bufferList.tex5.rgb, weight) * samplesRCP + volumetrics[1];
        volumetrics[2] = mix(texture2DLod(colortex6, offset * scale + screenCoord, volumetricsLOD).rgb, bufferList.tex6.rgb, weight) * samplesRCP + volumetrics[2];
        
      }

      // PERFORM BACK ABSORPTION
      if((underWater) || (positionData.depthBack > positionData.depthFront)) background *= volumetrics[2];

      // DRAW TRANSPARENT OBJECTS
      background = mix(background, bufferList.tex7.rgb, bufferList.tex7.a);

      // DRAW TRANSPARENT REFLECTIONS
      if(!underWater &&
        #ifdef SPECULAR_DUAL_LAYER
          positionData.depthBack > positionData.depthFront
        #else
          _getLandMask(positionData.depthFront)
        #endif
      ) background = drawReflections(gbufferData, positionData, background, screenCoord, atmosphereLighting, vec4(highlightOcclusion), dither);

      // PERFORM FRONT ABSORPTION & DRAW VOLUMETRICS SCATTERING
      background  = background * volumetrics[1] + volumetrics[0];

      return background;
    }
  #endif

  // MARCHER
  #if PROGRAM == COMPOSITE0
    #include "/lib/util/SpaceConversion.glsl"
    #include "/lib/util/ShadowConversion.glsl"

    #include "/lib/common/Atmosphere.glsl"

    // OPTIONS
    cv(float) volSteps = 6;
    cRCP(float, volSteps);
    
    // ATMOSPHERE LAYERS
    const struct AtmosphereLayerComplex {
      mat2x3 scatterCoeff;
      mat2x3 transmittanceCoeff;
    };

    const struct AtmosphereLayerSimple {
      vec3 scatterCoeff;
      vec3 transmittanceCoeff;
    };

    // AIR
    cv(AtmosphereLayerComplex) layerAir = AtmosphereLayerComplex(
      mat2x3(rayleighCoeff, vec3(mieCoeff)),
      mat2x3(rayleighCoeff + ozoneCoeff, vec3(mieCoeff) * 1.11)
    );

    // FOG
    cv(vec3) scatterCoeff = vec3(0.002) / log(2.0);
    cv(vec3) absorbCoeff = vec3(0.05) / log(2.0);
    cv(AtmosphereLayerSimple) layerFog = AtmosphereLayerSimple(
      scatterCoeff,
      scatterCoeff + absorbCoeff
    );

    // WATER
    cv(AtmosphereLayerSimple) layerWater = AtmosphereLayerSimple(
      waterScatterCoeff,
      waterTransmittanceCoeff
    );

    #define _waterPartialAbsorption() ( (underWater && !isWater) ? exp(-layerWater.transmittanceCoeff * distanceToFront * VOLUMETRIC_WATER_DENSITY) : vec3(1.0) )

    void computeAtmosphereContribution(io vec3 scattering, io vec3 transmittance, cin(AtmosphereLayerComplex) atmosphereLayer, in bool isWater, in float distanceToFront, in vec3 directLight, in vec3 skyLight, in vec3 phase, in float opticalDepth) {
      mat2x3 scatterCoeff = mat2x3(
        atmosphereLayer.scatterCoeff[0] * transmittedScatteringIntegral(opticalDepth, atmosphereLayer.transmittanceCoeff[0]),
        atmosphereLayer.scatterCoeff[1] * transmittedScatteringIntegral(opticalDepth, atmosphereLayer.transmittanceCoeff[1])
      );

      directLight = directLight * (scatterCoeff * phase.xy);
      skyLight = skyLight * (scatterCoeff * phase.zz);

      scattering += (directLight + skyLight) * transmittance * _waterPartialAbsorption();
      transmittance *= exp(-atmosphereLayer.transmittanceCoeff * vec2(opticalDepth));
    }

    void computeAtmosphereContribution(io vec3 scattering, io vec3 transmittance, cin(AtmosphereLayerSimple) atmosphereLayer, in bool isWater, in float distanceToFront, in vec3 directLight, in vec3 skyLight, in float phase, in float opticalDepth) {
      vec3 scatterCoeff = atmosphereLayer.scatterCoeff * transmittedScatteringIntegral(opticalDepth, atmosphereLayer.transmittanceCoeff);

      directLight = directLight * scatterCoeff * phase;
      skyLight = skyLight * scatterCoeff;

      scattering += (directLight + skyLight) * transmittance * _waterPartialAbsorption();
      transmittance *= exp(-atmosphereLayer.transmittanceCoeff * opticalDepth);
    }

    #undef _waterPartialAbsorption

    // RAYS
    struct RayVolumetric {
      vec3 worldStart;
      vec3 worldEnd;
      vec3 worldStep;
      vec3 worldPos;
      float worldStepSize;

      vec3 shadowStart;
      vec3 shadowEnd;
      vec3 shadowStep;
      vec3 shadowPos;
    };

    #define _newRay(name) RayVolumetric name = RayVolumetric(vec3(0.0), vec3(0.0), vec3(0.0), vec3(0.0), 0.0, vec3(0.0), vec3(0.0), vec3(0.0),vec3(0.0));

    void createRay(io RayVolumetric ray, in vec3 start, in vec3 end, in vec2 dither) {
      // WORLD
      ray.worldStart = start;
      ray.worldEnd = end;

      ray.worldStep = (ray.worldEnd - ray.worldStart) * volStepsRCP;
      ray.worldPos = ray.worldStep * dither.x + ray.worldStart;

      ray.worldStepSize = _length(ray.worldStep);

      // SHADOW
      cv(vec3) shadowBias = vec3(vec2(0.0), 0.75 * shadowMapResolutionRCP);
      ray.shadowStart = worldToShadow(ray.worldStart);
      ray.shadowEnd = worldToShadow(ray.worldEnd);

      ray.shadowStep = (ray.shadowEnd - ray.shadowStart) * volStepsRCP;
      ray.shadowPos = (ray.shadowStep * dither.x + ray.shadowStart) + shadowBias;
    }

    // LIGHTING
    float volumetrics_miePhase(in float theta, cin(float) G) {
      cv(float) g2 = G * G;
      cv(float) p1 = (0.75 * (1.0 - g2)) / (tau * (2.0 + g2));

      cv(float) p2_g2 = 1.0 + g2;
      cv(float) G_p2 = 2.0 * G;
      float p2 = (theta * theta + 1.0) * _pow(p2_g2 - G_p2 * theta, -1.5);
    
      return p1 * p2;
    }

    void computeShadowing(io vec2 visibilityEye, io float visibilityWater, io vec3 shadowColourEye, io vec3 shadowColourWater, io float depthFront, io float objectID, io bool isTransparentShadow, in RayVolumetric eyeRay, in RayVolumetric waterRay, in bool isTransparentPixel, in bool isWaterPixel, in bool isSkyPixel) {
      #define visibilityBack visibilityEye.x
      #define visibilityFront visibilityEye.y

      // COMPUTE EYE SHADOWS
      // DISTORT SHADOW POSITION
      eyeRay.shadowPos.xy = distortShadowPosition(eyeRay.shadowPos.xy, true);

      // SAMPLE FRONT DEPTH
      depthFront = texture2DLod(shadowtex0, eyeRay.shadowPos.xy, 0).x;

      // COMPUTE SHADOW VISIBILITY
      visibilityBack = _cutShadow(compareShadowDepth(texture2DLod(shadowtex1, eyeRay.shadowPos.xy, 0).x, eyeRay.shadowPos.z));
      visibilityFront = _cutShadow(compareShadowDepth(depthFront, eyeRay.shadowPos.z));

      // OVERWRITE SHADOW VISIBILITY ON INVALID SKY STEP
      if(isSkyPixel && (any(greaterThan(eyeRay.shadowPos.xy, vec2(1.0))) || any(lessThan(eyeRay.shadowPos.xy, vec2(0.0))))) {
        visibilityBack = 1.0;
        visibilityFront = 1.0;
      }

      // COMPUTE TRANSPARENT SHADOW MASK
      isTransparentShadow = visibilityBack - visibilityFront > 0.0;

      // SAMPLE SHADOW COLOUR
      if(isTransparentShadow) {
        shadowColourEye = texture2DLod(shadowcolor0, eyeRay.shadowPos.xy, 0).rgb;
      } else {
        shadowColourEye = vec3(1.0);
      }

      if(!isTransparentPixel) return;

      // COMPUTE WATER SHADOW
      // DISTORT SHADOW POSITION
      waterRay.shadowPos.xy = distortShadowPosition(waterRay.shadowPos.xy, true);

      // COMPUTE BACK SHADOW VISIBILITY
      visibilityWater = _cutShadow(compareShadowDepth(texture2DLod(shadowtex1, waterRay.shadowPos.xy, 0).x, waterRay.shadowPos.z));

      // SAMPLE SHADOW COLOUR
      shadowColourWater = texture2DLod(shadowcolor0, waterRay.shadowPos.xy, 0).rgb;

      if(!isWaterPixel) return;

      // COMPUTE WATER DEPTH
      float waterDepth = texture2DLod(shadowtex0, waterRay.shadowPos.xy, 0).x * 8.0 - 4.0;
            waterDepth = waterDepth * shadowProjectionInverse[2].z + shadowProjectionInverse[3].z;
            waterDepth = (_transMAD(shadowModelView, waterRay.worldPos)).z - waterDepth;
    
      // ABSORB SHADOW COLOUR
      if(waterDepth < 0.0) shadowColourWater *= exp(layerWater.transmittanceCoeff * waterDepth * VOLUMETRIC_WATER_DENSITY);

      #undef visibilityBack
      #undef visibilityFront
    }

    // OPTICAL DEPTH FUNCTIONS
    float opticalDepthAir(in vec3 world) {
      return exp2(-world.y * 0.001) * 4.0;
    }

    float opticalDepthFog(in vec3 world) {
      return exp2(-_max0(world.y - SEA_LEVEL) * 0.25) * 0.025;
    }

    // VOLUMETRICS FUNCTION
    void computeVolumetrics(in PositionData positionData, in GbufferData gbufferData, in MaskList maskList, out vec3 backTransmittance, out vec3 frontTransmittance, out vec3 scattering, in vec2 dither, in mat2x3 atmosphereLighting) {
      backTransmittance = vec3(1.0);
      frontTransmittance = vec3(1.0);
      scattering = vec3(0.0);

      #if !defined(VOLUMETRICS) || ( !defined(ATMOSPHERIC_SCATTERING) && !defined(VOLUMETRIC_FOG) && !defined(VOLUMETRIC_WATER) )
        return;
      #endif

      // COMPUTE TRANSPARENT PIXEL MASK
      bool isTransparentPixel = (!underWater && positionData.depthBack > positionData.depthFront) || (underWater);
      bool isWaterPixel = (isTransparentPixel && maskList.water) || (underWater);

      // COMPUTE SKY MASK
      bool isSkyPixel = !_getLandMask(positionData.depthBack);

      // COMPUTE PHASES
      float VoL = dot(_normalize(positionData.viewBack), lightDirection);
      vec3 phaseAir = vec3(phaseRayleigh(VoL), volumetrics_miePhase(VoL, 0.8), 0.5);

      float phaseFog = volumetrics_miePhase(_max0(VoL), 0.2);

      // COMPUTE WORLD POSITIONS
      vec3 worldFront = viewToWorld(positionData.viewFront);
      vec3 worldBack  = viewToWorld(positionData.viewBack);

      // CREATE EYE RAY
      _newRay(eyeRay);
      createRay(eyeRay, (underWater) ? worldFront : gbufferModelViewInverse[3].xyz, (underWater) ? worldBack : worldFront, dither);

      // CREATE WATER RAY
      _newRay(waterRay);
      createRay(waterRay, (underWater) ? gbufferModelViewInverse[3].xyz : worldFront, (underWater) ? worldFront : worldBack, dither);

      // COMPUTE DISTANCE TO FRONT
      float distanceToFront = _length(worldFront);

      // PREALLOCATE VARIABLES
      // Doing this improves FPS slightly, still, it's an improvement.
      vec3 eyeWorld, waterWorld, directLight, skyLight, shadowColourEye, shadowColourWater = vec3(0.0);

      vec2 visibilityEye = vec2(0.0);

      bool eye_isTransparentStep, eye_isWaterStep, isTransparentShadow = false;

      float distanceToRay, objectID, visibilityWater, depthFront = 0.0;

      // MARCH
      for(int i = 0; i < volSteps; i++, eyeRay.worldPos += eyeRay.worldStep, eyeRay.shadowPos += eyeRay.shadowStep, waterRay.worldPos += waterRay.worldStep, waterRay.shadowPos += waterRay.shadowStep) {
        // COMPUTE WORLD POSITION
        eyeWorld = eyeRay.worldPos + cameraPosition;
        waterWorld = waterRay.worldPos + cameraPosition;

        // COMPUTE DISTANCE TO RAY
        distanceToRay = _length(eyeRay.worldPos);

        // COMPUTE STEP MASKS
        eye_isTransparentStep = distanceToRay >= distanceToFront;
        eye_isWaterStep = (!underWater && eye_isTransparentStep && maskList.water) || (underWater && !eye_isTransparentStep);

        // COMPUTE LIGHTING
        directLight = atmosphereLighting[0];
        skyLight = atmosphereLighting[1];

        visibilityEye = vec2(0.0);
        visibilityWater = 0.0;

        #define visibilityBack visibilityEye.x
        #define visibilityFront visibilityEye.y

        shadowColourEye = vec3(0.0);
        shadowColourWater = vec3(0.0);

        isTransparentShadow = false;
        objectID = 0.0;

        depthFront = 0.0;
        
        computeShadowing(visibilityEye, visibilityWater, shadowColourEye, shadowColourWater, depthFront, objectID, isTransparentShadow, eyeRay, waterRay, isTransparentPixel, isWaterPixel, isSkyPixel);
        
        // COMPUTE ATMOSPHERE CONTRIBUTION
        // WATER
        if(isTransparentPixel) {
          if(isWaterPixel) {
            computeAtmosphereContribution(scattering, backTransmittance, layerWater, true, distanceToFront, directLight * shadowColourWater * visibilityWater, skyLight * shadowColourWater * visibilityWater, 1.0, VOLUMETRIC_WATER_DENSITY * waterRay.worldStepSize);
          } else {
            // AIR
            {
              computeAtmosphereContribution(scattering, backTransmittance, layerAir, false, distanceToFront, directLight * visibilityWater, skyLight * visibilityWater, phaseAir, opticalDepthAir(waterWorld) * waterRay.worldStepSize);
            }

            // FOG
            {
              computeAtmosphereContribution(scattering, backTransmittance, layerFog, false, distanceToFront, directLight * visibilityWater * 6.0, skyLight * visibilityWater, phaseFog, opticalDepthFog(waterWorld) * waterRay.worldStepSize);
            } 
          }
        }

        // AIR
        {
          computeAtmosphereContribution(scattering, frontTransmittance, layerAir, false, distanceToFront, directLight * shadowColourEye * visibilityBack, skyLight * shadowColourEye * visibilityBack, phaseAir, opticalDepthAir(eyeWorld) * eyeRay.worldStepSize);
        }

        // FOG
        {
          computeAtmosphereContribution(scattering, frontTransmittance, layerFog, false, distanceToFront, directLight * shadowColourEye * visibilityBack * 6.0, skyLight * shadowColourEye * visibilityBack, phaseFog, opticalDepthFog(eyeWorld) * eyeRay.worldStepSize);
        }

        #undef visibilityBack
        #undef visibilityFront
      }
    }
  #endif

#endif /* INTERNAL_INCLUDED_DEFERRED_VOLUMETRICS */
