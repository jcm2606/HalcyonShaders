/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_STRUCT_MATERIALOBJECT
    #define INCLUDED_STRUCT_MATERIALOBJECT

    struct MaterialObject {
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

    MaterialObject CreateMaterialObject(const SurfaceObject surfaceObject) {
        MaterialObject materialObject = MaterialObject(false, false, false, false, false, false, false, false, false, false, false, false, false, false);

        materialObject.fallback = CompareFloat(surfaceObject.materialID, MATERIAL_FALLBACK);
        materialObject.unlit = CompareFloat(surfaceObject.materialID, MATERIAL_UNLIT);

        materialObject.hand = CompareFloat(surfaceObject.materialID, MATERIAL_HAND);
        materialObject.entity = CompareFloat(surfaceObject.materialID, MATERIAL_ENTITY);
        materialObject.particle = CompareFloat(surfaceObject.materialID, MATERIAL_PARTICLE);
        materialObject.weather = CompareFloat(surfaceObject.materialID, MATERIAL_WEATHER);

        materialObject.stainedGlass = CompareFloat(surfaceObject.materialID, MATERIAL_STAINED_GLASS);
        materialObject.transparent = CompareFloat(surfaceObject.materialID, MATERIAL_TRANSPARENT);
        materialObject.water = CompareFloat(surfaceObject.materialID, MATERIAL_WATER);
        materialObject.ice = CompareFloat(surfaceObject.materialID, MATERIAL_ICE);

        materialObject.emissive = CompareFloat(surfaceObject.materialID, MATERIAL_EMISSIVE);
        materialObject.subsurface = CompareFloat(surfaceObject.materialID, MATERIAL_SUBSURFACE);
        materialObject.terrain = CompareFloat(surfaceObject.materialID, MATERIAL_TERRAIN);
        materialObject.metal = CompareFloat(surfaceObject.materialID, MATERIAL_METAL);

        return materialObject;
    }

#endif
