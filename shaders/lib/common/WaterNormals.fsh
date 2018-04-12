/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_COMMON_WATERNORMALS
    #define INCLUDED_COMMON_WATERNORMALS

    #include "/lib/util/Noise.glsl"

    float GerstnerOctave(vec2 coord, vec2 waveDirection, float waveSteepness, float waveAmplitude, float waveLength, float T) {
        const float g = 19.6;

        #define k ( tau / waveLength )
        #define w sqrt(g * k)
        #define x w * T - k * dot(waveDirection, coord)
        #define wave sin(x) * 0.5 + 0.5

        return waveAmplitude * pow(wave, waveSteepness);

        #undef k
        #undef w
        #undef x
        #undef wave
    }

    float Height0(vec3 worldPosition) {
        const int octaves = 9;

        const float rotAmount = cRadians(30.0);
        cRotateMat2(rotAmount, rot);

        float height = 0.0;

        vec2 position = worldPosition.xz - worldPosition.y;
        vec2 noisePosition = position * 0.005;

        float T = 0.3 * TIME;
        float waveSteepness = 0.45;
        float waveAmplitude = mix(0.2, 0.8, rainStrength);
        vec2  waveDirection = vec2(0.5, 0.2);
        float waveLength = 8.0;

        int i = octaves;
        while(--i > 0) {
            vec2 noise = noise2D(noisePosition / sqrt(waveLength));

            height += GerstnerOctave(position + (noise * 2.0 - 1.0) * sqrt(waveLength) * 2.0, waveDirection, waveSteepness, waveAmplitude, waveLength, T);

            waveSteepness *= 1.225;
            waveAmplitude *= 0.685;
            waveLength *= 0.695;
            T *= 1.08;
            waveDirection *= rot;
        }

        return height;
    }

    #define WaterHeightFunction Height0

    float CalculateWaterHeight(vec3 worldPosition) { return WaterHeightFunction(worldPosition); }

    vec3 CalculateWaterNormal(vec3 worldPosition) {
        const float deltaDist = 0.4;
        const vec2  deltaPos  = vec2(deltaDist, 0.0);

        const float anisotropy = 0.55;

        float   height0 = CalculateWaterHeight(worldPosition);
        #define height1   CalculateWaterHeight(worldPosition + deltaPos.xyy)
        #define height2   CalculateWaterHeight(worldPosition + deltaPos.yyx)

        vec2 deltaHeight = vec2(height0 - height1, height0 - height2);

        #undef height1
        #undef height2

        vec3 normal = vec3(deltaHeight.x, deltaHeight.y, 1.0 - pow2(deltaHeight.x) - pow2(deltaHeight.y));

        return normalize(normal) * anisotropy + vec3(0.0, 0.0, 1.0 - anisotropy);
    }

#endif
