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
        
        vec3 parallaxLighting;

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
        SurfaceObject surfaceObject = SurfaceObject(vec3(0.0), 0.0, 0.0, vec3(0.0), 0.0, 0.0, 0.0, vec3(0.0), 0.0, 0.0, 0.0, 0.0, 0.0);

        // Albedo.
        surfaceObject.albedo = ToLinear(DecodeAlbedo(screenObject.tex0.r));

        // Lighting.
        vec4 data01 = Decode4x8F(screenObject.tex0.g);
        surfaceObject.blockLight = data01.x;
        surfaceObject.skyLight = data01.y;
        surfaceObject.blockLightShaded = data01.z;
        surfaceObject.skyLightShaded = data01.w;

        vec4 data02 = Decode4x8F(screenObject.tex0.b);
        surfaceObject.parallaxLighting = data02.rgb;
        surfaceObject.vanillaAO = data02.w;

        // Normal.
        surfaceObject.normal = normalize(DecodeNormal(screenObject.tex1.r));

        // Material Properties.
        vec4 data11 = Decode4x8F(screenObject.tex1.g);
        surfaceObject.roughness = data11.x;
        surfaceObject.f0 = data11.y;
        surfaceObject.emission = data11.z;
        surfaceObject.placeholderProperty = data11.w;

        // Material ID.
        vec4 data12 = Decode4x8F(screenObject.tex1.b);
        surfaceObject.materialID = data12.x;

        return surfaceObject;
    }

#endif
