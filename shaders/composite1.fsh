/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#version 120

#include "/lib/common/syntax/Shaders.glsl"
#define SHADER FSH
#define PROGRAM COMPOSITE1
#include "/lib/Header.glsl"

// CONST
const bool colortex0MipmapEnabled = true;
const bool colortex4MipmapEnabled = true;
const bool colortex5MipmapEnabled = true;

// USED BUFFERS
#define IN_TEX0
#define IN_TEX1
#define IN_TEX2
#define IN_TEX3
#define IN_TEX6

// VARYING
varying vec2 screenCoord;

flat(vec3) sunVector;
flat(vec3) moonVector;
flat(vec3) lightVector;
flat(vec3) wLightVector;

// UNIFORM
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex5;
uniform sampler2D colortex6;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D depthtex2;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

uniform float frameTime;
uniform float frameTimeCounter;

uniform int isEyeInWater;

// STRUCT
#include "/lib/common/struct/StructBuffer.glsl"
#include "/lib/common/struct/StructGbuffer.glsl"
#include "/lib/common/struct/StructPosition.glsl"

// ARBITRARY
// INCLUDED FILES
#include "/lib/deferred/TemporalBlending.glsl"

#include "/lib/common/util/SpaceTransform.glsl"

#include "/lib/deferred/Refraction.glsl"

#include "/lib/common/Reflections.glsl"

#include "/lib/deferred/Volumetrics.glsl"

// FUNCTIONS
// MAIN
void main() {
  // CREATE STRUCTS
  NewBufferObject(buffers);
  NewGbufferObject(gbuffer);
  NewPositionObject(position);

  // POPULATE STRUCTS
  populateBufferObject(buffers, screenCoord);
  populateGbufferObject(gbuffer, buffers);
  populateDepths(position, screenCoord);
  populateViewPositions(position, screenCoord);

  // DRAW REFRACTION
  buffers.tex0.rgb = drawRefraction(gbuffer, position, buffers.tex0.rgb, screenCoord);

  if(position.depthBack > position.depthFront) {
    buffers.tex0.rgb *= gbuffer.albedo;
    buffers.tex0.rgb  = mix(buffers.tex0.rgb, buffers.tex6.rgb, buffers.tex6.a);
  }

  // DRAW VOLUMETRICS
  buffers.tex0.rgb = drawCombinedVolumetrics(gbuffer, position, buffers.tex0.rgb, screenCoord);

  // DRAW TRANSPARENT REFLECTIONS
  if(position.depthBack > position.depthFront && isEyeInWater == 0) buffers.tex0.rgb = getReflections(screenCoord, position.depthFront, position.viewFront, gbuffer.albedo, gbuffer.normal, gbuffer.roughness, gbuffer.f0, gbuffer.skyLight, getAtmosphereLighting(), vec4(1.0)).rgb * buffers.tex0.a + buffers.tex0.rgb;

  // PERFORM TEMPORAL BLENDING
  getTemporalBlending(buffers.tex3.a, screenCoord);

  // POPULATE OUTGOING BUFFERS
/* DRAWBUFFERS:03 */
  gl_FragData[0] = buffers.tex0;
  gl_FragData[1] = buffers.tex3;
}
