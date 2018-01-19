/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_STRUCT_MASK
  #define INTERNAL_INCLUDED_STRUCT_MASK

  struct MaskList {
    bool fallback;
    bool unlit;

    bool hand;
    bool entity;
    bool particle;
    bool weather;

    bool stainedGlass;
    bool transparent;
    bool water;
    bool ice;

    bool emissive;
    bool subsurface;
    bool terrain;
    bool metal;
  };

  #define _newMaskList(name) MaskList name = MaskList(false, false, false, false, false, false, false, false, false, false, false, false, false, false)

  void populateMaskList(io MaskList maskList, in GbufferData gbufferData) {
    float objectID = gbufferData.objectID;

    maskList.fallback = compare(objectID, OBJECT_FALLBACK);
    maskList.unlit = compare(objectID, OBJECT_UNLIT);

    maskList.hand = compare(objectID, OBJECT_HAND);
    maskList.entity = compare(objectID, OBJECT_ENTITY);
    maskList.particle = compare(objectID, OBJECT_PARTICLE);
    maskList.weather = compare(objectID, OBJECT_WEATHER);

    maskList.stainedGlass = compare(objectID, OBJECT_STAINED_GLASS);
    maskList.transparent = compare(objectID, OBJECT_TRANSPARENT);
    maskList.water = compare(objectID, OBJECT_WATER);
    maskList.ice = compare(objectID, OBJECT_ICE);

    maskList.emissive = compare(objectID, OBJECT_EMISSIVE);
    maskList.subsurface = compare(objectID, OBJECT_SUBSURFACE);
    maskList.terrain = compare(objectID, OBJECT_TERRAIN);
    maskList.metal = compare(objectID, OBJECT_METAL);
  }

#endif /* INTERNAL_INCLUDED_STRUCT_MASK */
