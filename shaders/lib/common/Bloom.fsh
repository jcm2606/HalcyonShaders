/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_COMMON_BLOOM
    #define INCLUDED_COMMON_BLOOM

    #if PROGRAM == COMPOSITE2
        vec3 CalculateBloomTile(vec2 screenCoord, vec2 offset, float scale, int lod) {
            const int   width      = 7;
            const int   samples    = width * width;
            const float samplesRCP = rcp(samples);

            const float a = pow(0.5, 0.5) * 20.0 * samplesRCP;

            vec3 tile = vec3(0.0);

            vec2 pixelSize = rcp(viewWidth) * vec2(1.0, aspectRatio);

            vec2 coord = screenCoord - offset;
            vec2 scaledCoord = coord * scale;

            if(scaledCoord.x > -0.1 && scaledCoord.y > -0.1 && scaledCoord.x < 1.1 && scaledCoord.y < 1.1) {
                for(int i = 0; i < samples; ++i) {
                    vec2 sampleCoord = Map2D(i, samples);

                    float weight = pow2(1.0 - fLength(sampleCoord - vec2(3.0)) * 0.25) * a;

                    if(weight <= 0.0)
                        continue;

                    tile += texture2DLod(colortex3, (pixelSize * (sampleCoord - vec2(2.5, 3.0)) + coord) * scale, lod).rgb * weight;
                }
            }

            return tile;
        }

        vec3 CalculateBloomTiles(vec2 screenCoord) {
            #ifndef BLOOM
                return vec3(0.0);
            #endif

            const float scale2 = exp2(2.0);
            const float scale3 = exp2(3.0);
            const float scale4 = exp2(4.0);
            const float scale5 = exp2(5.0);
            const float scale6 = exp2(6.0);
            const float scale7 = exp2(7.0);

            vec3 tiles  = vec3(0.0);
                 tiles += CalculateBloomTile(screenCoord, vec2(0.0, 0.0), scale2, 2);
                 tiles += CalculateBloomTile(screenCoord, vec2(0.3, 0.0), scale3, 3);
                 tiles += CalculateBloomTile(screenCoord, vec2(0.0, 0.3), scale4, 4);
                 tiles += CalculateBloomTile(screenCoord, vec2(0.1, 0.3), scale5, 5);
                 tiles += CalculateBloomTile(screenCoord, vec2(0.2, 0.3), scale6, 6);
                 tiles += CalculateBloomTile(screenCoord, vec2(0.3, 0.3), scale7, 7);

            return EncodeColour(tiles);
        }
    #endif

    #if PROGRAM == FINAL
        #include "/lib/util/Samplers.glsl"

        vec3 GetBloomTile(vec2 screenCoord, vec2 offset, float scale, int lod) {
            const float power = rcp(128.0);

            float a = rcp(scale);
            float b = pow(9.0 - float(lod), power);

            vec2 halfPixel = rcp(vec2(viewWidth, viewHeight)) * 0.5;

            return DecodeColour(bicubic2D(colortex2, (screenCoord - halfPixel) * a + offset).rgb) * b;
        }

        vec3 CalculateBloom(vec3 image, vec2 screenCoord) {
            #if !defined BLOOM || defined CAMERA_FOCUS_PREVIEW || defined LENS_PREVIEW
                return image;
            #endif

            const float scale2 = exp2(2.0);
            const float scale3 = exp2(3.0);
            const float scale4 = exp2(4.0);
            const float scale5 = exp2(5.0);
            const float scale6 = exp2(6.0);
            const float scale7 = exp2(7.0);

            float screenLuma = ReadFromTile(colortex3, TILE_COORD_TEMPORAL_LUMA, TILE_WIDTH_TEMPORAL).a;
                  screenLuma = max(0.0, 0.7 / (screenLuma + mix(1.0, 0.01, timeNight)));
                  screenLuma = pow(screenLuma, 3.0);

            vec3 bloom  = vec3(0.0);
                 bloom += GetBloomTile(screenCoord, vec2(0.0, 0.0), scale2, 2);
                 bloom += GetBloomTile(screenCoord, vec2(0.3, 0.0), scale3, 3);
                 bloom += GetBloomTile(screenCoord, vec2(0.0, 0.3), scale4, 4);
                 bloom += GetBloomTile(screenCoord, vec2(0.1, 0.3), scale5, 5);
                 bloom += GetBloomTile(screenCoord, vec2(0.2, 0.3), scale6, 6);
                 bloom += GetBloomTile(screenCoord, vec2(0.3, 0.3), scale7, 7);
                 bloom *= min(300.0, screenLuma) * luma(bloom) * 10.0;

            return mix(image, bloom, 0.02);
        }
    #endif

#endif
