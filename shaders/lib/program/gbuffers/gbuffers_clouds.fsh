/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

// Header.
#extension GL_EXT_gpu_shader4 : require

#include "/lib/syntax/Form.glsl"
#define STAGE FSH
#define PROGRAM GBUFFERS_CLOUDS
#include "/lib/Syntax.glsl"
#include "/lib/Utility.glsl"
#include "/lib/Settings.glsl"

#include "/lib/program/world_sky_elements.fsh"