/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_DEFERRED_VOLUMETRICS
  #define INTERNAL_INCLUDED_DEFERRED_VOLUMETRICS

  #if   PROGRAM == COMPOSITE0
    #include "/lib/common/util/ShadowTransform.glsl"

    #include "/lib/common/Lightmaps.glsl"

    // OPTIONS
    c(int) steps = 12;
    cRCP(float, steps);
 
    c(float) absorptionCoeff = 2.0;

    // OPTICAL DEPTH
    float getHeightFog(in vec3 world) {
      #ifndef FOG_LAYER_HEIGHT
        return 0.0;
      #endif

      return exp2(-max0(world.y - MC_SEA_LEVEL) * FOG_LAYER_HEIGHT_FALLOFF) * FOG_LAYER_HEIGHT_DENSITY;
    }

    float getSheetFog(in vec3 world) {
      #ifndef FOG_LAYER_SHEET
        return 0.0;
      #endif

      c(int) octaves = FOG_LAYER_SHEET_OCTAVES;
      cRCP(float, octaves);

      float opticalDepth = 0.0;

      c(mat2) rot = rot2(-0.7);

      vec3 position = world * 0.3 * vec3(1.0, 2.0, 1.0);

      float weight = 1.0;

      c(vec2) windDir = vec2(0.0, 1.0);
      vec3 wind = vec3(windDir.x, 0.0, windDir.y) * frametime;
      float windSpeed = 0.4;

      for(int i = 0; i < octaves; i++) {
        opticalDepth += texnoise3D(noisetex, position + wind * windSpeed) * weight;
        
        position *= 2.7;
        position.xz *= rot;
        position.xy *= rot;
        windSpeed *= 1.1;
        weight *= 0.5;
      }

      opticalDepth -= 0.7;
      opticalDepth  = max0(opticalDepth);

      opticalDepth *= FOG_LAYER_SHEET_DENSITY;

      return exp2(-abs(world.y - MC_SEA_LEVEL) * FOG_LAYER_SHEET_FALLOFF) * opticalDepth;
    }

    float getRainFog(in vec3 world) {
      #ifndef FOG_LAYER_RAIN
        return 0.0;
      #endif

      return rainStrength * FOG_LAYER_RAIN_MULTIPLIER;
    }

    float getWaterFog(in float opticalDepth, in vec3 world, in bool differenceMask, in bool isWater) {
      #ifndef FOG_LAYER_WATER
        return 0.0;
      #endif

      return (differenceMask && isWater) ? FOG_LAYER_WATER_DENSITY : opticalDepth;
    }

    float getOpticalDepth(in vec3 world, in float eBS, in float objectID, in bool differenceMask, in bool isWater) {
      float opticalDepth = 0.0;

      opticalDepth += getHeightFog(world);
      opticalDepth += getSheetFog(world);
      opticalDepth += getRainFog(world);

      opticalDepth  = getWaterFog(opticalDepth, world, differenceMask, isWater);

      return opticalDepth * 0.01;
    }

    // MARCHER
    struct Ray {
      vec3 start;
      vec3 end;
      vec3 pos;
      vec3 incr;
      float dist;
    };

    struct RayVol {
      vec3 origin;
      vec3 target;
      vec3 dir;
      vec3 pos;
      vec3 incr;

      float dist;
    };

    #define getRayDirection(ray) ( normalize(ray.target - ray.origin) )
    #define getRayDistance(ray) ( distance(ray.target, ray.origin) )
    #define getRayIncrement(ray) ( ray.dir * ray.dist * stepsRCP )

    float volVisibilityCheck(in vec3 ray, in vec3 dir, in float odAtStart, in float visDensity, in float dither, in float stepSize, in float eBS, const int samples) {
      const float visStepSizeScale = 1.0 / (float(samples) + 0.5);
      float visStepSize = stepSize * visStepSizeScale;

      dir *= visStepSize;
      ray += dither * dir;

      float opticalDepth = 0.5 * odAtStart;

      for(int i = 0; i < samples; i++, ray += dir) {
        opticalDepth -= getOpticalDepth(ray, eBS, 0.0, false, false);
      }

      return clamp01(exp((absorptionCoeff * visDensity) * visStepSize * (opticalDepth)));
    }

    float volumetrics_miePhase(in float theta, cin(float) G) {
      c(float) gg = G * G;
      c(float) p1 = (0.75 * (1.0 - gg)) / (tau * (2.0 + gg));
      float p2 = (theta * theta + 1.0) * pow(1.0 + gg - 2.0 * G * theta, -1.5);
    
      return p1 * p2;
    }

    vec4 getVolumetrics(io GbufferObject gbuffer, io PositionObject position, io MaskObject mask, in vec2 screenCoord, in mat2x3 atmosphereLighting) {
      #ifndef VOLUMETRICS
        return vec4(0.0, 0.0, 0.0, 1.0);
      #endif

      vec4 volumetrics = vec4(0.0, 0.0, 0.0, 1.0);

      #define scattering volumetrics.rgb
      #define transmittance volumetrics.a

      // DEFINE SMOOTHED EYE BRIGHTNESS
      float eBS = getRawSkyLightmap(getEBS().y);

      // DEFINE SKY MASK
      bool isSky = !getLandMask(position.depthBack);

      // DEFINE WORLD TO SHADOW MATRIX
      mat4 matrixWorldToShadow = shadowProjection * shadowModelView;

      // DEFINE DITHER
      float dither = bayer128(gl_FragCoord.xy);

      // DEFINE RAY OBJECTS
      RayVol viewRay, worldRay, shadowRay;

      // POPULATE RAY OBJECTS
      // VIEW
      c(float) skyDistance = 64.0;
      viewRay.origin = vec3(0.0);
      viewRay.target = position.viewPositionBack;
      viewRay.dir = getRayDirection(viewRay);
      viewRay.dist = getRayDistance(viewRay);
      viewRay.incr = getRayIncrement(viewRay);
      viewRay.pos = viewRay.incr * dither + viewRay.origin;

      // WORLD
      worldRay.origin = viewToWorld(viewRay.origin);
      worldRay.target = viewToWorld(viewRay.target);
      worldRay.dir = getRayDirection(worldRay);
      worldRay.dist = getRayDistance(worldRay);
      worldRay.incr = getRayIncrement(worldRay);
      worldRay.pos = worldRay.incr * dither + worldRay.origin;

      // SHADOW
      c(vec3) shadowRayScale = vec3(1.0, 1.0, shadowDepthMult);
      shadowRay.origin = transMAD(matrixWorldToShadow, worldRay.origin) * shadowRayScale;
      shadowRay.target = transMAD(matrixWorldToShadow, worldRay.target) * shadowRayScale;
      shadowRay.dir = getRayDirection(shadowRay);
      shadowRay.dist = getRayDistance(shadowRay);
      shadowRay.incr = getRayIncrement(shadowRay);
      shadowRay.pos = shadowRay.incr * dither + shadowRay.origin;

      // DEFINE MIE TAIL
      float miePhase = volumetrics_miePhase((dot(viewRay.dir, lightVector)), 0.2) * 2.0;

      // DEFINE STEP SIZE
      float stepSize = flength(worldRay.incr);

      // MARCH
      for(int i = 0; i < steps; i++, viewRay.pos += viewRay.incr, worldRay.pos += worldRay.incr, shadowRay.pos += shadowRay.incr) {
        // DEFINE POSITIONS
        vec3 shadow = vec3(distortShadowPosition(shadowRay.pos.xy, 0), shadowRay.pos.z) * 0.5 + 0.5;
        vec3 world = worldRay.pos + cameraPosition;

        // GET RAW FRONT SHADOW DEPTH
        float depthFront = texture2DLod(shadowtex0, shadow.xy, 0).x;

        // GET SHADOW VISIBILITY VALUES
        float visibilityBack = CutShadow(compareShadow(texture2DLod(shadowtex1, shadow.xy, 0).x, shadow.z));
        float visibilityFront = CutShadow(compareShadow(depthFront, shadow.z));

        // SKY VISIBILITY OVERRIDE
        if(isSky && (any(greaterThan(shadow.xy, vec2(1.0))) || any(lessThan(shadow.xy, vec2(0.0))))) {
          visibilityBack = 1.0;
          visibilityFront = 1.0;
        }

        // CLAMP SHADOW VISIBILITY VALUES
        visibilityBack = min1(visibilityBack);
        visibilityFront = min1(visibilityFront);

        // DEFINE DIFFERENCE MASK
        bool differenceMask = visibilityBack - visibilityFront > 0.0;

        // DEFINE DISTANCES
        float distanceToSurface = max0(shadow.z - depthFront) * shadowDepthBlocks;

        // GET SHADOW OBJECT ID
        float objectID = texture2DLod(shadowcolor1, shadow.xy, 0).a * objectIDRange;

        // DEFINE OBJECT ID MASKS
        bool isWater = comparef(objectID, OBJECT_WATER, ubyteMaxRCP);

        // GET OPTICAL DEPTH
        float opticalDepth = getOpticalDepth(world, eBS, objectID, differenceMask, isWater);

        // GET VOLUME VISIBILITY
        #ifdef FOG_LIGHTING_DIRECT
          float visibilityDirect = volVisibilityCheck(world, wLightVector, opticalDepth, 0.7, dither, stepSize, eBS, FOG_LIGHTING_DIRECT_STEPS);
        #else
          float visibilityDirect = 1.0;
        #endif

        #ifdef FOG_LIGHTING_SKY
          float visibilitySky = volVisibilityCheck(world, vec3(0.0, 1.0, 0.0), opticalDepth, 0.2, dither, stepSize, eBS, FOG_LIGHTING_SKY_STEPS);
        #else
          float visibilitySky = 1.0;
        #endif

        // GET CLOUD SHADOW
        float cloudShadow = getCloudShadow(world);

        // OCCLUDE RAY
        vec2 rayVisibility = vec2(1.0);

        #define directVisibility rayVisibility.x
        #define skyVisibility rayVisibility.y

        directVisibility *= cloudShadow * miePhase * visibilityDirect * visibilityBack;
        skyVisibility *= (cloudShadow * 0.75 + 0.25) * visibilitySky;

        #if   FOG_OCCLUSION_SKY == 1
          skyVisibility *= visibilityBack;
        #elif FOG_OCCLUSION_SKY == 2
          // TODO: Sky light occlusion approximation.
        #endif

        // ILLUMINATE RAY
        vec3 lightColour = atmosphereLighting[0] * directVisibility + atmosphereLighting[1] * skyVisibility;
        vec3 rayColour = lightColour;

        #undef directVisibility
        #undef skyVisibility

        // GET INTERACTION WITH FRONT SHADOWS
        rayColour *= (differenceMask) ? toShadowHDR(texture2DLod(shadowcolor0, shadow.xy, 0).rgb) : vec3(1.0);

        // GET INTERACTION WITH WATER VOLUME
        // WATER SURFACE -> RAY
        rayColour = (differenceMask && isWater) ? interactWater(rayColour, distanceToSurface) : rayColour;

        // RAY -> EYE
        vec3 waterAbsorptionOrigin = (isEyeInWater == 0) ? position.viewPositionFront : viewRay.origin;
        vec3 waterAbsorptionTarget = (!differenceMask && mask.water && isEyeInWater == 1) ? position.viewPositionFront : viewRay.pos;

        rayColour = ((differenceMask && isWater) || (isEyeInWater == 1 && mask.water)) ? interactWater(rayColour, distance(waterAbsorptionOrigin, waterAbsorptionTarget)) : rayColour;

        // ACCUMULATE RAY
        scattering += rayColour * transmittedScatteringIntegral(opticalDepth * stepSize, absorptionCoeff) * transmittance;
        transmittance *= exp(-absorptionCoeff * opticalDepth * stepSize);
      }

      #undef scattering
      #undef transmittance

      return volumetrics;
    }
  #elif PROGRAM == COMPOSITE1
    #include "/lib/deferred/Refraction.glsl"

    vec3 drawVolumetrics(io GbufferObject gbuffer, io PositionObject position, in vec3 frame, in vec2 screenCoord) {
      #ifndef VOLUMETRICS
        return frame;
      #endif

      vec2 originalCoord = screenCoord;
      float refractDist = 0.0;
      screenCoord = getRefractPos(refractDist, screenCoord, position.viewPositionBack, position.viewPositionFront, gbuffer.normal).xy;

      if(refractDist == 0.0 || texture2D(depthtex1, screenCoord.xy).x < position.depthFront) screenCoord = originalCoord;

      c(int) width = 3;
      cRCP(float, width);
      c(float) filterRadius = 0.003;
      c(vec2) filterOffset = vec2(filterRadius) * widthRCP;

      c(float) weight = 1.0 / pow(float(width) * 2.0 + 1.0, 2.0);

      vec2 radius = filterOffset;

      vec4 volumetrics = vec4(0.0);

      for(int i = -width; i <= width; i++) {
        for(int j = -width; j <= width; j++) {
          vec2 offset = vec2(i, j) * radius + screenCoord;

          //if(texture2DLod(depthtex1, offset).x - position.depthBack > 0.001) continue;

          volumetrics += texture2DLod(colortex4, offset, 2);
        }
      }

      volumetrics *= weight;

      return frame * volumetrics.a + volumetrics.rgb;
    }
  #endif

#endif /* INTERNAL_INCLUDED_DEFERRED_VOLUMETRICS */
