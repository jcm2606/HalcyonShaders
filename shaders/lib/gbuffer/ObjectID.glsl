/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_GBUFFER_OBJECTID
  #define INTERNAL_INCLUDED_GBUFFER_OBJECTID

  float getObjectID(in vec2 entity) {
    float objectID = OBJECT_FALLBACK;

    #if PROGRAM == SHADOW || PROGRAM == GBUFFERS_TERRAIN
      objectID = OBJECT_TERRAIN;

      if(
        entity.x == TORCH.x ||
        entity.x == FIRE.x ||
        entity.x == GLOWSTONE.x ||
        entity.x == REDSTONE_LAMP.x || entity.x == REDSTONE_LAMP.y ||
        entity.x == BEACON.x ||
        entity.x == SEA_LANTERN.x ||
        entity.x == END_ROD.x
      ) objectID = OBJECT_EMISSIVE;

      if(
        entity.x == SAPLING.x ||
        entity.x == LEAVES.x || entity.x == LEAVES.y ||
        entity.x == TALLGRASS.x ||
        entity.x == FLOWER.x || entity.x == FLOWER.y ||
        entity.x == MUSHROOM.x || entity.x == FLOWER.y ||
        entity.x == WHEAT.x ||
        entity.x == REEDS.x ||
        entity.x == VINE.x ||
        entity.x == LILYPAD.x ||
        entity.x == NETHERWART.x ||
        entity.x == CARROTS.x ||
        entity.x == POTATOES.x ||
        entity.x == DOUBLE_PLANT.x ||
        entity.x == CACTUS.x
      ) objectID = OBJECT_SUBSURFACE;
    #endif
    #if PROGRAM == SHADOW || PROGRAM == GBUFFERS_WATER || PROGRAM == GBUFFERS_HANDWATER
      objectID = OBJECT_TRANSPARENT;

      if(
        entity.x == WATER.x || entity.x == WATER.y
      ) objectID = OBJECT_WATER;
    #endif
    #if PROGRAM == GBUFFERS_HAND
      objectID = OBJECT_HAND;
    #elif PROGRAM == GBUFFERS_ENTITIES
      objectID = OBJECT_ENTITY;
    #elif PROGRAM == GBUFFERS_TEXTURED || PROGRAM == GBUFFERS_TEXTUREDLIT
      objectID = OBJECT_PARTICLE;
    #elif PROGRAM == GBUFFERS_WEATHER
      objectID = OBJECT_WEATHER;
    #endif

    return objectID;
  }

#endif /* INTERNAL_INCLUDED_GBUFFER_OBJECTID */
