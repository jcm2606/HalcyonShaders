/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_GBUFFER_STRUCTGBUFFER
  #define INTERNAL_INCLUDED_GBUFFER_STRUCTGBUFFER

  struct GbufferObject {
    // BUFFERS
    vec4 workingBuffer;
    vec4 gbuffer0;
    vec4 gbuffer1;

    // GBUFFER DATA
    vec4 albedo;
    vec2 lightmap;
    float objectID;

    vec3 normal;
    vec4 material;
  };

  #define NewGbufferObject(name) GbufferObject name = GbufferObject(vec4(0.0, 0.0, 0.0, 1.0), vec4(0.0, 0.0, 0.0, 1.0), vec4(0.0, 0.0, 0.0, 1.0), vec4(0.0), vec2(0.0), 0.0, vec3(0.0), vec4(0.0))

  void populateBuffers(io GbufferObject gbuffer) {
    // ALBEDO
    gbuffer.gbuffer0.x = encodeColour(gbuffer.albedo.rgb);

    // LIGHTMAPS
    gbuffer.gbuffer0.y = encode2x8(gbuffer.lightmap);

    // OBJECT ID
    gbuffer.gbuffer0.z = gbuffer.objectID;

    // NORMAL
    gbuffer.gbuffer1.x = encodeNormal(gbuffer.normal);

    // MATERIAL
    gbuffer.gbuffer1.y = encode2x8(gbuffer.material.xy);
    gbuffer.gbuffer1.z = encode2x8(gbuffer.material.zw);
  }

#endif /* INTERNAL_INCLUDED_GBUFFER_STRUCTGBUFFER */
