/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_DEFERRED_VOLUMETRICS
  #define INTERNAL_INCLUDED_DEFERRED_VOLUMETRICS

  // FILTER
  #if PROGRAM == COMPOSITE2
    
  #endif

  // MARCHER
  #if PROGRAM == COMPOSITE1
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
    cv(vec3) scatterCoeff = vec3(0.01) / log(2.0);
    cv(vec3) absorbCoeff = vec3(0.05) / log(2.0);
    cv(AtmosphereLayerSimple) layerFog = AtmosphereLayerSimple(
      scatterCoeff,
      scatterCoeff + absorbCoeff
    );

    // WATER
    cv(vec3) waterScatterCoeff = vec3(0.001) / log(2.0);
    cv(vec3) waterAbsorptionCoeff = vec3(0.4510, 0.0867, 0.0476) / log(2.0);
    cv(AtmosphereLayerSimple) layerWater = AtmosphereLayerSimple(
      waterScatterCoeff,
      waterScatterCoeff + waterAbsorptionCoeff
    );

    #define _waterPartialAbsorption() ( (underWater && !isWater) ? exp(-layerWater.transmittanceCoeff * distanceToFront) : vec3(1.0) )

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
      vec3 start;
      vec3 end;
      vec3 incr;
      vec3 pos;

      float stepSize;
    };

    #define _newRay(name) RayVolumetric name = RayVolumetric(vec3(0.0), vec3(0.0), vec3(0.0),vec3(0.0), 0.0);

    void createRay(io RayVolumetric ray, in vec3 start, in vec3 end, in vec2 dither) {
      ray.start = start;
      ray.end = end;

      ray.incr = (ray.end - ray.start) * volStepsRCP;
      ray.pos = (ray.incr * dither.x + ray.start);

      ray.stepSize = _length(ray.incr);
    }

    // LIGHTING
    float volumetrics_miePhase(in float theta, cin(float) G) {
      cv(float) g2 = G * G;
      cv(float) p1 = (0.75 * (1.0 - g2)) / (tau * (2.0 + g2));

      float p2 = (theta * theta + 1.0) * _pow(1.0 + g2 - 2.0 * G * theta, -1.5);
    
      return p1 * p2;
    }

    void computeShadowsAt(io float visibilityBack, io float visibilityFront, io float visibilityWater, io bool isTransparentShadow, io float objectID, io float depthFront, in RayVolumetric eyeRay, in RayVolumetric waterRay, in bool isTransparentPixel) {
      // COMPUTE EYE SHADOWS
      // COMPUTE SHADOW POSITION
      vec3 shadowEye    = worldToShadow(eyeRay.pos);
           shadowEye.xy = distortShadowPosition(shadowEye.xy, true);

      // SAMPLE FRONT DEPTH
      depthFront = texture2DLod(shadowtex0, shadowEye.xy, 0).x;

      // COMPUTE SHADOW VISIBILITY
      visibilityBack = _cutShadow(compareShadowDepth(texture2DLod(shadowtex1, shadowEye.xy, 0).x, shadowEye.z));
      visibilityFront = _cutShadow(compareShadowDepth(depthFront, shadowEye.z));

      // COMPUTE TRANSPARENT SHADOW MASK
      isTransparentShadow = visibilityBack - visibilityFront > 0.0;

      if(!isTransparentPixel) return;

      // COMPUTE WATER SHADOW
      vec3 shadowWater    = worldToShadow(waterRay.pos);
           shadowWater.xy = distortShadowPosition(shadowWater.xy, true);

      visibilityWater = _cutShadow(compareShadowDepth(texture2DLod(shadowtex1, shadowWater.xy, 0).x, shadowWater.z));
    }

    // OPTICAL DEPTH FUNCTIONS
    float opticalDepthAir(in vec3 world) {
      return exp2(-world.y * 0.001) * 10.0;
    }

    float opticalDepthFog(in vec3 world) {
      return exp2(-_max0(world.y - SEA_LEVEL) * 0.5) * 0.2;
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
      bool isTransparentPixel = (!underWater && positionData.depthBack > positionData.depthFront && maskList.water) || (underWater);

      // COMPUTE PHASES
      float VoL = dot(normalize(positionData.viewBack), lightDirection);
      vec3 phase = vec3(phaseRayleigh(VoL), volumetrics_miePhase(VoL, 0.8), 0.5);

      // COMPUTE WORLD POSITIONS
      vec3 worldFront = viewToWorld(positionData.viewFront);
      vec3 worldBack  = viewToWorld(positionData.viewBack);

      // CREATE EYE RAY
      _newRay(eyeRay);
      createRay(eyeRay, gbufferModelViewInverse[3].xyz, worldBack, dither);

      // CREATE WATER RAY
      _newRay(waterRay);
      createRay(waterRay, (underWater) ? gbufferModelViewInverse[3].xyz : worldFront, (underWater) ? worldFront : worldBack, dither);

      // COMPUTE DISTANCE TO FRONT
      float distanceToFront = _length(worldFront);

      // MARCH
      for(int i = 0; i < volSteps; i++, eyeRay.pos += eyeRay.incr, waterRay.pos += waterRay.incr) {
        // COMPUTE WORLD POSITION
        vec3 world = eyeRay.pos + cameraPosition;

        // COMPUTE DISTANCE TO RAY
        float distanceToRay = _length(eyeRay.pos);

        // COMPUTE STEP MASKS
        bool isTransparentStep = distanceToRay >= distanceToFront;
        bool isWaterStep = (!underWater && isTransparentStep && maskList.water) || (underWater && !isTransparentStep);

        // COMPUTE LIGHTING
        vec3 directLight = atmosphereLighting[0];
        vec3 skyLight = atmosphereLighting[1];

        float visibilityBack = 0.0;
        float visibilityFront = 0.0;
        float visibilityWater = 0.0;

        bool isTransparentShadow = false;
        float objectID = 0.0;

        float depthFront = 0.0;

        computeShadowsAt(visibilityBack, visibilityFront, visibilityWater, isTransparentShadow, objectID, depthFront, eyeRay, waterRay, isTransparentPixel);
        
        // COMPUTE ATMOSPHERE CONTRIBUTION
        // WATER
        if(isTransparentPixel) {
          computeAtmosphereContribution(scattering, backTransmittance, layerWater, true, distanceToFront, directLight * visibilityWater, skyLight * visibilityWater, 1.0, 2.0 * waterRay.stepSize);
        }

        if(isWaterStep) continue;

        // AIR
        {
          computeAtmosphereContribution(scattering, frontTransmittance, layerAir, false, distanceToFront, directLight * visibilityBack, skyLight * visibilityBack, phase, opticalDepthAir(world) * eyeRay.stepSize);
        }

        // FOG
        {
          computeAtmosphereContribution(scattering, frontTransmittance, layerFog, false, distanceToFront, directLight * 6.0 * visibilityBack, skyLight * visibilityBack, volumetrics_miePhase(_max0(VoL), 0.2), opticalDepthFog(world) * eyeRay.stepSize);
        }
      }
    }
  #endif

#endif /* INTERNAL_INCLUDED_DEFERRED_VOLUMETRICS */
