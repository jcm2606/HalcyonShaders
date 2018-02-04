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

    vec3 drawVolumetricEffects(in GbufferData gbufferData, in PositionData positionData, in BufferList bufferList, in MaskList maskList, in vec3 background, in vec2 screenCoord, in mat2x3 atmosphereLighting, in float highlightOcclusion, in vec2 dither) {
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
        
        volumetrics[0] = texture2DLod(colortex4, offset * scale + screenCoord, 1).rgb * samplesRCP + volumetrics[0];
        volumetrics[1] = mix(texture2DLod(colortex5, offset * scale + screenCoord, volumetricsLOD).rgb, bufferList.tex5.rgb, weight) * samplesRCP + volumetrics[1];
        volumetrics[2] = mix(texture2DLod(colortex6, offset * scale + screenCoord, volumetricsLOD).rgb, bufferList.tex6.rgb, weight) * samplesRCP + volumetrics[2];
      }

      // DRAW TRANSPARENT ABSORPTION
      if(positionData.depthBack > positionData.depthFront && !maskList.water) background *= gbufferData.albedo * (1.0 - bufferList.tex7.a);

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

    #include "/lib/common/Clouds.glsl"
  
    /*
      CONSTANTS
    */
    cv(int) volSteps = 6;
    cRCP(float, volSteps);

    /*
      RAY
    */
    struct RayVolumetric {
      vec3 increment;
      vec3 position;
      
      float incrementLength;
    };

    #define _newRay(name) RayVolumetric name = RayVolumetric(vec3(0.0), vec3(0.0), 0.0)

    void computeRay(io RayVolumetric ray, in vec3 start, in vec3 end, in vec2 dither) {
      ray.increment = (end - start) * volStepsRCP;
      ray.position  = ray.increment * dither.x + start;

      ray.incrementLength = _length(ray.increment);
    }

    /*
      ATMOSPHERE LAYER
    */
    const struct AtmosphereLayerComplex {
      mat2x3 scatterCoeff;
      mat2x3 transmittanceCoeff;
    };

    const struct AtmosphereLayerSimple {
      vec3 scatterCoeff;
      vec3 transmittanceCoeff;
    };

    cv(AtmosphereLayerComplex) layerAir = AtmosphereLayerComplex(
      mat2x3(rayleighCoeff, vec3(mieCoeff)),
      mat2x3(rayleighCoeff + ozoneCoeff, vec3(mieCoeff) * 1.11)
    );

    cv(AtmosphereLayerSimple) layerFog = AtmosphereLayerSimple(
      fogScatterCoeff,
      fogTransmittanceCoeff
    );

    cv(AtmosphereLayerSimple) layerWater = AtmosphereLayerSimple(
      waterScatterCoeff,
      waterTransmittanceCoeff
    );
    
    #define _waterPartialAbsorb() ( (underWater && !isWaterPixel) ? exp(-layerWater.transmittanceCoeff * distanceToFront) : vec3(1.0) )

    void computeAtmosphereContribution(cin(AtmosphereLayerComplex) atmosphereLayer, io vec3 scatter, io vec3 absorb, in vec3 scatterAbsorb, in float opticalDepth, in vec3 directLight, in vec3 skyLight, in vec3 phase, in float distanceToFront, in bool isWaterPixel) {
      mat2x3 scatterCoeff = mat2x3(
        atmosphereLayer.scatterCoeff[0] * transmittedScatteringIntegral(opticalDepth, atmosphereLayer.transmittanceCoeff[0]),
        atmosphereLayer.scatterCoeff[1] * transmittedScatteringIntegral(opticalDepth, atmosphereLayer.transmittanceCoeff[1])
      );

      directLight = directLight * (scatterCoeff * phase.xy);
      skyLight    = skyLight * (scatterCoeff * phase.zz);

      scatter += (directLight + skyLight) * absorb * scatterAbsorb * _waterPartialAbsorb(); // TODO: Partial water absorption.
      absorb  *= exp(-atmosphereLayer.transmittanceCoeff * vec2(opticalDepth));
    }

    void computeAtmosphereContribution(cin(AtmosphereLayerSimple) atmosphereLayer, io vec3 scatter, io vec3 absorb, in vec3 scatterAbsorb, in float opticalDepth, in vec3 directLight, in vec3 skyLight, in float phase, in float distanceToFront, in bool isWaterPixel) {
      vec3 scatterCoeff = atmosphereLayer.scatterCoeff * transmittedScatteringIntegral(opticalDepth, atmosphereLayer.transmittanceCoeff);

      directLight = directLight * scatterCoeff * phase;
      skyLight    = skyLight * scatterCoeff;

      scatter += (directLight + skyLight) * absorb * scatterAbsorb * _waterPartialAbsorb(); // TODO: Partial water absorption.
      absorb  *= exp(-atmosphereLayer.transmittanceCoeff * opticalDepth);
    }

    #undef _waterPartialAbsorb

    /*
      LIGHTING
    */
    float volumetrics_miePhase(in float theta, cin(float) G) {
      cv(float) g2 = G * G;
      cv(float) p1 = (0.75 * (1.0 - g2)) / (tau * (2.0 + g2));

      cv(float) g2_p2 = 1.0 + g2;
      cv(float) G_p2 = 2.0 * G;

      float p2 = (theta * theta + 1.0) * _pow(g2_p2 - G_p2 * theta, -1.5);

      return p1 * p2;
    }

    void computeShadows(io vec2 visibility, io vec3 shadowColour, io float objectID, io bool isTransparentShadow, in vec3 world, in vec3 shadow, in bool isSkyPixel, in bool isWaterPixel) {
      #define visibilityFront visibility.x
      #define visibilityBack  visibility.y

      // DISTORT SHADOW POSITION
      shadow.xy = distortShadowPosition(shadow.xy, true);

      // SAMPLE FRONT DEPTH
      float depthFront = texture2D(shadowtex0, shadow.xy).x;

      // COMPUTE SHADOW VISIBILITY
      visibilityFront = _cutShadow(compareShadowDepth(depthFront, shadow.z));
      visibilityBack  = _cutShadow(compareShadowDepth(texture2D(shadowtex1, shadow.xy).x, shadow.z));

      // OVERWRITE SHADOW VISIBILITY ON INVALID SKY STEP
      if(isSkyPixel && (any(greaterThan(shadow.xy, vec2(1.0))) || any(lessThan(shadow.xy, vec2(0.0)))))
        visibility = vec2(1.0);

      // SET SHADOW COLOUR TO WHITE
      shadowColour = vec3(1.0);

      // COMPUTE TRANSPARENT SHADOW MASK
      isTransparentShadow = visibilityBack - visibilityFront > 0.0;
      
      if(!isTransparentShadow)
        return;

      // SAMPLE SHADOW COLOUR
      vec4 shadowSample = texture2D(shadowcolor0, shadow.xy);
      shadowColour = shadowSample.rgb;

      // EARLY EXIT IF NOT WATER PIXEL
      if(!isWaterPixel)
        return;

      // ABSORB SHADOW COLOUR
      float waterDepth = depthFront * 8.0 - 4.0;
            waterDepth = waterDepth * shadowProjectionInverse[2].z + shadowProjectionInverse[3].z;
            waterDepth = (_transMAD(shadowModelView, world)).z - waterDepth;

      if(isWaterPixel && waterDepth < 0.0) shadowColour *= exp(layerWater.transmittanceCoeff * waterDepth);

      #undef visibilityFront
      #undef visibilityBack
    }

    /*
      OPTICAL DEPTH
    */
    float opticalDepthAir(in vec3 world) {
      return 20.0;
    }

    float opticalDepthFog(in vec3 world) {
      return 0.02;
    }

    float opticalDepthWater(in vec3 world) {
      return 1.0;
    }

    /*
      PASS FUNCTION
    */
    void computeVolumetricPass(io vec3 scatter, io vec3 absorb, in vec3 scatterAbsorb, in vec3 start, in vec3 end, in vec4 albedo, in vec2 screenCoord, in vec4 hitCoord, in vec2 dither, in mat2x3 atmosphereLighting, in float VoL, in float distanceToFront, in bool isBackPass, in bool isSkyPixel, in bool isWaterPixel) {
      // COMPUTE PHASES
      vec3 phaseAir = vec3(phaseRayleigh(VoL), volumetrics_miePhase(VoL, 0.8), 0.5);

      float phaseFog = volumetrics_miePhase(VoL, 0.6) * 2.0 + 0.5;
      
      // CREATE RAYS
      _newRay(worldRay);
      computeRay(worldRay, start, end, dither);

      _newRay(shadowRay);
      computeRay(shadowRay, worldToShadow(start), worldToShadow(end), dither);

      // APPLY SHADOW BIAS TO SHADOW RAY
      shadowRay.position.z = 0.75 * shadowMapResolutionRCP + shadowRay.position.z;

      // ADD CAMERA POSITION TO WORLD
      worldRay.position += cameraPosition;

      // COMPUTE PIXEL MASKS
      isWaterPixel = isBackPass && (isWaterPixel || underWater);

      for(int i = 0; i < volSteps; i++, worldRay.position += worldRay.increment, shadowRay.position += shadowRay.increment) {
        // COMPUTE LIGHTING
        vec3 directLight = atmosphereLighting[0];
        vec3 skyLight    = atmosphereLighting[1];

        vec3 shadowColour = vec3(0.0);

        vec2 visibility = vec2(0.0);

        #define visibilityFront visibility.x
        #define visibilityBack  visibility.y

        float objectID = 0.0;

        bool isTransparentShadow = false;

        computeShadows(visibility, shadowColour, objectID, isTransparentShadow, worldRay.position - cameraPosition, shadowRay.position, isSkyPixel, isWaterPixel);

        directLight *= shadowColour * visibilityBack;
        skyLight    *= shadowColour * visibilityBack;

        #undef visibilityFront
        #undef visibilityBack

        // COMPUTE CLOUD SHADOWS
        float cloudShadowDirect = getCloudShadow(worldRay.position, wLightDirection);
        float cloudShadowSky = 
        #ifdef CLOUD_SHADOW_SKY
          getCloudShadow(worldRay.position, vec3(0.0, 1.0, 0.0)) * CLOUD_SHADOW_SKY_INTENSITY + cloudShadowSkyIntensityInverse;
        #else
          1.0
        #endif
        ;

        directLight *= cloudShadowDirect;
        skyLight    *= cloudShadowSky;

        // COMPUTE ATMOSPHERE CONTRIBUTION
        // WATER
        if(isWaterPixel) {
          #ifdef VOLUMETRIC_WATER
            computeAtmosphereContribution(layerWater, scatter, absorb, scatterAbsorb, opticalDepthWater(worldRay.position) * worldRay.incrementLength, directLight, skyLight, 1.0, distanceToFront, isWaterPixel);
          #endif

          continue;
        }

        // AIR
        #ifdef ATMOSPHERIC_SCATTERING
          computeAtmosphereContribution(layerAir, scatter, absorb, scatterAbsorb, opticalDepthAir(worldRay.position) * worldRay.incrementLength, directLight, skyLight, phaseAir, distanceToFront, isWaterPixel);
        #endif

        // FOG
        #ifdef VOLUMETRIC_FOG
          computeAtmosphereContribution(layerFog, scatter, absorb, scatterAbsorb, opticalDepthFog(worldRay.position) * worldRay.incrementLength, directLight, skyLight, phaseFog, distanceToFront, isWaterPixel);
        #endif
      }

      if(isBackPass && !isWaterPixel) scatter *= albedo.rgb * (1.0 - albedo.a);
    }

    /*
      MAIN FUNCTION
    */
    void computeVolumetrics(in BufferList bufferList, in PositionData positionData, in GbufferData gbufferData, in MaskList maskList, io vec3 scatter, io vec3 frontAbsorption, io vec3 backAbsorption, in vec2 screenCoord, in vec4 hitCoord, in vec2 dither, in mat2x3 atmosphereLighting) {
      scatter         = vec3(0.0);
      frontAbsorption = vec3(1.0);
      backAbsorption  = vec3(1.0);

      #if !defined(VOLUMETRICS) || ( !defined(ATMOSPHERIC_SCATTERING) && !defined(VOLUMETRIC_FOG) && !defined(VOLUMETRIC_WATER) )
        return;
      #endif

      // COMPUTE BACK CLIP POSITION
      vec3 clipBack   = (hitCoord.z == hitCoord.w) ? vec3(screenCoord, positionData.depthBack) : hitCoord.xyz;

      // COMPUTE WORLD POSITIONS
      vec3 worldEye   = gbufferModelViewInverse[3].xyz;
      vec3 worldFront = viewToWorld(positionData.viewFront);
      vec3 worldBack  = viewToWorld(clipToView(clipBack.xy, clipBack.z));

      // COMPUTE DISTANCE TO FRONT
      float distanceToFront = _length(worldFront);

      // COMPUTE PIXEL MASKS
      bool isSkyPixel = !_getLandMask(positionData.depthBack);

      // COMPUTE VoL
      float VoL = dot(normalize(worldBack), wLightDirection);

      // COMPUTE FRONT VOLUMETRICS PASS
      computeVolumetricPass(scatter, frontAbsorption, vec3(1.0), (underWater) ? worldFront : worldEye, (underWater) ? worldBack : worldFront, vec4(gbufferData.albedo, bufferList.tex7.a), screenCoord, hitCoord, dither, atmosphereLighting, VoL, distanceToFront, false, isSkyPixel, maskList.water);

      // COMPUTE BACK VOLUMETRICS PASS
      if((!underWater && positionData.depthBack > positionData.depthFront) || (underWater))
        computeVolumetricPass(scatter, backAbsorption, frontAbsorption, (underWater) ? worldEye : worldFront, (underWater) ? worldFront : worldBack, vec4(gbufferData.albedo, bufferList.tex7.a), screenCoord, hitCoord, dither, atmosphereLighting, VoL, distanceToFront, true, isSkyPixel, maskList.water);
    }
  #endif

#endif /* INTERNAL_INCLUDED_DEFERRED_VOLUMETRICS */
