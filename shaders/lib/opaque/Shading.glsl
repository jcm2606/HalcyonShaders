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

  vec3 getFinalShading(io GbufferObject gbuffer, io MaskObject mask, io PositionObject position, in vec2 screenCoord, in vec3 albedo, in mat2x3 atmosphereLighting) {
    NewShadowObject(shadowObject);

    getShadows(gbuffer, mask, position, shadowObject, screenCoord);

    return vec3(shadowObject.difference);

    vec3 direct = atmosphereLighting[0] * shadowObject.occlusionBack * getDirectShading(mask, gbuffer.normal);
    vec3 ambient = atmosphereLighting[1] * pow4(gbuffer.skyLight);
    vec3 block = vec3(1.0, 0.1, 0.0) * pow6(gbuffer.blockLight);

    return albedo * (direct + ambient + block);
  }

#endif /* INTERNAL_INCLUDED_OPAQUE_SHADING */
