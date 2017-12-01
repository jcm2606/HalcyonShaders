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
 
    c(float) absorptionCoeff = 0.02;

    // OPTICAL DEPTH
    float getHeightFog(in vec3 world) {
      return exp2(-max0(world.y - MC_SEA_LEVEL) * 0.01) * 0.02;
    }

    float getGroundFog(in vec3 world) {
      return exp2(-abs(world.y - MC_SEA_LEVEL) * 0.2) * 0.1;
    }

    float getRainFog(in vec3 world) {
      return rainStrength * 2.0;
    }

    float getWaterFog(in float opticalDepth, in vec3 world, in bool differenceMask, in bool isWater) {
      return (differenceMask && isWater) ? 1.0 : opticalDepth;
    }

    float getOpticalDepth(in vec3 world, in float eBS, in float objectID, in bool differenceMask, in bool isWater) {
      float opticalDepth = 0.0;

      opticalDepth += getHeightFog(world);
      opticalDepth += getGroundFog(world);
      opticalDepth += getRainFog(world);

      opticalDepth  = getWaterFog(opticalDepth, world, differenceMask, isWater);

      return opticalDepth;
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

      return exp((absorptionCoeff * visDensity) * visStepSize * opticalDepth);
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
      viewRay.target = (!getLandMask(position.depthBack)) ? clipToView(screenCoord, getExpDepth(skyDistance)) : position.viewPositionBack;
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
      shadowRay.origin = transMAD(matrixWorldToShadow, worldRay.origin);
      shadowRay.target = transMAD(matrixWorldToShadow, worldRay.target);
      shadowRay.dir = getRayDirection(shadowRay);
      shadowRay.dist = getRayDistance(shadowRay);
      shadowRay.incr = getRayIncrement(shadowRay);
      shadowRay.pos = shadowRay.incr * dither + shadowRay.origin;

      // DEFINE STEP SIZE
      float stepSize = flength(shadowRay.incr);

      // MARCH
      for(int i = 0; i < steps; i++, viewRay.pos += viewRay.incr, worldRay.pos += worldRay.incr, shadowRay.pos += shadowRay.incr) {
        // DEFINE POSITIONS
        vec3 shadow = vec3(distortShadowPosition(shadowRay.pos.xy, 0), shadowRay.pos.z * shadowDepthMult) * 0.5 + 0.5;
        vec3 world = worldRay.pos + cameraPosition;

        // GET RAW FRONT SHADOW DEPTH
        float depthFront = texture2DLod(shadowtex0, shadow.xy, 0).x;

        // GET SHADOW VISIBILITY VALUES
        float visibilityBack = CutShadow(compareShadow(texture2DLod(shadowtex1, shadow.xy, 0).x, shadow.z));
        float visibilityFront = CutShadow(compareShadow(depthFront, shadow.z));

        // DEFINE DIFFERENCE MASK
        bool differenceMask = visibilityBack - visibilityFront > 0.0;

        // DEFINE DISTANCES
        float distanceToSurface = max0(shadow.z - depthFront) * shadowDepthBlocks;

        // GET SHADOW OBJECT ID
        float objectID = texture2DLod(shadowcolor1, shadow.xy, 0).a * objectIDRange;

        // DEFINE OBJECT ID MASKS
        bool isWater = comparef(objectID, OBJECT_WATER, ubyteMaxRCP);

        // GET OPTICAL DEPTH
        float opticalDepth = getOpticalDepth(world, eBS, objectID, differenceMask, isWater) * stepSize;

        // GET VOLUME VISIBILITY
        //float visibilityLight = volVisibilityCheck(world, wLightVector, opticalDepth, 1.5, dither, stepSize, eBS, 6);

        // GET CLOUD SHADOW
        float cloudShadow = getCloudShadow(world);

        // OCCLUDE RAY
        vec2 rayVisibility = vec2(1.0);

        #define directVisibility rayVisibility.x
        #define skyVisibility rayVisibility.y

        directVisibility *= cloudShadow * visibilityBack;
        skyVisibility *= (cloudShadow * 0.75 + 0.25) * visibilityBack;//eBS;

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
        scattering += rayColour * transmittedScatteringIntegral(opticalDepth, 0.02) * transmittance;
        transmittance *= exp(-0.02 * opticalDepth);
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
