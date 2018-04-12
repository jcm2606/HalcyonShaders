/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_DEFERRED_REFRACTION
    #define INCLUDED_DEFERRED_REFRACTION
    
    vec3 CalculateRefractedViewPosition(vec3 viewPositionBack, vec3 viewPositionFront, vec3 normal) {
        #define viewVector normalize(-viewPositionFront)
        #define flatNormal normalize(cross(dFdx(viewPositionFront), dFdy(viewPositionFront)))
        #define rayDirection refract(viewVector, normal - flatNormal, 0.75)

        return rayDirection * abs(distance(viewPositionBack, viewPositionFront) * 8.0) / viewPositionFront.z + viewPositionFront;

        #undef viewVector
        #undef flatNormal
        #undef rayDirection
    }

    vec3 CalculateRefractedClipPosition(vec3 viewPositionBack, vec3 viewPositionFront, vec3 normal) {
        vec3 clipPosition   = CalculateRefractedViewPosition(viewPositionBack, viewPositionFront, normal);
             clipPosition   = ViewToClipPosition(clipPosition);
             clipPosition.z = texture2D(depthtex1, clipPosition.xy).x;

        return clipPosition;
    }

#endif
