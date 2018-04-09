/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_COMMON_SKY
    #define INCLUDED_COMMON_SKY

    #include "/lib/util/SpaceTransform.glsl"

    #include "/lib/common/Atmosphere.fsh"

    vec3 CalculateSky(const vec3 viewPosition) {
        return CalculateScatter(vec3(0.0), normalize(viewPosition), 0);
    }

#endif
