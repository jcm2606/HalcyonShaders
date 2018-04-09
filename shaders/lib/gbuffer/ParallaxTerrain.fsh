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
        
        const int   samples    = PARALLAX_TERRAIN_SAMPLES;
        const float samplesRCP = rcp(samples);

        float stepLength = tileSize.x * samplesRCP;

        vec3 coord = vec3(uvCoord, 0.0);
        int i = samples;

        while(GetDepthGradient(coord.xy, texD) < coord.z && --i > 0.0) {
            coord += viewDirection * stepLength;
        }

        return WrapTexture(coord.xy);
    }

    float CalculateParallaxShadow(const vec2 uvCoord, const vec3 viewDirection, const mat2 texD) {
        #ifndef PARALLAX_TERRAIN_SHADOW
            return 1.0;
        #endif

        const int   samples    = PARALLAX_TERRAIN_SHADOW_SAMPLES;
        const float samplesRCP = rcp(samples);

        vec3 lightDirection = ((shadowLightPosition * 0.01) * tbn);

        float stepLength = tileSize.x * samplesRCP;
        vec3 increment = lightDirection * stepLength;

        vec3 coord = vec3(uvCoord, GetDepthGradient(uvCoord, texD));
        int i = samples;

        while(GetDepthGradient(coord.xy, texD) <= coord.z && --i > 0.0 && coord.z < 0.0) {
            coord += increment;
        }

        return coord.z < 0.0 ? 0.0 : 1.0;
    }

#endif
