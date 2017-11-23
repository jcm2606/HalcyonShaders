/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_OPAQUE_SHADING
  #define INTERNAL_INCLUDED_OPAQUE_SHADING

  #include "/lib/opaque/Shadows.glsl"

  #include "/lib/common/DiffuseModel.glsl"

  #include "/lib/common/Lightmaps.glsl"

  float getDirectShading(io GbufferObject gbuffer, io MaskObject mask, io PositionObject position) {
    return (mask.foliage) ? 1.0 : lambert(normalize(position.viewPositionBack), lightVector, normalize(gbuffer.normal), gbuffer.roughness);
  }

  vec3 getFinalShading(out vec4 highlightTint, io GbufferObject gbuffer, io MaskObject mask, io PositionObject position, in vec2 screenCoord, in vec3 albedo, in mat2x3 atmosphereLighting) {
    NewShadowObject(shadowObject);

    getShadows(shadowObject, position.viewPositionFront, position.viewPositionBack);

    highlightTint = vec4(shadowObject.colour, shadowObject.occlusionBack);

    #ifdef VISUALISE_PCSS_EDGE_PREDICTION
      if(screenCoord.x > 0.5) return vec3(shadowObject.edgePrediction);
    #endif

    //vec3 direct = atmosphereLighting[0] * shadowObject.occlusionBack * mix(vec3(shadowObject.occlusionFront), shadowObject.colour, shadowObject.difference) * getDirectShading(gbuffer, mask, position);
    vec3 direct = atmosphereLighting[0];
    direct *= mix(vec3(shadowObject.occlusionFront), shadowObject.colour, shadowObject.difference);
    direct *= getDirectShading(gbuffer, mask, position);
    direct *= getCloudShadow(viewToWorld(position.viewPositionBack) + cameraPosition);
    direct *= shadowObject.occlusionBack;

    vec3 sky = atmosphereLighting[1] * getSkyLightmap(gbuffer.skyLight, gbuffer.normal);
    vec3 block = blockLightColour * max(((mask.emissive) ? 32.0 : 1.0) * gbuffer.emission, getBlockLightmap(gbuffer.blockLight));

    return albedo * (direct + sky + block);
  }

#endif /* INTERNAL_INCLUDED_OPAQUE_SHADING */
