/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

// Header.
#extension GL_EXT_gpu_shader4 : require

#include "/lib/syntax/Form.glsl"
#define STAGE FSH
#define PROGRAM COMPOSITE2
#include "/lib/Syntax.glsl"
#include "/lib/Utility.glsl"
#include "/lib/Settings.glsl"

// Used Screen Buffers.
#define IN_TEX3
#define IN_TEX4

// Constants.
const bool colortex3MipmapEnabled = true;
const bool colortex4MipmapEnabled = true;

// Varyings.
varying vec2 screenCoord;

flat(vec4) timeVector;

// Screen Samples.
// Uniforms.
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex5;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D depthtex2;

uniform mat4 gbufferProjection, gbufferProjectionInverse;
uniform mat4 gbufferModelView, gbufferModelViewInverse;

uniform float centerDepthSmooth;
uniform float viewWidth;
uniform float viewHeight;
uniform float aspectRatio;
uniform float near;
uniform float far;

// Structs.
#include "/lib/struct/ScreenObject.fsh"

// Globals.
// Includes.
#include "/lib/util/SpaceTransform.glsl"

#include "/lib/deferred/Camera.fsh"

// Functions.
// Main.
void main() {
    ScreenObject screenObject = CreateScreenObject(screenCoord);

    vec4 temporalBuffer = screenObject.tex3;

    vec3 image = DecodeColour(screenObject.tex4.rgb);
         image = CalculateDOF(screenCoord);

    temporalBuffer.rgb = EncodeColour(image);

         image = CalculateExposedImage(image, ReadFromTile(colortex3, TILE_COORD_TEMPORAL_LUMA, TILE_WIDTH_TEMPORAL).a);

    #ifdef LENS_PREVIEW
         image = texture2D(colortex5, screenCoord * vec2(1.0, 0.55) + vec2(0.0, 0.2)).rgb;
    #endif
    
    /* DRAWBUFFERS:34 */
    gl_FragData[0] = temporalBuffer;
    gl_FragData[1] = vec4(EncodeColour(image), 1.0);
}
// EOF.
