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
        const int colortex3Format = RGBA32F;
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
    #define TIME_MULT 1.0 // [0.0 0.083333 0.090909 0.1 0.111111 0.125 0.142857 0.166667 0.2 0.25 0.333333 0.5 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0]
    #define TIME_SCRUB_MAJOR 0.0 // [-10.0 -9.0 -8.0 -7.0 -6.0 -5.0 -4.0 -3.0 -2.0 -1.0 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0]
    #define TIME_SCRUB_MINOR 0.0 // [-10.0 -9.0 -8.0 -7.0 -6.0 -5.0 -4.0 -3.0 -2.0 -1.0 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0]

    #define TIME ( frameTimeCounter * TIME_MULT + TIME_SCRUB_MAJOR * 10.0 + TIME_SCRUB_MINOR )

    //#define NO_ALBEDO

    #define SEA_LEVEL 63.0 // [4.0 63.0]

    #define NORMAL_MAPS

    #ifdef NORMAL_MAPS
    #endif

    const float materialIDRange = 255.0;
    const float materialIDMult  = rcp(materialIDRange);

    // Camera / Post Processing Configuration.
    #define DOF
    #define DOF_SAMPLES 64 // [32 64 96 128 160 192 224 256 288 320 352 384 416 448 480 512 544 576 608 640 672 704 736 768 800 832 864 896 928 960 992 1024]
    #define DOF_DISTORTION_ANAMORPHIC 1.0
    #define DOF_DISTORTION_BARREL 0.6

    #define EXPOSURE 1.0 // [0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0 3.2 3.4 3.6 3.8 4.0]
    #define EXPOSURE_AUTO

    const float exposure = EXPOSURE * 0.125;

    #define CAMERA_FOCUS_MODE 1 // [0 1]
    #define CAMERA_MANUAL_FOCUS 96.0 // [8.0 16.0 24.0 32.0 40.0 48.0 56.0 64.0 72.0 80.0 88.0 96.0 104.0 112.0 120.0 128.0 136.0 144.0 152.0 160.0 168.0 176.0 184.0 192.0 200.0 208.0 216.0 224.0 232.0 240.0 248.0 256.0]
    //#define CAMERA_FOCUS_PREVIEW

    #define CAMERA_FOCAL_LENGTH 50.0 // [25.0 50.0 75.0 100.0 125.0 150.0 175.0 200.0 225.0 250.0 275.0 300.0 325.0 350.0 375.0 400.0 425.0 450.0 475.0 500.0 525.0 550.0 575.0 600.0 625.0 650.0 675.0 700.0 725.0 750.0 775.0 800.0 825.0 850.0 875.0 900.0 925.0 950.0 975.0 1000.0 1025.0 1050.0 1075.0 1100.0 1125.0 1150.0 1175.0 1200.0 1225.0 1250.0]
    #define CAMERA_APERTURE 2.8

    #define LENS_BLADES 1 // [1 3 4 5 6 7 8 9 10 11 12]
    #define LENS_SHIFT 0.2 // [0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]
    #define LENS_ROTATION 0.0 // [0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]
    #define LENS_ROUNDING 1.0 // [0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]
    #define LENS_BIAS 0.95 // [0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]
    #define LENS_SHARPNESS 0.0 // [0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]
    //#define LENS_PREVIEW

    #define BOKEH_OFFSET vec2(0.375, 0.35)

    // Parallax Configuration.
    #define PARALLAX_TERRAIN
    #define PARALLAX_TERRAIN_DEPTH 1.0 // [0.0625 0.125 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0 2.25 2.5 2.75 3.0]
    const float parallaxTerrainDepth = PARALLAX_TERRAIN_DEPTH * 0.5;

    #define PARALLAX_TERRAIN_SHADOW

    #ifdef PARALLAX_TERRAIN_SHADOW
    #endif

    #define PARALLAX_WATER
    #define PARALLAX_WATER_STEPS 4
    #define PARALLAX_WATER_HEIGHT 4.0

    // Shadow Configuration.
    #define cutShadow ceil // [floor ceil sign]

    #define SHADOW_DISTORTION_FACTOR 0.9 // [0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95]

    #define SHADOW_QUALITY 12 // [4 6 8 10 12 14 16 18 20 22 24 26 28 30 32]
    #define SHADOW_BLOCKER_QUALITY 8 // [4 6 8 10 12 14 16 18 20 22 24 26 28 30 32]

    const float shadowDepthBlocks = 1024.0;
    const float shadowDepthMult   = 256.0 / shadowDepthBlocks;

    const float shadowDistance = 160.0; // Needs to be `16 * (renderDistance + 2)` to properly capture the whole world reliably. [160.0 288.0 416.0 544.0 800.0 1056.0]
    const float shadowDistanceRCP = rcp(shadowDistance);
    const float shadowDistanceScale = 160.0 / shadowDistance;

    const int shadowMapResolution = 2048; // [512 1024 2048 3072 4096 8192 16384]
    const float shadowMapResolutionRCP = rcp(shadowMapResolution);

    // Lighting Configuration.
    #define LIGHT_SUN_INTENSITY 32.0
    #define LIGHT_MOON_INTENSITY 0.006

    #define BLOCK_LIGHT_ANISOTROPY 0.5 // [0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75]
    #define BLOCK_LIGHT_BRIGHTNESS 1.0 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
    #define BLOCK_LIGHT_TEMPERATURE 3700 // [3700 6500]

    #define SKY_LIGHT_ANISOTROPY 0.5 // [0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75]

    // Sky Configuration.
    #define SUN_SPOT_MULTIPLIER 0.1
    #define MOON_SPOT_MULTIPLIER 100.0

    #define SUN_SIZE 1.0
    #define MOON_SIZE 1.0

    // Material Configuration.
    #define MATERIAL_FORMAT 2 // [0 1 2 3 4]

    #define F0_DIELECTRIC 0.02
    #define F0_WATER 0.021
    #define F0_METALLIC 0.8

    /*
        Material Key:

            vec4(x, y, z, w)
        
        'x' = smoothness = 1.0 - roughness
        'y' = f0
        'z' = emission
        'w' = placeholder
    */
    
    #define SURFACE_DEFAULT vec4(0.0, F0_DIELECTRIC, 0.0, 0.0)
    #define SURFACE_WATER vec4(0.95, F0_WATER, 0.0, 0.0)
    #define SURFACE_STAINED_GLASS vec4(0.97, F0_DIELECTRIC, 0.0, 0.0)
    
    // Volumetrics Configuration.
    #define VOLUMETRICS

    // Volumetric Clouds Configuration.
    #define CLOUDS
    #define CLOUDS_STEPS 8 // [4 5 6 7 8 9 10 11 12 13 14 15 16]
    #define CLOUDS_DETAIL 6 // [4 5 6 7 8 9]

    #define CLOUDS_ALTITUDE 1536.0 // [512.0 768.0 1024.0 1280.0 1536.0 1792.0 2048.0]
    #define CLOUDS_HEIGHT 512.0 // [256.0 512.0 768.0 1024.0 1280.0 1536.0 1792.0 2048.0]
    #define CLOUDS_SCALE 1.0 // [0.7 0.8 0.9 1.0 1.1 1.2 1.3]
    #define CLOUDS_SPEED 1.0 // [1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0 13.0 14.0 15.0]

    #define CLOUDS_COVERAGE_CLEAR 1.1 // [0.7 0.75 0.8 0.85 0.9 0.95 1.0 1.05 1.1 1.15 1.2 1.25]
    #define CLOUDS_COVERAGE_RAIN 0.75

    #define CLOUDS_DENSITY_CLEAR 1.1 // [0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0]
    #define CLOUDS_DENSITY_RAIN 1.0 // [0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0]

    #define CLOUDS_OPACITY 1.0

    const float cloudDensityClear = CLOUDS_DENSITY_CLEAR * CLOUDS_OPACITY;
    const float cloudDensityRain  = CLOUDS_DENSITY_RAIN * CLOUDS_OPACITY;

    #define CLOUDS_LIGHTING_DENSITY 300.0
    const float cloudLightingDensity = CLOUDS_LIGHTING_DENSITY / CLOUDS_OPACITY;

    #define CLOUDS_LIGHTING_DIRECT_STEPS 4 // [0 1 2 3 4 5 6 7 8 9 10 11 12]
    const float cloudLightingDensityDirect = cloudLightingDensity;

    #define CLOUDS_LIGHTING_SKY_STEPS 1 // [0 1 2 3 4 5 6 7 8 9 10 11 12]
    const float cloudLightingDensitySky = cloudLightingDensity * piRCP;

    #define CLOUDS_LIGHTING_BOUNCED_STEPS 0 // [0 1 2 3 4 5 6 7 8 9 10 11 12]
    const float cloudLightingDensityBounced = cloudLightingDensity * piRCP;
    #define CLOUDS_LIGHTING_BOUNCED_BRIGHTNESS 0.1

    #define CLOUDS_SHADOW
    #define CLOUDS_SHADOW_STEPS 1 // [1 2 3 4 5]
    #define CLOUDS_SHADOW_DENSITY_MULT 0.5

    #ifdef CLOUDS_SHADOW
    #endif

    #define CLOUDS_HORIZON_FADE 0.05

    // Atmospherics Configuration.
    #define ATMOSPHERICS
    #define ATMOSPHERICS_STEPS 8 // [1 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32]

    // Atmospherics Lighting.
    #define ATMOSPHERICS_LIGHTING_SKY_SHADOW 1 // [0 1]

    // Atmospherics Layers.
    // Air.
    #define ATMOSPHERICS_AIR
    #define ATMOSPHERICS_AIR_HEIGHT 384.0 // [32.0 64.0 96.0 128.0]
    #define ATMOSPHERICS_AIR_DENSITY 5.0 // [1.0 2.5 5.0 7.5 10.0 12.5 15.0 20.0 25.0 30.0 35.0 40.0 45.0 50.0]

    // Fog.
    #define ATMOSPHERICS_FOG

    const vec3 fogScatterCoeff = vec3(0.1) / log(2.0);
    const vec3 fogAbsorbCoeff  = vec3(0.01) / log(2.0);

    const vec3 fogTransmittanceCoeff = fogScatterCoeff + fogAbsorbCoeff;

    #define ATMOSPHERICS_HEIGHT_FOG
    #define ATMOSPHERICS_HEIGHT_FOG_HEIGHT 64.0
    #define ATMOSPHERICS_HEIGHT_FOG_DENSITY 0.02

    //#define ATMOSPHERICS_MIST_FOG
    #define ATMOSPHERICS_MIST_FOG_HEIGHT 8.0 // [4.0 6.0 8.0 10.0 12.0 14.0 16.0 18.0 20.0 22.0 24.0 26.0 28.0 30.0 32.0]
    #define ATMOSPHERICS_MIST_FOG_DENSITY 0.1 // [0.01 0.025 0.05 0.075 0.1 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5]

    #define ATMOSPHERICS_NIGHT_FOG

    //#define ATMOSPHERICS_GROUND_FOG
    #define ATMOSPHERICS_GROUND_FOG_HEIGHT 2.0
    #define ATMOSPHERICS_GROUND_FOG_DENSITY 2.0 // [1.0 1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0 3.2 3.4 3.6 3.8 4.0 4.2 4.4 4.6 4.8 5.0]
    //#define ATMOSPHERICS_GROUND_FOG_ROLLING

    const float fogGroundDensity = ATMOSPHERICS_GROUND_FOG_DENSITY * 0.5;

    #define ATMOSPHERICS_RAIN_FOG
    #define ATMOSPHERICS_RAIN_FOG_HEIGHT 64.0
    #define ATMOSPHERICS_RAIN_FOG_DENSITY 0.2

    // Water.
    #define ATMOSPHERICS_WATER

    #define ATMOSPHERICS_WATER_TURBIDITY 1.0 // [0.0 0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0]
    #define ATMOSPHERICS_WATER_ABSORPTION 1.5 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4.0]

    const vec3 waterScatterCoeff = vec3(1.0) * ATMOSPHERICS_WATER_TURBIDITY * 0.002 / log(2.0);
    const vec3 waterAbsorbCoeff  = vec3(0.4510, 0.0867, 0.0476) * ATMOSPHERICS_WATER_ABSORPTION / log(2.0);

    const vec3 waterTransmittanceCoeff = waterScatterCoeff + waterAbsorbCoeff;

    #define ATMOSPHERICS_WATER_DENSITY 1.0

    // Specular Configuration.
    #define SPECULAR_SSR RoughSSR // Which method of screen space reflections should the shader use?. Rough SSR allows reflections to get softer with respect to roughness, but is slower than Smooth SSR. [RoughSSR]

    #define SPECULAR_SSR_ROUGH_SAMPLES 3 // How many samples should Rough SSR use?. More samples removes the grain, at the cost of performance. [2 3 4 5 6 7 8 9 10 11 12 13 14 15 16]

    #define SPECULAR_RAYTRACER RaytraceClipStein // Which ray tracer should SSR use?. 'Stein', short for 'Frankenstein', is the quicker and more reliable ray tracer, but can self reflect on the edges of the screen. 'Jodie' is overall more accurate, but is slower and can have very obvious banding artifacts when used at grazing angles. [RaytraceClipStein RaytraceClipJodie]

    #define SPECULAR_RAYTRACER_0_QUALITY 16.0
    #define SPECULAR_RAYTRACER_0_REFINEMENTS 8

    #define SPECULAR_RAYTRACER_1_QUALITY 4 // To get the amount of steps, add 4 to this number. [2 3 4 5 6 7 8 9 10 11 12 13 14 15 16]
    #define SPECULAR_RAYTRACER_1_REFINEMENTS 4

    // TAA Configuration.
    #define TAA

#endif
