/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_DEFERRED_CAMERA
    #define INCLUDED_DEFERRED_CAMERA
    
    // Bokeh.
    #if PROGRAM == COMPOSITE0
        vec3 CalculateBokeh(vec2 screenCoord, vec2 offset, float lod) {
            const float a = tau / LENS_BLADES;
            const mat2 rot = mat2(cos(a), -sin(a), sin(a), cos(a));
            const vec3 size = 0.4 * vec3(1.0 - vec2(LENS_SHIFT, LENS_SHIFT * 0.5), 1.0);

            vec2 coord = (screenCoord - offset) * exp2(lod);

            float r = 0.0;

            const vec2 caddv = vec2(sin(LENS_ROTATION), -cos(LENS_ROTATION));
            vec2 addv = caddv;

            vec2 centerOffset = coord - 0.5;

            for(int i = 0; i < LENS_BLADES; ++i) {
                addv = rot * addv;
                r = max(r, dot(addv, centerOffset));
            }

            r = mix(r, fLength(centerOffset) * 0.8, LENS_ROUNDING);

            vec3 bokeh = saturate(1.0 - smoothstep(size * LENS_SHARPNESS, size, vec3(r)));
                 bokeh = bokeh * (1.0 - saturate(smoothstep(size, size * LENS_SHARPNESS * 0.8, vec3(r)) * LENS_BIAS));

            return bokeh;
        }
    #endif

    // Exposure.
    #if PROGRAM == COMPOSITE2
        vec3 CalculateExposedImage(const vec3 image, float averageLuma) {
            #ifndef EXPOSURE_AUTO
                averageLuma = EXPOSURE;
            #else
                averageLuma = max(0.0, 0.7 / (averageLuma + mix(0.001, 0.1, timeNight)));
            #endif

            return image * averageLuma;
        }
    #endif

    // Depth of Field.
    #if PROGRAM == COMPOSITE2
        #include "/lib/util/SpaceTransform.glsl"

        float CalculateFocus(float depth) {
            const float focalLength = CAMERA_FOCAL_LENGTH / 1000.0;
            const float aperture    = (CAMERA_FOCAL_LENGTH / CAMERA_APERTURE) / 1000.0;

            #if   CAMERA_FOCUS_MODE == 1
                float focus = ClipToViewDepth(centerDepthSmooth);
            #elif CAMERA_FOCUS_MODE == 0
                float focus = ClipToViewDepth(getDepthExp(CAMERA_MANUAL_FOCUS));//ClipToViewDepth(CAMERA_MANUAL_FOCUS);
            #endif

            return aperture * (focalLength * (focus - depth)) / (focus * (depth - focalLength));
        }

        vec2 CalculateDistOffset(vec2 prep, float angle, vec2 offset, vec2 anamorphic) {
            vec2 oldOffset = offset * anamorphic;
            return oldOffset * angle + prep * dot(prep, oldOffset) * (1.0 - angle);
        }

        vec3 CalculateDOF(vec2 screenCoord) {
            #ifndef DOF
                return DecodeColour(texture2DLod(colortex4, screenCoord, 0).rgb);
            #endif

            // Note: If Optifine allows repurposing of depthtex2 for back face depth, we'll need to switch this over to a proper material mask.
            if(texture2D(depthtex2, screenCoord).x > texture2D(depthtex1, screenCoord).x)
                return DecodeColour(texture2DLod(colortex4, screenCoord, 0).rgb);

            const int   samples    = DOF_SAMPLES;
            const float samplesRCP = rcp(samples);

            vec3 dof    = vec3(0.0);
            vec3 weight = vec3(0.0);

            float r = 1.0;
            const mat2 rot = mat2(
                cos(goldenAngle), -sin(goldenAngle),
                sin(goldenAngle),  cos(goldenAngle)
            );

            const float focalLength = 35.0 / 1000.0;
            const float aperture    = (35.0 / CAMERA_APERTURE) / 1000.0;

            float depth = ClipToViewDepth(texture2D(depthtex1, screenCoord).x);
            float pcoc  = CalculateFocus(depth);

            #ifdef CAMERA_FOCUS_PREVIEW
                return vec3(abs(pcoc) * 1000.0);
            #endif

            vec2 pcocAngle   = vec2(0.0, pcoc);
            vec2 sampleAngle = vec2(0.0, 1.0);

            const float sizeCorrection = 1.0 / (sqrt(samples) * 1.35914091423) * 0.5;
            const float apertureScale  = sizeCorrection * aperture * 1000.0;

            const float inverseIter05 = mix(0.1, 1.0, samples / 1024.0) / samples;
            float lod = log2(abs(pcoc) * viewHeight * viewWidth * inverseIter05);

            vec2 distOffsetScale = apertureScale * vec2(1.0, aspectRatio);

            vec2 toCenter = screenCoord - 0.5;
            vec2 prep = normalize(vec2(toCenter.y, -toCenter.x));
            float lToCenter = fLength(toCenter);
            float angle = cos(lToCenter * 2.221 * DOF_DISTORTION_BARREL);

            for(int i = 0; i < samples; ++i) {
                r += rcp(r);

                pcocAngle = rot * pcocAngle;
                sampleAngle = rot * sampleAngle;

                vec2 pos = CalculateDistOffset(prep, 1.0, (r - 1.0) * sampleAngle, vec2(1.0)) * sizeCorrection + 0.5;
                vec3 bokeh = texture2D(colortex5, pos * 0.25 + BOKEH_OFFSET).rgb;

                pos = CalculateDistOffset(prep, angle, (r - 1.0) * pcocAngle, vec2(DOF_DISTORTION_ANAMORPHIC, 1.0 / DOF_DISTORTION_ANAMORPHIC)) * distOffsetScale;

                dof += DecodeColour(texture2DLod(colortex4, screenCoord + pos, lod).rgb) * bokeh;
                weight += bokeh;
            }

            return dof / weight;
        }
    #endif

#endif
