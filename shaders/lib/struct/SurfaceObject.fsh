/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_STRUCT_SURFACEOBJECT
    #define INCLUDED_STRUCT_SURFACEOBJECT

    struct SurfaceObject {
        // Albedo.
        vec3 albedo;

        // Lighting.
        float blockLight;
        float skyLight;
        
        float parallaxShadow;

        float vanillaAO;

        float blockLightShaded;
        float skyLightShaded;

        // Normal.
        vec3 normal;

        // Material Properties.
        float roughness;
        float f0;
        float emission;
        float placeholderProperty;

        // Material ID.
        float materialID;
    };

    SurfaceObject CreateSurfaceObject(const ScreenObject screenObject) {
        SurfaceObject surfaceObject = SurfaceObject(vec3(0.0), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, vec3(0.0), 0.0, 0.0, 0.0, 0.0, 0.0);

        // Albedo.
        surfaceObject.albedo = ToLinear(DecodeAlbedo(screenObject.tex0.r));

        // Lighting.
        vec4 lightingData = Decode4x8F(screenObject.tex0.g);
        
        surfaceObject.blockLight = lightingData.x;
        surfaceObject.skyLight = lightingData.y;

        surfaceObject.parallaxShadow = lightingData.z * 4.0;
        
        surfaceObject.vanillaAO = lightingData.w;

        vec2 shadedLightmaps = Decode4x8F(screenObject.tex0.b).xy;
        
        surfaceObject.blockLightShaded = shadedLightmaps.x;
        surfaceObject.skyLightShaded = shadedLightmaps.y;

        // Normal.
        surfaceObject.normal = normalize(DecodeNormal(screenObject.tex1.r));

        // Material Properties.
        vec4 material0Data = Decode4x8F(screenObject.tex1.g);

        surfaceObject.roughness = material0Data.x;
        surfaceObject.f0 = material0Data.y;
        surfaceObject.emission = material0Data.z;
        surfaceObject.placeholderProperty = material0Data.w;

        // Material ID.
        vec4 material1Data = Decode4x8F(screenObject.tex1.b);

        surfaceObject.materialID = material1Data.x;

        return surfaceObject;
    }

#endif
