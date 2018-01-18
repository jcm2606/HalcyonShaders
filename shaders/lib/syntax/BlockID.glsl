/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE..
*/

#ifndef INTERNAL_INCLUDED_UTIL_BLOCKIDS
  #define INTERNAL_INCLUDED_UTIL_BLOCKIDS
  
  /*
    ID FORMAT:
      OPAQUE BLOCKS & FOLIAGE: vec2(id, meta)
      FLUIDS: vec2(still, flowing)

      Except where specified.
  */

  // VANILLA
  // OPAQUE
  #define GRASS vec2(2, 0)
  #define BLOCK_IRON vec2(42, 0)
  #define BLOCK_GOLD vec2(41, 0)
  #define BLOCK_DIAMOND vec2(57, 0)
  #define BLOCK_EMERALD vec2(133, 0)
  #define BLOCK_REDSTONE vec2(152, 0)
  #define BLOCK_LAPIS vec2(22, 0)
  #define OBSIDIAN vec2(49, 0)
  #define SNOW vec2(80, 0)
  #define WEB vec2(30, 0)
  #define SIGN vec2(63, 68)

  // TRANSPARENT
  #define ICE vec2(79, 0)
  #define STAINED_GLASS vec2(95, 160) // x = block, y = pane

  // FOLIAGE
  #define SAPLING vec2(6, 0)
  #define LEAVES vec2(18, 161) // x = leaves1, y = leaves2
  #define TALLGRASS vec2(31, 0)
  #define DEADBUSH vec2(32, 0)
  #define FLOWER vec2(37, 38) // x = yellow flower, y = red flower
  #define MUSHROOM vec2(39, 40) // x = brown mushroom, y = red mushroom
  #define WHEAT vec2(59, 0)
  #define REEDS vec2(83, 0)
  #define VINE vec2(106, 0)
  #define LILYPAD vec2(111, 0)
  #define NETHERWART vec2(115, 0)
  #define CARROTS vec2(141, 0)
  #define POTATOES vec2(142, 0)
  #define DOUBLE_PLANT vec2(175, 0)
  #define CACTUS vec2(81, 0)

  // EMISSIVE
  #define TORCH vec2(50, 0)
  #define FIRE vec2(51, 0)
  #define GLOWSTONE vec2(89, 0)
  #define REDSTONE_LAMP vec2(124, 123) // x = lit, y = unlit
  #define BEACON vec2(138, 0)
  #define SEA_LANTERN vec2(159, 0)
  #define END_ROD vec2(198, 0)

  // FLUIDS
  #define WATER vec2(9, 8)
  #define LAVA vec2(11, 10)

#endif /* INTERNAL_INCLUDED_UTIL_BLOCKIDS */
