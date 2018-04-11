/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

// Header.
#extension GL_EXT_gpu_shader4 : require

#include "/lib/syntax/Form.glsl"
#define STAGE FSH
#define PROGRAM COMPOSITE0
#include "/lib/Syntax.glsl"
#include "/lib/Utility.glsl"
#include "/lib/Settings.glsl"

// Used Screen Buffers.
#define IN_TEX0
#define IN_TEX1
#define IN_TEX4
#define IN_TEX5

// Constants.
const bool colortex4MipmapEnabled = true;

// Varyings.
varying vec2 screenCoord;

flat(vec3) sunDirection;
flat(vec3) moonDirection;
flat(vec3) lightDirection;

// Screen Samples.
// Uniforms.
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex4;
uniform sampler2D colortex5;

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowcolor1;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D depthtex2;

uniform mat4 gbufferProjection, gbufferProjectionInverse;
uniform mat4 gbufferModelView, gbufferModelViewInverse;

uniform mat4 shadowProjection, shadowProjectionInverse;
uniform mat4 shadowModelView, shadowModelViewInverse;

uniform vec3 cameraPosition;

uniform float sunAngle;
uniform float near;
uniform float far;
uniform float viewWidth;
uniform float viewHeight;

uniform int isEyeInWater;
uniform int frameCounter;

// Structs.
#include "/lib/struct/ScreenObject.fsh"
#include "/lib/struct/SurfaceObject.fsh"
#include "/lib/struct/MaterialObject.fsh"

// Globals.
// Includes.
#include "/lib/util/SpaceTransform.glsl"

#include "/lib/common/Atmosphere.fsh"
#include "/lib/common/DiffuseLighting.fsh"

#include "/lib/deferred/Atmospherics.fsh"

#include "/lib/deferred/SpecularLighting.fsh"

// Functions.
// Main.
void main() {
    ScreenObject screenObject = CreateScreenObject(screenCoord);
    SurfaceObject surfaceObject = CreateSurfaceObject(screenObject);
    MaterialObject materialObject = CreateMaterialObject(surfaceObject);

    float depthBack  = texture2D(depthtex1, screenCoord).x;
    float depthFront = texture2D(depthtex0, screenCoord).x;

    vec3 viewPositionBack  = ClipToViewPosition(screenCoord, depthBack);
    vec3 viewPositionFront = ClipToViewPosition(screenCoord, depthFront);

    vec3 worldPositionBack  = ViewToWorldPosition(viewPositionBack);
    vec3 worldPositionFront = ViewToWorldPosition(viewPositionFront);

    const float ditherScale = pow(64.0, 2.0);
    vec2 dither   = vec2(Bayer64(gl_FragCoord.xy), ditherScale);
    #ifdef TAA
         dither.x = DitherJitter(dither.x, 64.0);
    #endif

    vec3 image = DecodeColour(screenObject.tex4.rgb);

    vec4 transparentGeometry     = screenObject.tex5;
         transparentGeometry.rgb = ToLinear(transparentGeometry.rgb);
    
    bool isTransparentPixel = depthBack > depthFront;

    mat2x3 atmosphereLighting = CalculateAtmosphereLighting();

    if(isTransparentPixel)
         transparentGeometry.rgb = CalculateShadedFragment(materialObject, surfaceObject, atmosphereLighting, transparentGeometry.rgb, viewPositionFront, screenCoord, dither);

    bool isSkyPixel = !getLandMask(depthBack);
    bool isWaterPixel = materialObject.water;

    float VoL = max0(dot(normalize(viewPositionBack), lightDirection));
    float distFront = distance(viewPositionEye, viewPositionFront);

    mat2x3 atmosphericsVolumeFront = CalculateAtmosphericsVolume(atmosphereLighting, (underWater) ? worldPositionFront : worldPositionEye, (underWater) ? worldPositionBack : worldPositionFront, vec3(1.0), screenCoord, dither, VoL, distFront, false, isSkyPixel, false, isTransparentPixel);

    if(isTransparentPixel || underWater) {
        mat2x3 atmosphericsVolumeBack = CalculateAtmosphericsVolume(atmosphereLighting, (underWater) ? worldPositionEye : worldPositionFront, (underWater) ? worldPositionFront : worldPositionBack, atmosphericsVolumeFront[1], screenCoord, dither, VoL, distFront, true, isSkyPixel, isWaterPixel || underWater, isTransparentPixel);

        image *= atmosphericsVolumeBack[1];

        atmosphericsVolumeFront[0] += atmosphericsVolumeBack[0];
    }

    image = mix(image, transparentGeometry.rgb, transparentGeometry.a);

    if(getLandMask(depthFront) && !underWater && !underLava)
        image = CalculateSpecularLighting(surfaceObject, atmosphereLighting, image, vec3(1.0), viewPositionFront, screenCoord, dither, depthFront);

    image = image * atmosphericsVolumeFront[1] + atmosphericsVolumeFront[0];
    
    /* DRAWBUFFERS:4 */
    gl_FragData[0] = vec4(EncodeColour(image), 1.0);
}
// EOF.
