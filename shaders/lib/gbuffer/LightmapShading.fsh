/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_GBUFFER_MATERIALID
    #define INCLUDED_GBUFFER_MATERIALID

    vec2 CalculateShadedLightmaps(const vec3 viewPosition, const vec3 normal, const vec2 lightmap) {
        #if PROGRAM == GBUFFERS_EYES
            return lightmap;
        #endif

        /*
        mat2x3 positionD = mat2x3(dFdx(worldSpacePosition), dFdy(worldSpacePosition));
        vec3 lightDirection = normalize( positionD * vec2( dFdx(lmCoord.x), dFdy(lmCoord.x) ) );
        */
        
        vec2 blockD = vec2(dFdx(lightmap.x), dFdy(lightmap.x)) * 256.0;
        vec2 skyD   = vec2(dFdx(lightmap.y), dFdy(lightmap.y)) * 256.0;

        vec3 T = normalize(dFdx(viewPosition));
        vec3 B = normalize(dFdy(viewPosition));
        vec3 N = cross(T, B);

        vec3 blockL = normalize(vec3(blockD.x * T + 0.0005 * N + blockD.y * B));
        
        vec2 lightmapShading = saturate(min(vec2(0.85), saturate(vec2(
            max0(dot(normal, blockL)) * 0.5 + 0.5,
            1.0
        ) * 1.5)) * 1.15);

        return lightmap * lightmapShading;
    }

#endif
