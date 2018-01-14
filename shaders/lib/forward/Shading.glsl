/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_FORWARD_SHADING
  #define INTERNAL_INCLUDED_FORWARD_SHADING

  #include "/lib/common/Shadows.glsl"

  #include "/lib/common/DiffuseModel.glsl"

  #include "/lib/common/Lightmaps.glsl"

  float getDirectShading(io GbufferObject gbuffer, io MaskObject mask, io PositionObject position) {
    return (mask.foliage) ? 1.0 : lambert(normalize(position.viewBack), lightVector, normalize(gbuffer.normal), gbuffer.roughness);
  }

  vec3 getAmbientLighting(io PositionObject position, in vec2 screenCoord) {
    vec3 ambientLighting = vec3(0.0);

    cv(int) width = 3;
    cRCP(float, width);
    cv(float) filterRadius = 0.001;
    cv(vec2) filterOffset = vec2(filterRadius) * widthRCP;
    cv(vec2) radius = filterOffset;

    cv(float) weight = 1.0 / pow(float(width) * 2.0 + 1.0, 2.0);

    for(int i = -width; i <= width; i++) {
      for(int j = -width; j <= width; j++) {
        vec2 offset = vec2(i, j) * radius + screenCoord;

        if(texture2D(depthtex1, offset).x - position.depthBack > 0.001) continue;

        ambientLighting += texture2DLod(colortex4, offset, 0).rgb;
      }
    }

    return ambientLighting * weight;
  }

  vec3 getFinalShading(out vec4 highlightTint, io GbufferObject gbuffer, io MaskObject mask, io PositionObject position, in vec2 screenCoord, in vec3 albedo, in mat2x3 atmosphereLighting) {
    //return getAmbientLighting(position, screenCoord);

    NewShadowObject(shadowObject);

    vec3 world = viewToWorld(position.viewBack) + cameraPosition;
    vec3 wNormal = mat3(gbufferModelViewInverse) * gbuffer.normal;

    float directCloudShadow = getCloudShadow(world, wLightVector);
    float skyCloudShadow = getCloudShadow(world, vec3(0.0, 1.0, 0.0)) * 0.25 + 0.75;

    vec3 ambient = getAmbientLighting(position, screenCoord);

    getShadows(shadowObject, position.viewBack, directCloudShadow, false);

    highlightTint = vec4(mix(vec3(1.0), shadowObject.colour, shadowObject.difference), shadowObject.occlusionBack);

    #ifdef VISUALISE_PCSS_EDGE_PREDICTION
      if(screenCoord.x > 0.5) return vec3(shadowObject.edgePrediction);
    #endif

    //vec3 direct = atmosphereLighting[0] * shadowObject.occlusionBack * mix(vec3(shadowObject.occlusionFront), shadowObject.colour, shadowObject.difference) * getDirectShading(gbuffer, mask, position);
    vec3 direct  = atmosphereLighting[0];
         direct *= mix(vec3(shadowObject.occlusionFront), shadowObject.colour, shadowObject.difference);
         direct *= getDirectShading(gbuffer, mask, position);
         direct *= directCloudShadow;
         direct *= shadowObject.occlusionBack;

    cv(float) bounceLightMaxDistanceScale = 1.0 / 1024.0;
    vec3 bounce  = atmosphereLighting[0];
         bounce *= 3.0;
         bounce *= mix(
           max0(dot(wNormal, -reflect(wLightVector, vec3(0.0, 0.0, 1.0)))),
           max0(dot(wNormal,  reflect(wLightVector, vec3(0.0, 0.0, 1.0)))),
           pow(abs((sunAngle * 2.0) * 2.0 - 1.0), 0.5)
         ) * 0.75 + 0.25;
         bounce *= pow(gbuffer.skyLight, 8.0);
         bounce *= directCloudShadow;
         bounce *= ambient;
         bounce *= shadowObject.bounceWeight;
         //if(screenCoord.x > 0.5) bounce *= 0.0;

    vec3 sky  = atmosphereLighting[1];
         sky *= ambient;
         sky *= getRawSkyLightmap(gbuffer.skyLight);
         sky *= skyCloudShadow;
         sky *= SKY_LIGHT_STRENGTH;

    vec3 block  = blockLightColour;
         block *= max(((mask.emissive) ? 32.0 : 1.0) * gbuffer.emission, getBlockLightmap(gbuffer.blockLight));

    return albedo * (direct + bounce + sky + block);
  }

#endif /* INTERNAL_INCLUDED_FORWARD_SHADING */
