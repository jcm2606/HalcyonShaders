/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_SYNTAX
    #define INCLUDED_SYNTAX

    // Shorthand Notation.
    #define saturate(x) clamp(x, 0.0, 1.0)

    #define rcp(x) ( 1.0 / x )

    #define io inout

    #define flat(type) flat varying type

    #define viewPositionEye  vec3(0.0)
    #define worldPositionEye gbufferModelViewInverse[3].xyz
    #define worldPositionUp  vec3(0.0, 1.0, 0.0)

    #define viewDirectionUp  gbufferModelView[1].xyz
    #define worldDirectionUp vec3(0.0, 1.0, 0.0)

    #define underWater ( isEyeInWater == 1 )
    #define underLava  ( isEyeInWater == 2 )

    #define timeNoon    timeVector.x
    #define timeNight   timeVector.y
    #define timeHorizon timeVector.z
    #define timeMorning timeVector.w

    // GLSL 120/410 Compatibility.
    #if STAGE == VSH
        #define attribute in
        #define varying out
    #else
        #define varying in
    #endif

#endif
