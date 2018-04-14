/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

// Header.
#extension GL_EXT_gpu_shader4 : require

#include "/lib/syntax/Form.glsl"
#define STAGE VSH
#define PROGRAM SHADOW
#include "/lib/Syntax.glsl"
#include "/lib/Utility.glsl"
#include "/lib/Settings.glsl"

// Constants.
// Varyings.
varying vec3 tint;

varying vec3 viewPosition;
varying vec3 worldPosition;

varying vec3 vertexNormal;

varying vec2 uvCoord;

flat(mat3) tbn;

flat(vec2) entity;

flat(float) materialID;

// Screen Samples.
// Uniforms.
attribute vec3 mc_Entity;
attribute vec2 mc_midTexCoord;
attribute vec4 at_tangent;

uniform mat4 gbufferProjection, gbufferProjectionInverse;
uniform mat4 gbufferModelView, gbufferModelViewInverse;

uniform mat4 shadowProjection;
uniform mat4 shadowModelView, shadowModelViewInverse;

uniform vec3 cameraPosition;

uniform float viewWidth;
uniform float viewHeight;

uniform int frameCounter;

// Structs.
// Globals.
// Includes.
#include "/lib/gbuffer/MaterialID.vsh"

#include "/lib/util/ShadowTransform.glsl"

#include "/lib/common/Jitter.glsl"

// Functions.
// Main.
void main() {
    uvCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    tint = gl_Color.rgb;

    entity = mc_Entity.xz;
    materialID = CalculateMaterialID(entity);
    
    viewPosition  = transMAD(gl_ModelViewMatrix, gl_Vertex.xyz);
    worldPosition = transMAD(shadowModelViewInverse, viewPosition) + cameraPosition;
    
    gl_Position = transMAD(shadowModelView, worldPosition - cameraPosition).xyzz * diagonal4(gl_ProjectionMatrix) + gl_ProjectionMatrix[3];
    gl_Position.xy = DistortShadowPosition(gl_Position.xy);
    gl_Position.z *= shadowDepthMult;

    vertexNormal = normalize(gl_NormalMatrix * gl_Normal) * mat3(shadowModelView);

    tbn    = mat3(0.0);
    tbn[0] = normalize(gl_NormalMatrix * at_tangent.xyz / at_tangent.w) * mat3(shadowModelView);
    tbn[1] = cross(tbn[0], vertexNormal);
    tbn[2] = vertexNormal;
}
// EOF.
