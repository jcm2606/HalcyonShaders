/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_STRUCT_STRUCTMASK
  #define INTERNAL_INCLUDED_STRUCT_STRUCTMASK

  struct MaskObject {
    bool fallback;
    bool unlit;

    bool beam;
    bool hand;
    bool entity;
    bool particle;
    bool weather;
    
    bool stainedGlass;
    bool transparent;
    bool water;
    bool ice;
    
    bool emissive;
    bool foliage;
    bool terrain;
    bool metal;
  };

  #define NewMaskObject(name) MaskObject name = MaskObject(false, false, false, false, false, false, false, false, false, false, false, false, false, false, false)

  void populateMaskObject(io MaskObject mask, io GbufferObject gbuffer) {
    cv(float) width = ubyteMaxRCP;

    mask.fallback = comparef(gbuffer.objectID, OBJECT_FALLBACK, width);
    mask.unlit = comparef(gbuffer.objectID, OBJECT_UNLIT, width);

    mask.beam = comparef(gbuffer.objectID, OBJECT_BEAM, width);
    mask.hand = comparef(gbuffer.objectID, OBJECT_HAND, width);
    mask.entity = comparef(gbuffer.objectID, OBJECT_ENTITY, width);
    mask.particle = comparef(gbuffer.objectID, OBJECT_PARTICLE, width);
    mask.weather = comparef(gbuffer.objectID, OBJECT_WEATHER, width);

    mask.stainedGlass = comparef(gbuffer.objectID, OBJECT_STAINED_GLASS, width);
    mask.transparent = comparef(gbuffer.objectID, OBJECT_TRANSPARENT, width);
    mask.water = comparef(gbuffer.objectID, OBJECT_WATER, width);
    mask.ice = comparef(gbuffer.objectID, OBJECT_ICE, width);

    mask.emissive = comparef(gbuffer.objectID, OBJECT_EMISSIVE, width);
    mask.foliage = comparef(gbuffer.objectID, OBJECT_FOLIAGE, width);
    mask.terrain = comparef(gbuffer.objectID, OBJECT_TERRAIN, width);
    mask.metal = comparef(gbuffer.objectID, OBJECT_METAL, width);
  }

#endif /* INTERNAL_INCLUDED_STRUCT_STRUCTMASK */
