/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

// Constants.
// Varyings.
varying vec3 tint;

varying vec3 viewPosition;
varying vec3 tangentViewVector;
varying vec3 worldPosition;

varying vec3 vertexNormal;

varying vec2 uvCoord;
varying vec2 lmCoord;

varying float vanillaAO;

flat(mat3) tbn;
flat(mat2) tileInfo;

flat(vec2) entity;

flat(float) materialID;

// Screen Samples.
// Uniforms.
attribute vec3 mc_Entity;
attribute vec2 mc_midTexCoord;
attribute vec4 at_tangent;

uniform sampler2D texture;

uniform mat4 gbufferProjection, gbufferProjectionInverse;
uniform mat4 gbufferModelView, gbufferModelViewInverse;

uniform float viewWidth;
uniform float viewHeight;

uniform int frameCounter;

// Structs.
// Globals.
// Includes.
#include "/lib/util/SpaceTransform.glsl"

#include "/lib/gbuffer/MaterialID.vsh"

#include "/lib/common/Jitter.glsl"

// Functions.
// Main.
void main() {
    uvCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmCoord = pow2(gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

    tint = gl_Color.rgb;

    vanillaAO = gl_Color.a;

    entity = mc_Entity.xz;
    materialID = CalculateMaterialID(entity);
    
    viewPosition  = transMAD(gl_ModelViewMatrix, gl_Vertex.xyz);
    worldPosition = transMAD(gbufferModelViewInverse, viewPosition);

    viewPosition = transMAD(gbufferModelView, worldPosition);

    #if PROGRAM == GBUFFERS_HAND
        gl_Position = viewPosition.xyzz * diagonal4(gl_ProjectionMatrix) + gl_ProjectionMatrix[3];
    #else
        gl_Position = viewPosition.xyzz * diagonal4(gbufferProjection) + gbufferProjection[3];
        gl_Position.xy = CalculateJitter() * gl_Position.w + gl_Position.xy;
    #endif

    vertexNormal = normalize(gl_NormalMatrix * gl_Normal);
    vec3 tangent = at_tangent.xyz / at_tangent.w;

    tbn    = mat3(0.0);
    tbn[0] = normalize(gl_NormalMatrix * tangent);
    tbn[1] = cross(tbn[0], vertexNormal);
    tbn[2] = vertexNormal;

    vec2 atlasSize = vec2(textureSize2D(texture, 0));
    mat3 tbnMod = mat3(tangent * atlasSize.y / atlasSize.x, cross(tangent, gl_Normal), gl_Normal);

    tangentViewVector = (viewPosition * gl_NormalMatrix) * tbnMod;

    #if PROGRAM == GBUFFERS_TERRAIN || PROGRAM == GBUFFERS_HAND
        vec2 coordOffset = abs(gl_MultiTexCoord0.xy - mc_midTexCoord.xy);
        tileInfo = mat2(coordOffset * 2.0, mc_midTexCoord - coordOffset);
    #endif
}
// EOF.
