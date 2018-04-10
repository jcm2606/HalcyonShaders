/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

// Header.
#extension GL_EXT_gpu_shader4 : require

#include "/lib/syntax/Form.glsl"
#define STAGE FSH
#define PROGRAM DEFERRED1
#include "/lib/Syntax.glsl"
#include "/lib/Utility.glsl"
#include "/lib/Settings.glsl"

// Used Screen Buffers.
#define IN_TEX0
#define IN_TEX1
#define IN_TEX4

// Constants.
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

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowcolor1;

uniform sampler2D depthtex1;

uniform mat4 gbufferProjection, gbufferProjectionInverse;
uniform mat4 gbufferModelView, gbufferModelViewInverse;

uniform mat4 shadowProjection, shadowProjectionInverse;
uniform mat4 shadowModelView, shadowModelViewInverse;

uniform float sunAngle;
uniform float near;
uniform float far;

uniform int isEyeInWater;

// Structs.
#include "/lib/struct/ScreenObject.fsh"
#include "/lib/struct/SurfaceObject.fsh"
#include "/lib/struct/MaterialObject.fsh"

// Globals.
// Includes.
#include "/lib/util/SpaceTransform.glsl"

#include "/lib/common/Atmosphere.fsh"
#include "/lib/common/Sky.fsh"
#include "/lib/common/DiffuseLighting.fsh"

// Functions.
// Main.
void main() {
    ScreenObject screenObject = CreateScreenObject(screenCoord);
    SurfaceObject surfaceObject = CreateSurfaceObject(screenObject);
    MaterialObject materialObject = CreateMaterialObject(surfaceObject);

    float depthBack = texture2D(depthtex1, screenCoord).x;
    vec3 viewPosition = ClipToViewPosition(screenCoord, depthBack);

    const float ditherScale = pow(16.0, 2.0);
    vec2 dither = vec2(Bayer16(gl_FragCoord.xy), ditherScale);

    mat2x3 atmosphereLighting = CalculateAtmosphereLighting();

    vec3 image = screenObject.tex4.rgb;

    if(getLandMask(depthBack)) {
        // Is land.
         image = CalculateShadedFragment(materialObject, surfaceObject, atmosphereLighting, surfaceObject.albedo, viewPosition, screenCoord, dither);
    } else {
        // Is sky.
         image = CalculateSky(viewPosition);
    }
    
    /* DRAWBUFFERS:4 */
    gl_FragData[0] = vec4(EncodeColour(image), 1.0);
}
// EOF.
