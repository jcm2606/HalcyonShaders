/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_GBUFFER_MATERIALID
    #define INCLUDED_GBUFFER_MATERIALID

    float CalculateMaterialID(const vec2 entity) {
        float materialID = MATERIAL_FALLBACK;

        #if PROGRAM == SHADOW || PROGRAM == GBUFFERS_TERRAIN || PROGRAM == GBUFFERS_HAND
            switch(int(entity.x)) {
                case SAPLING.x:
                case LEAVES.x:
                case LEAVES.y:
                case TALLGRASS.x:
                case FLOWER.x:
                case FLOWER.y:
                case WHEAT.x:
                case REEDS.x:
                case VINE.x:
                case LILYPAD.x:
                case NETHERWART.x:
                case CARROTS.x:
                case DOUBLE_PLANT.x:
                case BEETROOT.x:
                case CACTUS.x: materialID = MATERIAL_SUBSURFACE; break;
                case TORCH.x:
                case FIRE.x:
                case GLOWSTONE.x:
                case REDSTONE_LAMP.x:
                case REDSTONE_LAMP.y:
                case BEACON.x:
                case SEA_LANTERN.x:
                case END_ROD.x: materialID = MATERIAL_EMISSIVE; break;
                default: materialID = MATERIAL_TERRAIN; break;
            }
        #endif
        #if PROGRAM == SHADOW || PROGRAM == GBUFFERS_WATER || PROGRAM == GBUFFERS_HAND_WATER
            switch(int(entity.x)) {
                case WATER.x:
                case WATER.y: materialID = MATERIAL_WATER; break;
                case STAINED_GLASS.x:
                case STAINED_GLASS.y: materialID = MATERIAL_STAINED_GLASS; break;
                case ICE.x: materialID = MATERIAL_ICE; break;
                default: materialID = MATERIAL_TRANSPARENT; break;
            }
        #endif
        #if PROGRAM == GBUFFERS_ENTITIES
            materialID = MATERIAL_ENTITY;
        #endif
        #if PROGRAM == GBUFFERS_TEXTURED || PROGRAM == GBUFFERS_TEXTURED_LIT
            materialID = MATERIAL_PARTICLE;
        #endif
        #if PROGRAM == GBUFFERS_WEATHER
            materialID = MATERIAL_WEATHER;
        #endif
        #if PROGRAM == GBUFFERS_EYES || PROGRAM == GBUFFERS_BEAM
            materialID = MATERIAL_UNLIT;
        #endif

        return materialID;
    }

#endif
