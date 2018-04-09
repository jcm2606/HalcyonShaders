/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_UTIL_ENTITYLIST
    #define INCLUDED_UTIL_ENTITYLIST

    /*
        ID FORMAT:
        OPAQUE BLOCKS & FOLIAGE: ivec2(id, meta)
        FLUIDS: ivec2(still, flowing)

        Except where specified.
    */

    // VANILLA
    // OPAQUE
    #define GRASS ivec2(2, 0)
    #define BLOCK_IRON ivec2(42, 0)
    #define BLOCK_GOLD ivec2(41, 0)
    #define BLOCK_DIAMOND ivec2(57, 0)
    #define BLOCK_EMERALD ivec2(133, 0)
    #define BLOCK_REDSTONE ivec2(152, 0)
    #define BLOCK_LAPIS ivec2(22, 0)
    #define OBSIDIAN ivec2(49, 0)
    #define SNOW ivec2(80, 0)
    #define WEB ivec2(30, 0)
    #define SIGN ivec2(63, 68)

    // TRANSPARENT
    #define ICE ivec2(79, 0)
    #define STAINED_GLASS ivec2(95, 160) // x = block, y = pane

    // CUTOUT
    #define GLASS ivec2(20, 102) // x = block, y = pane

    // FOLIAGE
    #define SAPLING ivec2(6, 0)
    #define LEAVES ivec2(18, 161) // x = leaves1, y = leaves2
    #define TALLGRASS ivec2(31, 0)
    #define DEADBUSH ivec2(32, 0)
    #define FLOWER ivec2(37, 38) // x = yellow flower, y = red flower
    #define MUSHROOM ivec2(39, 40) // x = brown mushroom, y = red mushroom
    #define WHEAT ivec2(59, 0)
    #define REEDS ivec2(83, 0)
    #define VINE ivec2(106, 0)
    #define LILYPAD ivec2(111, 0)
    #define NETHERWART ivec2(115, 0)
    #define CARROTS ivec2(141, 0)
    #define POTATOES ivec2(142, 0)
    #define DOUBLE_PLANT ivec2(175, 0)
    #define CACTUS ivec2(81, 0)
    #define BEETROOT ivec2(207, 0)

    // EMISSIVE
    #define TORCH ivec2(50, 0)
    #define FIRE ivec2(51, 0)
    #define GLOWSTONE ivec2(89, 0)
    #define REDSTONE_LAMP ivec2(124, 123) // x = lit, y = unlit
    #define BEACON ivec2(138, 0)
    #define SEA_LANTERN ivec2(169, 0)
    #define END_ROD ivec2(198, 0)

    // FLUIDS
    #define WATER ivec2(9, 8)
    #define LAVA ivec2(11, 10)

#endif
