/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_STRUCT_GBUFFER
  #define INTERNAL_INCLUDED_STRUCT_GBUFFER

  struct GbufferObject {
    // RAW DATA
    vec3 albedo;
    vec2 lightmap;
    float objectID;

    vec3 normal;
    vec2 material0;
    vec2 material1;

    // UNPACKED DATA
    float blockLight;
    float skyLight;
    
    float roughness;
    float f0;
    float emission;
    float materialPlaceholder;
  };

  #define NewGbufferObject(name) GbufferObject name = GbufferObject(vec3(0.0), vec2(0.0), 0.0, vec3(0.0), vec2(0.0), vec2(0.0), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)

  void populateGbufferObject(io GbufferObject gbuffer, io BufferObject buffers) {
    // RAW DATA
    gbuffer.albedo = toLinear(decodeColour(buffers.tex1.x));
    gbuffer.lightmap = toLinear(decode2x8(buffers.tex1.y));
    gbuffer.objectID = buffers.tex1.z * objectIDRange;

    gbuffer.normal = decodeNormal(buffers.tex2.x);
    gbuffer.material0 = decode2x8(buffers.tex2.y);
    gbuffer.material1 = decode2x8(buffers.tex2.z);

    // UNPACKED DATA
    gbuffer.blockLight = gbuffer.lightmap.x;
    gbuffer.skyLight = gbuffer.lightmap.y;

    gbuffer.roughness = gbuffer.material0.x;
    gbuffer.f0 = gbuffer.material0.y;
    gbuffer.emission = gbuffer.material1.x;
    gbuffer.materialPlaceholder = gbuffer.material1.y;
  }

#endif /* INTERNAL_INCLUDED_STRUCT_GBUFFER */
