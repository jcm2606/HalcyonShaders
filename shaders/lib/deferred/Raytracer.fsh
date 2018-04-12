/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_DEFERRED_RAYTRACER
    #define INCLUDED_DEFERRED_RAYTRACER

    #include "/lib/util/SpaceTransform.glsl"

    #include "/lib/common/Atmosphere.fsh"

    vec3 RaytraceClipJodie(vec3 viewPosition, vec3 viewDirection, vec3 clipPosition, float skyLight) {
        // This is Jodie's new clip space ray tracer.
        // While in theory this one should be faster, in my experience you need to use way more steps to achieve the same result as the old one.
        // The problem with this is the result seems to have obvious clipping issues, where the ray tracer seemingly only picks up part of the surface during the intersection check.
        // The only way to fix it is to crank up the steps.

        const float quality = SPECULAR_RAYTRACER_0_QUALITY;
        int refinements = SPECULAR_RAYTRACER_0_REFINEMENTS;
        const float maxLength = 1.0 / quality;
        const float minLength = 0.1 / quality;

        vec3 direction = normalize(ViewToClipPosition(viewPosition + viewDirection) - clipPosition);
        float rz = 1.0 / abs(direction.z);

        vec3 skyReflection = CalculateScatter(vec3(0.0), viewDirection, 1) * skyLight;

        float stepLength = minLength;
        float depth = clipPosition.z;

        while(depth >= clipPosition.z) {
            stepLength = clamp((depth - clipPosition.z) * rz, minLength, maxLength);
            clipPosition += direction * stepLength;

            if(saturate(clipPosition) != clipPosition)
                return skyReflection; // Exit early if the ray goes off screen.

            depth = texture2D(depthtex1, clipPosition.xy).x;
        }

        while(--refinements > 0) {
            vec3 clipPositionReflected = clipPosition + direction * clamp((depth - clipPosition.z) * rz, -stepLength, stepLength);

            float depthReflected = texture2D(depthtex1, clipPositionReflected.xy).x;
            bool intersecting = depthReflected < clipPositionReflected.z;

            clipPosition = (intersecting) ? clipPositionReflected : clipPosition;
            depth = (intersecting) ? depthReflected : depth;

            stepLength *= 0.5;
        }

        bool visible = distance(ClipToViewPosition(clipPosition.xy, depth), ClipToViewPosition(clipPosition.xy, clipPosition.z)) < 1.0;

        return (visible) ? DecodeColour(texture2DLod(colortex4, clipPosition.xy, 0).rgb) : skyReflection;
    }

    #define faceVisible() abs(clipPosition.z - depth) < abs(stepLength * direction.z)
    #define onScreen() ( floor(clipPosition.xy) == vec2(0.0) )

    vec3 RaytraceClipStein(const vec3 viewPosition, const vec3 viewDirection, vec3 clipPosition, const float skyLight) {
        // This is a modified version of Jodie's old clip space ray tracer.
        // The biggest modification is the binary search refinement system, borrowed from her new ray tracer.
        // The reason why I use this over the new one is the new one has issues with reflections clipping when parallel to the surface.
        // This one also seems to run a good bit faster on my end, for more or less the same results.

        const int   quality    = SPECULAR_RAYTRACER_1_QUALITY;
        const float qualityRCP = rcp(quality);

        int steps = quality + 4;
        int refinements = SPECULAR_RAYTRACER_1_REFINEMENTS;

        vec3 skyReflection = CalculateScatter(vec3(0.0), viewDirection, 1) * skyLight;

        vec3 direction = normalize(ViewToClipPosition(viewPosition + viewDirection) - clipPosition);
        direction.xy = normalize(direction.xy);

        vec3 maxLengths = (step(0.0, direction) - clipPosition) / direction;

        float maxStepLength = min3v(maxLengths) * qualityRCP;
        float minStepLength = maxStepLength * 0.1;

        float stepLength = minStepLength;
        float stepWeight = 1.0 / abs(direction.z);

        clipPosition += direction * stepLength;

        float depth = texture2D(depthtex2, clipPosition.xy).x;

        bool rayHit = false;

        while(--steps > 0) {
            // March a ray out from the surface to find any intersections.

            rayHit = depth < clipPosition.z;

            if(!onScreen())
                return skyReflection; // If the ray goes off the screen, then we can return the sky reflection, as it won't hit anything.

            if(rayHit)
                break; // If the ray hits something, break out of the loop.

            stepLength = (depth - clipPosition.z) * stepWeight;
            stepLength = clamp(stepLength, minStepLength, maxStepLength);

            clipPosition = direction * stepLength + clipPosition;

            depth = texture2D(depthtex2, clipPosition.xy).x;
        }

        while(--refinements > 0) {
            // Refine the hit result to make it more accurate.

            clipPosition += direction * clamp((depth - clipPosition.z) * stepWeight, -stepLength, stepLength);
            depth = texture2D(depthtex2, clipPosition.xy).x;
            stepLength *= 0.5;
        }

        if(
            faceVisible() + 0.001 // Not a back face.
            && depth < 1.0 // Not the sky.
            && 0.95 < clipPosition.z // Not camera clipping.
            && rayHit
        ) return DecodeColour(texture2DLod(colortex4, clipPosition.xy, 0).rgb);

        return skyReflection;
    }

    #undef faceVisible
    #undef onScreen

#endif
