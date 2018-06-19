/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_GBUFFER_PARALLAXTERRAIN
    #define INCLUDED_GBUFFER_PARALLAXTERRAIN

    #define tileSize     tileInfo[0]
    #define tilePosition tileInfo[1]

    vec2 WrapTexture(const vec2 uvCoord) {
        return ceil((tilePosition - uvCoord) / tileSize) * tileSize + uvCoord;
    }

    float GetDepthGradient(const vec2 uvCoord, const mat2 texD) {
        float parallaxDepth = tileSize.x * parallaxTerrainDepth;

        return texture2DGradARB(normals, WrapTexture(uvCoord), texD[0], texD[1]).a * parallaxDepth - parallaxDepth;
    }

    vec2 CalculateParallaxCoord(out vec2 parallaxCoord, const vec2 uvCoord, const vec3 viewDirection, const mat2 texD) {
        parallaxCoord = uvCoord;

        #ifndef PARALLAX_TERRAIN
            return uvCoord;
        #endif

        if(texture2DGradARB(normals, WrapTexture(uvCoord), texD[0], texD[1]).a <= 0.0)
            return uvCoord;
        
        const float quality = -1.0e-6 * 1.0;

        vec3 increment = tangentViewVector * fInverseLength(tangentViewVector.xy);
             increment = fLength(increment.xy * texD) * increment;

        vec3 coord = vec3(uvCoord, 0.0);
        bool iterCheck = increment.z < quality;

        while(GetDepthGradient(coord.xy, texD) <= coord.z && iterCheck)
            coord += increment;

        parallaxCoord = coord.xy;
        return WrapTexture(coord.xy);
    }

    float CalculateParallaxShadow(const vec2 uvCoord, const mat2 texD) {
        #ifndef PARALLAX_TERRAIN_SHADOW
            return 1.0;
        #endif

        const float quality = 1.0e-6 * 1.0;
        
        vec3 increment = ((shadowLightPosition) * tbn);
             increment = increment * fInverseLength(increment.xy);
             increment = fLength(increment.xy * texD) * increment;

        vec3 coord = vec3(uvCoord, GetDepthGradient(uvCoord, texD));
        bool iterCheck = increment.z > quality;

        while(GetDepthGradient(coord.xy, texD) <= coord.z && iterCheck && coord.z < 0.0)
            coord += increment;

        return coord.z < 0.0 ? 0.0 : 1.0;
    }

    vec3 CalculateParallaxSSS(const vec2 uvCoord, const mat2 texD, const float materialID) {
    #if defined PARALLAX_TERRAIN_SSS
        if(/*!CompareFloat(materialID, MATERIAL_SUBSURFACE) && */!CompareFloat(entity.x, GRASS.x))
    #endif
            return vec3(CalculateParallaxShadow(uvCoord, texD));

        const float quality = 1.0e-6 * 1.0;
        
        vec3 increment = ((shadowLightPosition) * tbn);
             increment = increment * fInverseLength(increment.xy);
             increment = fLength(increment.xy * texD) * increment;

        vec3 coord = vec3(uvCoord, GetDepthGradient(uvCoord, texD));
        bool iterCheck = increment.z > quality;

        float height = GetDepthGradient(coord.xy, texD);

        vec3 volume = vec3(0.0);

        int i = 0;

        while(iterCheck && coord.z < 0.0) {
            bool intersect = height > coord.z;

            volume += (1.0 - (texture2DGradARB(texture, WrapTexture(coord.xy), texD[0], texD[1]).rgb * tint)) * float(intersect);

            coord += increment;
            height = GetDepthGradient(coord.xy, texD);
            ++i;
        }

        return exp2(-volume / i * 10.0);
    }

#endif
