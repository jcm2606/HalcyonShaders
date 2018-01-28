/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_DEFERRED_REFRACTION
  #define INTERNAL_INCLUDED_DEFERRED_REFRACTION

  #include "/lib/common/Normals.glsl"

  vec4 getRefractedCoord(in PositionData positionData, in vec2 screenCoord, in vec3 normal, in float eta, in bool isWater, io float dist, io vec3 hit, io bool isTransparent) {
    isTransparent = false;

    #ifndef REFRACTION
      return vec4(screenCoord, 0.0, 0.0);
    #endif

    #define refractedVector positionData.viewFront

    vec3 direction = refract(normalize(refractedVector), normalize(normal), eta);
    
    dist = _distance(positionData.viewBack, positionData.viewFront);

    hit = direction * saturate(dist) + refractedVector;

    vec4 hitCoord = vec4(viewToClip(hit), 0.0); 

    if(isWater) hitCoord.xy += getNormal(viewToWorld(positionData.viewFront) + cameraPosition, OBJECT_WATER).xy * 0.02 * _min(16.0, dist);

    float hitMaskY = smoothstep(0.7, 1.0, 1.0 - hitCoord.y) + smoothstep(0.7, 1.0, hitCoord.y);
    float hitMaskX = smoothstep(0.9, 1.0, abs(hitCoord.x * 2.0 - 1.0));

    hitCoord.y = mix(hitCoord.y, screenCoord.y, hitMaskY);
    hitCoord.x = mix(hitCoord.x, screenCoord.x, hitMaskX);

    hitCoord.z = texture2D(depthtex1, hitCoord.xy).x;
    hit.z = _linearDepth(hitCoord.z);

    hitCoord.w = texture2D(depthtex0, hitCoord.xy).x;

    isTransparent = hitCoord.z != hitCoord.w;

    return hitCoord;

    #undef refractedVector
  }

  vec3 getRefractedBackground(in vec3 background, in vec2 hitCoord, in bool isTransparent) {
    return (isTransparent) ? texture2D(colortex0, hitCoord).rgb : background;
  }

#endif /* INTERNAL_INCLUDED_DEFERRED_REFRACTION */
