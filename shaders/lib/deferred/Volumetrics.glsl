/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_DEFERRED_VOLUMETRICS
  #define INTERNAL_INCLUDED_DEFERRED_VOLUMETRICS

  #if   PROGRAM == COMPOSITE0
    #ifndef INTERNAL_INCLUDED_UTIL_SHADOWTRANSFORM
      #include "/lib/common/util/ShadowTransform.glsl"
    #endif

    // MARCHER
    c(int) steps = 12;
    cRCP(float, steps);

    struct Ray {
      vec3 start;
      vec3 end;
      vec3 pos;
      vec3 incr;
      float dist;
    };

    #define getRayIncrement(ray) ( normalize(ray.end - ray.start) * ray.dist * stepsRCP )

    vec4 getVolumetrics(io GbufferObject gbuffer, io PositionObject position, io MaskObject mask, in vec2 screenCoord, in mat2x3 atmosphereLighting) {
      #ifndef VOLUMETRICS
        return vec4(0.0);
      #endif

      vec4 volumetrics = vec4(0.0);

      // CREATE MIE TAIL
      float mieTail = dot(normalize(position.viewPositionBack), lightVector) * 0.5 + 0.75;

      // CREATE EYE BRIGHTNESS SMOOTH
      float ebs = pow(getEBS().y, 6.0);

      // CREATE DITHER PATTERN
      float dither = bayer64(ivec2(int(screenCoord.x * viewWidth), int(screenCoord.y * viewHeight)));

      // CREATE WORLD TO SHADOW MATRIX
      mat4 matrixWorldToShadow = shadowProjection * shadowModelView;

      // CREATE RAYS
      Ray viewRay, worldRay, shadowRay;

      // VIEW
      viewRay.start = vec3(0.0);
      viewRay.end = (!getLandMask(position.depthBack)) ? clipToView(screenCoord, getExpDepth(48.0)) : position.viewPositionBack;
      viewRay.dist = distance(viewRay.start, viewRay.end);
      viewRay.incr = getRayIncrement(viewRay);
      viewRay.pos = viewRay.incr * dither + viewRay.start;

      // WORLD
      worldRay.start = viewToWorld(viewRay.start);
      worldRay.end = viewToWorld(viewRay.end);
      worldRay.dist = distance(worldRay.start, worldRay.end);
      worldRay.incr = getRayIncrement(worldRay);
      worldRay.pos = worldRay.incr * dither + worldRay.start;

      // SHADOW
      shadowRay.start = transMAD(matrixWorldToShadow, worldRay.start);
      shadowRay.end = transMAD(matrixWorldToShadow, worldRay.end);
      shadowRay.dist = distance(shadowRay.start, shadowRay.end);
      shadowRay.incr = getRayIncrement(shadowRay);
      shadowRay.pos = shadowRay.incr * dither + shadowRay.start;

      // MARCH VOLUME
      float weight = flength(shadowRay.incr);

      for(int i = 0; i < steps; i++, viewRay.pos += viewRay.incr, worldRay.pos += worldRay.incr, shadowRay.pos += shadowRay.incr) {
        // CREATE POSITIONS
        vec3 shadow = vec3(distortShadowPosition(shadowRay.pos.xy, 0), shadowRay.pos.z) * 0.5 + 0.5;
        vec3 world = worldRay.pos + cameraPosition;

        // STORE RAW FRONT SHADOW DEPTH
        float depthFront = texture2DLod(shadowtex0, shadow.xy, 0).x;

        // STORE OCCLUSION SCALARS
        float occlusionBack = compareShadow(texture2DLod(shadowtex1, shadow.xy, 0).x, shadow.z);
        float occlusionFront = compareShadow(depthFront, shadow.z);

        // CREATE DISTANCES
        float distSurfaceToRay = max0(shadow.z - depthFront) * shadowDepthBlocks;

        // STORE OBJECT ID
        float objectID = texture2DLod(shadowcolor1, shadow.xy, 0).a * objectIDRange;
        bool water = comparef(objectID, OBJECT_WATER, ubyteMaxRCP);

        // BEGIN RAY VISIBILITY
        vec2 visibility = vec2(0.0);

        // PARTICIPATING MEDIA
        // HEIGHT FOG
        visibility += exp2(-max0(world.y - MC_SEA_LEVEL) * 0.05) * 0.1;
        
        // VOLUME FOG
        // WATER
        visibility  = (occlusionBack - occlusionFront > 0.0 && water) ? vec2(0.5) : visibility;

        // OCCLUDE RAY
        visibility.x *= occlusionBack * mieTail;
        visibility.y *= mix(ebs, pow6(gbuffer.skyLight), pow4(distance(viewRay.start, viewRay.pos) / viewRay.dist));

        // BEGIN RAY COLOURING
        vec3 lightColour = atmosphereLighting[0] * visibility.x + (atmosphereLighting[1] * visibility.y);
        vec3 rayColour = lightColour;

        // COLOURED SHADOW TINT
        rayColour *= (occlusionBack - occlusionFront > 0.0) ? toShadowHDR(texture2DLod(shadowcolor0, shadow.xy, 0).rgb) : vec3(1.0);

        // BEGIN RAY INTERACTION
        // WATER INTERACTION
        // SURFACE -> RAY
        rayColour = (occlusionBack - occlusionFront > 0.0 && water) ? interactWater(rayColour, distSurfaceToRay) : rayColour;

        // RAY -> EYE
        vec3 eyeAbsorptionStart = viewRay.start;
        vec3 eyeAbsorptionEnd = viewRay.end;

        //rayColour = ((occlusionBack - occlusionFront > 0.0 && water) || (isEyeInWater == 1 && mask.water)) ? interactWater(rayColour, distance(eyeAbsorptionStart, eyeAbsorptionEnd)) : rayColour;

        // ACCUMULATE RAYS
        volumetrics.rgb = rayColour * weight + volumetrics.rgb;
      }

      // TWEAK RESULTS
      // RETURN
      return vec4(volumetrics.rgb, 1.0);
    }
  #elif PROGRAM == COMPOSITE1
    vec3 drawVolumetrics(in vec3 frame, in vec2 screenCoord, in vec2 refractOffset) {
      #ifndef VOLUMETRICS
        return frame;
      #endif

      c(int) width = 3;
      cRCP(float, width);
      c(float) filterRadius = 0.002;
      c(vec2) filterOffset = vec2(filterRadius) * widthRCP;

      c(float) weight = 1.0 / pow(float(width) * 2.0 + 1.0, 2.0);

      vec2 radius = filterOffset;

      vec4 volumetrics = vec4(0.0);

      for(int i = -width; i <= width; i++) {
        for(int j = -width; j <= width; j++) {
          vec2 offset = vec2(i, j) * radius + screenCoord;

          volumetrics += texture2DLod(colortex4, offset, 2);
        }
      }

      volumetrics *= weight;

      return frame + volumetrics.rgb;
    }
  #endif

#endif /* INTERNAL_INCLUDED_DEFERRED_VOLUMETRICS */
