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

    return ambientLighting * weight * SKY_LIGHT_STRENGTH;
  }

  vec3 getFinalShading(out vec4 highlightTint, io GbufferObject gbuffer, io MaskObject mask, io PositionObject position, in vec2 screenCoord, in vec3 albedo, in mat2x3 atmosphereLighting) {
    //return getAmbientLighting(position, screenCoord);

    NewShadowObject(shadowObject);

    float cloudShadow = getCloudShadow(viewToWorld(position.viewBack) + cameraPosition, wLightVector);

    getShadows(shadowObject, position.viewBack, cloudShadow, false);

    highlightTint = vec4(mix(vec3(1.0), shadowObject.colour, shadowObject.difference), shadowObject.occlusionBack);

    #ifdef VISUALISE_PCSS_EDGE_PREDICTION
      if(screenCoord.x > 0.5) return vec3(shadowObject.edgePrediction);
    #endif

    //vec3 direct = atmosphereLighting[0] * shadowObject.occlusionBack * mix(vec3(shadowObject.occlusionFront), shadowObject.colour, shadowObject.difference) * getDirectShading(gbuffer, mask, position);
    vec3 direct  = atmosphereLighting[0];
         direct *= mix(vec3(shadowObject.occlusionFront), shadowObject.colour, shadowObject.difference);
         direct *= getDirectShading(gbuffer, mask, position);
         direct *= cloudShadow;
         direct *= shadowObject.occlusionBack;

    vec3 sky  = atmosphereLighting[1];
         sky *= getAmbientLighting(position, screenCoord);
         sky *= getRawSkyLightmap(gbuffer.skyLight);

    vec3 block  = blockLightColour;
         block *= max(((mask.emissive) ? 32.0 : 1.0) * gbuffer.emission, getBlockLightmap(gbuffer.blockLight));

    return albedo * (direct + sky + block);
  }

#endif /* INTERNAL_INCLUDED_FORWARD_SHADING */
