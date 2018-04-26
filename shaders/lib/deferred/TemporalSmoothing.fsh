/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_DEFERRED_TEMPORALSMOOTHING
    #define INCLUDED_DEFERRED_TEMPORALSMOOTHING

    float CalculateSmoothedTiles(const vec2 screenCoord, const float oldValue, io float avgLuma) {
        float newValue = oldValue;

        // Average Luma.
        const float lumaSpeed = 0.5;

        float prevLuma = ReadFromTile(colortex3, TILE_COORD_TEMPORAL_LUMA, TILE_WIDTH_TEMPORAL).a;
        float currLuma = luma(DecodeColour(texture2DLod(colortex4, vec2(0.5), 10).rgb));
              avgLuma  = mix(prevLuma, currLuma, saturate(frameTime * lumaSpeed));

        if(CanWriteToTile(screenCoord, TILE_COORD_TEMPORAL_LUMA, TILE_WIDTH_TEMPORAL))
            newValue = avgLuma;

        return newValue;
    }

#endif
