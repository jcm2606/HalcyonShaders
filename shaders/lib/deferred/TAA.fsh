/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_DEFERRED_TAA
    #define INCLUDED_DEFERRED_TAA

    #include "/lib/util/SpaceTransform.glsl"

    // Credit to Continuum for this TAA code!

    vec3 FindClosestFragment3x3(vec2 screenCoord, vec2 pixelSize) {
        vec2 dd = abs(pixelSize);
        vec3 d  = vec3(dd.x, dd.y, 0.0);

        vec3 dtl = vec3(-1, -1, texture2D(depthtex1, screenCoord - d.zy - d.xz).x);
        vec3 dtc = vec3( 0, -1, texture2D(depthtex1, screenCoord - d.zy).x);
        vec3 dtr = vec3( 1, -1, texture2D(depthtex1, screenCoord - d.zy + d.xz).x);

        vec3 dml = vec3(-1, 0, texture2D(depthtex1, screenCoord - d.xz).x);
        vec3 dmc = vec3( 0, 0, texture2D(depthtex1, screenCoord).x);
        vec3 dmr = vec3( 1, 0, texture2D(depthtex1, screenCoord + d.xz).x);

        vec3 dbl = vec3(-1, 1, texture2D(depthtex1, screenCoord + d.zy - d.xz).x);
        vec3 dbc = vec3( 0, 1, texture2D(depthtex1, screenCoord + d.zy ).x);
        vec3 dbr = vec3( 1, 1, texture2D(depthtex1, screenCoord + d.zy + d.xz).x);

        vec3 dmin = dtl;

        dmin = dmin.z > dtc.z ? dtc : dmin;
        dmin = dmin.z > dtr.z ? dtr : dmin;

        dmin = dmin.z > dml.z ? dml : dmin;
        dmin = dmin.z > dmc.z ? dmc : dmin;
        dmin = dmin.z > dmr.z ? dmr : dmin;

        dmin = dmin.z > dbl.z ? dbl : dmin;
        dmin = dmin.z > dbc.z ? dbc : dmin;
        dmin = dmin.z > dbr.z ? dbr : dmin;

        return vec3(screenCoord + dd.xy * dmin.xy, dmin.z);
    }

    vec2 CalculateCameraMotion(vec3 screenPos) {
        vec3 projection = mat3(gbufferModelViewInverse) * ClipToViewPosition(screenPos.xy, screenPos.z);

        projection = (cameraPosition - previousCameraPosition) + projection;
        projection = mat3(gbufferPreviousModelView) * projection;
        projection = (diagonal3(gbufferPreviousProjection) * projection + gbufferPreviousProjection[3].xyz) / -projection.z * 0.5 + 0.5;

        return (screenPos.xy - projection.xy);
    }

    vec3 ClipAABB(vec3 aabbMin, vec3 aabbMax, vec3 p, vec3 q) {
        vec3 p_clip = 0.5 * (aabbMax + aabbMin);

        vec3 v_clip = q - p_clip;
        vec3 a_unit = abs(v_clip.xyz / (0.5 * (aabbMax - aabbMin) + 1.0e-8));
        float ma_unit = max(a_unit.x, max(a_unit.y, a_unit.z));

        if(ma_unit > 1.0)
            return p_clip + v_clip / ma_unit;
        else
            return q; // Point inside AABB.
    }

    vec3 TemporalReprojection(vec2 screenCoord, vec2 motion, vec2 dd, vec3 colour) {
        vec3 currentSample = colour;
        vec3 previousSample = DecodeColour(texture2D(colortex3, screenCoord - motion).rgb);

        vec2 du = vec2(dd.x, 0.0);
        vec2 dv = vec2(0.0, dd.y);

        // Minmax3x3
        vec3 ctl = DecodeColour(texture2D(colortex4, screenCoord - dv - du).rgb);
        vec3 ctc = DecodeColour(texture2D(colortex4, screenCoord - dv     ).rgb);
        vec3 ctr = DecodeColour(texture2D(colortex4, screenCoord - dv + du).rgb);
        vec3 cml = DecodeColour(texture2D(colortex4, screenCoord      - du).rgb);
        vec3 cmc = DecodeColour(texture2D(colortex4, screenCoord          ).rgb);
        vec3 cmr = DecodeColour(texture2D(colortex4, screenCoord      + du).rgb);
        vec3 cbl = DecodeColour(texture2D(colortex4, screenCoord + dv - du).rgb);
        vec3 cbc = DecodeColour(texture2D(colortex4, screenCoord + dv     ).rgb);
        vec3 cbr = DecodeColour(texture2D(colortex4, screenCoord + dv + du).rgb);

        vec3 cmin = min(ctl, min(ctc, min(ctr, min(cml, min(cmc, min(cmr, min(cbl, min(cbc, cbr))))))));
        vec3 cmax = max(ctl, max(ctc, max(ctr, max(cml, max(cmc, max(cmr, max(cbl, max(cbc, cbr))))))));

        // If 3x3rounded YCOCG or clipping.
        vec3 cavg = (ctl + ctc + ctr + cml + cmc + cmr + cbl + cbc + cbr) * 0.1111111111;

        // 3x3 rounding.
        vec3 cmin5 = min(ctc, min(cml, min(cmc, min(cmr, cbc))));
        vec3 cmax5 = max(ctc, max(cml, max(cmc, max(cmr, cbc))));
        vec3 cavg5 = (ctc + cml + cmc + cmr + cbc) * 0.2;
        cmin = 0.5 * (cmin + cmin5);
        cmax = 0.5 * (cmax + cmax5);
	    cavg = 0.5 * (cavg + cavg5);

        /*
            vec2 chroma_extent = 0.25 * 0.5 * (cmax.r - cmin.r);
            vec2 chroma_center = texel0.gb;
            cmin.yz = chroma_center - chroma_extent;
            cmax.yz = chroma_center + chroma_extent;
            cavg.yz = chroma_center;
        */

        // Clipping.
        previousSample = ClipAABB(cmin.xyz, cmax.xyz, clamp(cavg, cmin, cmax), previousSample);

        // No clip?
        //previousSample = clamp(previousSample, cmin, cmax);

        // Lum, if using YCOCG just R channel.
        float currentLum = luma(currentSample);
        float previousLum = luma(previousSample);

        float unbiasedDiff = abs(currentLum - previousLum) / max(currentLum, max(previousLum, 0.2));
        float unbiasedWeight = 1.0 - unbiasedDiff;
        float unbiasedWeightSqr = pow2(unbiasedWeight);
        float kFeedback = mix(0.77, 0.97, unbiasedWeightSqr);

        return mix(currentSample, previousSample, kFeedback);
    }

    vec3 CalculateTAA(vec3 currentFrame, vec2 screenCoord) {
        #ifndef TAA
            return currentFrame;
        #endif

        vec2 pixelSize = 1.0 / vec2(viewWidth, viewHeight);

        vec3 closestFrag = FindClosestFragment3x3(screenCoord, pixelSize);
        float closestDepth = texture2D(depthtex0, closestFrag.xy).x;
        vec2 motion = CalculateCameraMotion(closestFrag);

        if(closestDepth < 0.7) return currentFrame;

        return TemporalReprojection(screenCoord, motion, pixelSize, currentFrame);
    }

#endif
