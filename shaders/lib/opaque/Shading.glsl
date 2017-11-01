/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_OPAQUE_SHADING
  #define INTERNAL_INCLUDED_OPAQUE_SHADING

  #ifndef INTERNAL_INCLUDED_OPAQUE_SHADOWS
    #include "/lib/opaque/Shadows.glsl"
  #endif

  float getDirectShading(io MaskObject mask, in vec3 normal) {
    return (mask.foliage) ? 1.0 : max0(dot(normal, lightVector));
  }

  vec3 getFinalShading(out vec4 highlightTint, io GbufferObject gbuffer, io MaskObject mask, io PositionObject position, in vec2 screenCoord, in vec3 albedo, in mat2x3 atmosphereLighting) {
    NewShadowObject(shadowObject);

    getShadows(gbuffer, mask, position, shadowObject, screenCoord);

    highlightTint = vec4(shadowObject.colour, shadowObject.occlusionBack);

    #ifdef VISUALISE_PCSS_EDGE_PREDICTION
      if(screenCoord.x > 0.5) return vec3(shadowObject.edgePrediction);
    #endif

    vec3 direct = atmosphereLighting[0] * shadowObject.occlusionBack * mix(vec3(shadowObject.occlusionFront), shadowObject.colour, shadowObject.difference) * getDirectShading(mask, gbuffer.normal);
    vec3 ambient = atmosphereLighting[1] * pow5(gbuffer.lightmap.y) * max0(dot(gbuffer.normal, upVector) * 0.45 + 0.65);
    vec3 block = blockLightColour * max(((mask.emissive) ? 32.0 : 1.0) * gbuffer.emission, pow6(gbuffer.lightmap.x));

    return albedo * (direct + ambient + block);
  }

#endif /* INTERNAL_INCLUDED_OPAQUE_SHADING */
