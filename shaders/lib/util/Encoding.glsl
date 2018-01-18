/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_UTIL_ENCODING
  #define INTERNAL_INCLUDED_UTIL_ENCODING

  // 3xNf / COLOUR
  cv(vec3) values = exp2(vec3(5.0, 6.0, 5.0));
  cv(vec3) maxValues = values - 1.0;
  cRCP(vec3, maxValues);
  cv(vec3) positions = vec3(1.0, values.x, values.x * values.y);
  cv(vec3) uhalfMaxOverPositions = uhalfMax / positions;

  float encodeColour(in vec3 colour) {
    colour = saturate(colour);

    return dot(round(colour * maxValues), positions) * uhalfMaxRCP;
  }

  vec3 decodeColour(in float encoded) {
    return mod(encoded * uhalfMaxOverPositions, values) * maxValuesRCP;
  }

  // 2x8f
  float encode2x8(in vec2 v) {
    ivec2 i = ivec2(v * ubyteMax);
    
    return float(i.x | (i.y << 8)) * uhalfMaxRCP;
  }

  vec2 decode2x8(in float f) {
    int i = int(f * uhalfMax);

    return vec2(i % 256, i >> 8) * ubyteMaxRCP;
  }

  // NORMALS
  cv(float) bits = 11.0;

  cv(float) bitsExp2_a = exp2(bits);
  cv(float) bitsExp2_b = exp2(bits + 2.0);
  cRCP(float, bitsExp2_b);

  cv(vec2) bitsExp2_cRCP = vec2(1.0) / exp2(vec2(bits, bits * 2.0 + 2.0));

  float encodeNormal(in vec3 normal) {
    normal = clamp(normal, -1.0, 1.0);

    normal.xy = round(((vec2(atan(normal.x, normal.z), acos(normal.y)) * piRCP) + vec2(1.0, 0.0)) * bitsExp2_a);

    return normal.y * bitsExp2_b + normal.x;
  }

  vec3 decodeNormal(in float encoded) {
    vec4 normal = vec4(0.0);

    normal.y = bitsExp2_b * floor(encoded * bitsExp2_bRCP);
    normal.x = encoded - normal.y;

    normal.xy = ((normal.xy * bitsExp2_cRCP) - swizzle2) * pi;
    normal.xwzy = vec4(sin(normal.xy), cos(normal.xy));

    normal.xz *= normal.w;

    return normal.xyz;
  }

#endif /* INTERNAL_INCLUDED_UTIL_ENCODING */
