/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_STRUCT_GBUFFER
  #define INTERNAL_INCLUDED_STRUCT_GBUFFER

  struct GbufferData {
    vec3 albedo;

    vec3 normal;

    float blockLight;
    float skyLight;

    float roughness;
    float f0;
    float emission;
    float pourosity;

    float objectID;
  };

  #define _newGbufferObject(name) GbufferData name = GbufferData(vec3(0.0), vec3(0.0), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)

  void populateGbufferData(io GbufferData gbufferData, in BufferList bufferList) {
    vec2 pair0 = decode2x8(bufferList.tex1.g);
    vec2 pair1 = decode2x8(bufferList.tex1.b);
    vec2 pair2 = decode2x8(bufferList.tex2.g);
    vec2 pair3 = decode2x8(bufferList.tex2.b);

    // ALBEDO
    gbufferData.albedo = toLinear(decodeColour(bufferList.tex1.r));

    // LIGHTMAPS
    gbufferData.blockLight = pair0.x;
    gbufferData.skyLight = pair0.y;

    // OBJECT ID
    gbufferData.objectID = pair1.x * objectIDMax;

    // NORMAL
    gbufferData.normal = decodeNormal(bufferList.tex2.r);

    // ROUGNESS/F0
    gbufferData.roughness = pair2.x;
    gbufferData.f0 = pair2.y;

    // EMISSION/POUROSITY
    gbufferData.emission = pair3.x;
    gbufferData.pourosity = pair3.y;
  }

#endif /* INTERNAL_INCLUDED_STRUCT_GBUFFER */
