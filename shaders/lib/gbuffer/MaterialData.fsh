/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_GBUFFER_MATERIALDATA
    #define INCLUDED_GBUFFER_MATERIALDATA

    vec4 CalculateMaterialData(const vec2 uvCoord, const vec2 entity, const float materialID, const float puddle, const mat2 texD) {
        vec4 materialData = MATERIAL_DEFAULT;

        #define smoothness materialData.x
        #define f0 materialData.y
        #define emission materialData.z
        #define placeholder materialData.w

        #if   PROGRAM == GBUFFERS_TERRAIN || PROGRAM == GBUFFERS_HAND || PROGRAM == GBUFFERS_BLOCK
            vec4 specularData = textureSample(specular, uvCoord);

            #if   MATERIAL_FORMAT == 1 // Specular.
                smoothness = specularData.x;
                f0 = 0.02;
                emission = float(CompareFloat(materialID, MATERIAL_EMISSIVE));
                placeholder = 0.0;
            #elif MATERIAL_FORMAT == 2 // Old PBR, no emission.
                smoothness = specularData.x;
                f0 = mix(0.02, 0.8, specularData.y);
                emission = float(CompareFloat(materialID, MATERIAL_EMISSIVE));
                placeholder = 0.0;
            #elif MATERIAL_FORMAT == 3 // Old PBR, emission.
                smoothness = specularData.x;
                f0 = mix(0.02, 0.8, specularData.y);
                emission = specularData.z;
                placeholder = 0.0;
            #elif MATERIAL_FORMAT == 4 // New PBR / Pulchra.
                smoothness = specularData.z;
                f0 = specularData.x;
                emission = 1.0 - specularData.a;
                placeholder = 0.0;
            #else

            #endif
        #endif

        #undef smoothness
        #undef f0
        #undef emission
        #undef placeholder

        return materialData;
    }

#endif
