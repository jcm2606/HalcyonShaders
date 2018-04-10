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

    vec2 CalculateParallaxCoord(const vec2 uvCoord, const vec3 viewDirection, const mat2 texD) {
        #ifndef PARALLAX_TERRAIN
            return uvCoord;
        #endif
        
        vec3 increment = tangentViewVector * fInverseLength(tangentViewVector.xy);
             increment = fLength(increment.xy * texD) * increment;

        vec3 coord = vec3(uvCoord, 0.0);
        bool iterCheck = increment.z < -1.0e-6;

        while(GetDepthGradient(coord.xy, texD) <= coord.z && iterCheck)
            coord += increment;

        return WrapTexture(coord.xy);
    }

    float CalculateParallaxShadow(const vec2 uvCoord, const vec3 viewDirection, const mat2 texD) {
        #ifndef PARALLAX_TERRAIN_SHADOW
            return 1.0;
        #endif

        vec3 increment = ((shadowLightPosition * 0.01) * tbn);
             increment = increment * fInverseLength(increment.xy);
             increment = fLength(increment.xy * texD) * increment;

        vec3 coord = vec3(uvCoord, GetDepthGradient(uvCoord, texD));
        bool iterCheck = increment.z > 1.0e-6;

        while(GetDepthGradient(coord.xy, texD) <= coord.z && iterCheck && coord.z < 0.0)
            coord += increment;

        return coord.z < 0.0 ? 0.0 : 1.0;
    }

#endif
