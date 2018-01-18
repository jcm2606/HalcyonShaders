/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_SYNTAX
  #define INTERNAL_INCLUDED_SYNTAX

  #define DEFINE_genFType(func) func(float) func(vec2) func(vec3) func(vec4)
  #define DEFINE_genVType(func) func(vec2) func(vec3) func(vec4)
  #define DEFINE_genDType(func) func(double) func(dvec2) func(dvec3) func(dvec4)
  #define DEFINE_genIType(func) func(int) func(ivec2) func(ivec3) func(ivec4)
  #define DEFINE_genUType(func) func(uint) func(uvec2) func(uvec3) func(uvec4)
  #define DEFINE_genBType(func) func(bool) func(bvec2) func(bvec3) func(bvec4)

  #include "/lib/syntax/MacroConstant.glsl"

  #include "/lib/syntax/BlockID.glsl"
  #include "/lib/syntax/ObjectID.glsl"

  #include "/lib/Settings.glsl"

  #include "/lib/syntax/Values.glsl"
  #include "/lib/syntax/Compat.glsl"
  #include "/lib/syntax/Macro.glsl"
  #include "/lib/syntax/Math.glsl"
  #include "/lib/syntax/Vector.glsl"
  #include "/lib/syntax/Functions.glsl"
  #include "/lib/syntax/PointMapping.glsl"
  #include "/lib/syntax/Tiles.glsl"

  #include "/lib/util/Encoding.glsl"

#endif /* INTERNAL_INCLUDED_SYNTAX */
