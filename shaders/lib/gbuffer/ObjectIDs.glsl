/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_GBUFFER_OBJECTIDS
  #define INTERNAL_INCLUDED_GBUFFER_OBJECTIDS

  objectID = OBJECT_FALLBACK;

  #if PROGRAM == GBUFFERS_TERRAIN
    objectID = OBJECT_TERRAIN;

    if(
      entity.x == SAPLING.x ||
      entity.x == LEAVES1.x ||
      entity.x == LEAVES2.x ||
      entity.x == TALLGRASS.x ||
      entity.x == DEADBUSH.x ||
      entity.x == FLOWER_YELLOW.x ||
      entity.x == FLOWER_RED.x ||
      entity.x == MUSHROOM_BROWN.x ||
      entity.x == MUSHROOM_RED.x ||
      entity.x == WHEAT.x ||
      entity.x == REEDS.x ||
      entity.x == VINE.x ||
      entity.x == LILYPAD.x ||
      entity.x == NETHERWART.x ||
      entity.x == CARROTS.x ||
      entity.x == POTATOES.x ||
      entity.x == DOUBLE_PLANT.x ||
      (
        false
      )
    ) objectID = OBJECT_FOLIAGE;

    if(
      entity.x == TORCH.x ||
      entity.x == FIRE.x ||
      entity.x == GLOWSTONE.x ||
      entity.x == REDSTONE_LAMP_LIT.x ||
      entity.x == BEACON.x ||
      entity.x == SEA_LANTERN.x ||
      entity.x == END_ROD.x ||
      (
        false
      )
    ) objectID = OBJECT_EMISSIVE;
  #elif PROGRAM == GBUFFERS_HAND
    objectID = OBJECT_HAND;
  #elif PROGRAM == GBUFFERS_WATER
    objectID = OBJECT_TRANSPARENT;
  #elif PROGRAM == GBUFFERS_BEACON_BEAM
    objectID = OBJECT_BEAM;
  #elif PROGRAM == GBUFFERS_ENTITIES
    objectID = OBJECT_ENTITY;
  #elif PROGRAM == GBUFFERS_TEXTURED_LIT
    objectID = OBJECT_PARTICLE;
  #elif PROGRAM == GBUFFERS_WEATHER
    objectID = OBJECT_WEATHER;
  #endif
  
#endif /* INTERNAL_INCLUDED_GBUFFER_OBJECTIDS */
