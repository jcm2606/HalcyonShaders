/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_SETTINGS
    #define INCLUDED_SETTINGS

    #if PROGRAM == DEFERRED0
        // Optifine Configuration.
        /*
        const int colortex0Format = RGB32F;
        const int colortex1Format = RGB32F;
        const int colortex3Format = RGBA16F;
        const int colortex4Format = RGBA16F;

        const bool colortex3Clear = false;

        const bool shadowtex0Mipmap = false;
        const bool shadowtex1Mipmap = false;
        const bool shadowcolor0Mipmap = false;
        const bool shadowcolor1Mipmap = false;
        */

        const float sunPathRotation = -40.0; // How rotated should the sun be, relative to the world?. [-70.0 -65.0 -60.0 -55.0 -50.0 -45.0 -40.0 -35.0 -30.0 -25.0 -20.0 -15.0 -10.0 -5.0 0.0 5.0 10.0 15.0 20.0 25.0 30.0 35.0 40.0 45.0 50.0 55.0 60.0 65.0 70.0]
        const int noiseTextureResolution = 64;
    #endif

    // Internal Configuration.
    #define GLOBAL_TIME 1.0
    #define TIME ( frameTimeCounter * GLOBAL_TIME )

    //#define NO_ALBEDO

    #define SEA_LEVEL 63.0

    const float materialIDRange = 255.0;
    const float materialIDMult  = rcp(materialIDRange);

    // Camera / Post Processing Configuration.
    #define EXPOSURE 1.0

    // Parallax Configuration.
    #define PARALLAX_TERRAIN
    #define PARALLAX_TERRAIN_DEPTH 1.0 // [0.125 0.14286 0.16667 0.2 0.25 0.33333 0.5 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0]
    const float parallaxTerrainDepth = PARALLAX_TERRAIN_DEPTH * 0.5;

    #define PARALLAX_TERRAIN_SHADOW

    #ifdef PARALLAX_TERRAIN_SHADOW
    #endif

    // Shadow Configuration.
    #define cutShadow ceil // [floor ceil sign]

    #define SHADOW_DISTORTION_FACTOR 0.9 // [0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95]

    #define SHADOW_QUALITY 12 // [8 10 12 14 16 18 20 22 24 26 28 30 32]

    const float shadowDepthBlocks = 1024.0;
    const float shadowDepthMult   = 256.0 / shadowDepthBlocks;

    const float shadowDistance = 160.0; // Needs to be `16 * (renderDistance + 2)` to properly capture the whole world reliably. [160.0 288.0 416.0 544.0 800.0 1056.0]
    const float shadowDistanceRCP = rcp(shadowDistance);
    const float shadowDistanceScale = 160.0 / shadowDistance;

    const int shadowMapResolution = 2048; // [512 1024 2048 3072 4096 8192 16384]
    const float shadowMapResolutionRCP = rcp(shadowMapResolution);

    // Lighting Configuration.
    #define LIGHT_SUN_INTENSITY 32.0
    #define LIGHT_MOON_INTENSITY 0.0004

    // Sky Configuration.
    #define SUN_SPOT_MULTIPLIER 2.0
    #define MOON_SPOT_MULTIPLIER 100.0

    #define SUN_SIZE 1.0
    #define MOON_SIZE 1.0

    // Material Configuration.
    #define MATERIAL_FORMAT 2 // [0 1 2 3 4]

    /*
        Material Key:

            vec4(x, y, z, w)
        
        'x' = smoothness = 1.0 - roughness
        'y' = f0
        'z' = emission
        'w' = placeholder
    */
    
    #define SURFACE_DEFAULT vec4(0.0, 0.02, 0.0, 0.0)
    #define SURFACE_WATER vec4(0.95, 0.021, 0.0, 0.0)
    
    // Atmospherics Configuration.
    #define ATMOSPHERICS
    #define ATMOSPHERICS_STEPS 8 // [1 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32]

    // Atmospherics Layers.
    // Air.
    #define ATMOSPHERICS_AIR_HEIGHT 384.0 // [32.0 64.0 96.0 128.0]
    #define ATMOSPHERICS_AIR_DENSITY 2.5 // [1.0 2.5 5.0 7.5 10.0 12.5 15.0 20.0 25.0 30.0 35.0 40.0 45.0 50.0]

    // Fog.
    const vec3 fogScatterCoeff = vec3(0.1) / log(2.0);
    const vec3 fogAbsorbCoeff  = vec3(0.01) / log(2.0);

    const vec3 fogTransmittanceCoeff = fogScatterCoeff + fogAbsorbCoeff;

    #define ATMOSPHERICS_HEIGHT_FOG
    #define ATMOSPHERICS_HEIGHT_FOG_HEIGHT 64.0
    #define ATMOSPHERICS_HEIGHT_FOG_DENSITY 0.02

    //#define ATMOSPHERICS_MIST_FOG
    #define ATMOSPHERICS_MIST_FOG_HEIGHT 8.0
    #define ATMOSPHERICS_MIST_FOG_DENSITY 0.1

    // Water.
    const vec3 waterScatterCoeff = vec3(1.0) * 0.001 / log(2.0);
    const vec3 waterAbsorbCoeff  = vec3(0.4510, 0.0867, 0.0476) / log(2.0);

    const vec3 waterTransmittanceCoeff = waterScatterCoeff + waterAbsorbCoeff;

    #define ATMOSPHERICS_WATER_DENSITY 1.0

    // Specular Configuration.
    #define SPECULAR_SSR RoughSSR // Which method of screen space reflections should the shader use?. Rough SSR allows reflections to get softer with respect to roughness, but is slower than Smooth SSR. [RoughSSR]

    #define SPECULAR_SSR_ROUGH_SAMPLES 3 // How many samples should Rough SSR use?. More samples removes the grain, at the cost of performance. [2 3 4 5 6 7 8 9 10 11 12 13 14 15 16]

    #define SPECULAR_RAYTRACER RaytraceClipStein // Which ray tracer should SSR use?. This can influence the quality and cost of screen space reflections substantially. [RaytraceClipJodie RaytraceClipStein]

    #define SPECULAR_RAYTRACER_0_QUALITY 16.0
    #define SPECULAR_RAYTRACER_0_REFINEMENTS 8

    #define SPECULAR_RAYTRACER_1_QUALITY 4 // To get the amount of steps, add 4 to this number. [2 3 4 5 6 7 8 9 10 11 12 13 14 15 16]
    #define SPECULAR_RAYTRACER_1_REFINEMENTS 4

    // TAA Configuration.
    #define TAA

#endif
