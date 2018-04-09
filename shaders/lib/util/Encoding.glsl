/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_UTIL_ENCODING
    #define INCLUDED_UTIL_ENCODING

    float Encode4x8F(vec4 decoded) {
        const vec3  cExponent1 = exp2(vec3(0.0, 8.0, 16.0));
        const float cExponent2 = exp2(-24.0);

        decoded = saturate(decoded);
        decoded = round(decoded * vec4(254.0, 255.0, 255.0, 252.0));
        
        float z_sign = (decoded.b < 128.0 ? 1.0 : -1.0);
        decoded.b = mod(decoded.b, 128.0);
        
        float encode = dot(decoded.rgb, cExponent1);
        
        float encodebuffer = encode * cExponent2 + 0.5;
        encodebuffer = ldexp(encodebuffer * z_sign, int(decoded.a - 125.0));
        
        return encodebuffer;
    }

    vec4 Decode4x8F(const float encoded) {
        const float cExponent1 = exp2(24.0);
        const vec3  cExponent2 = exp2(vec3(8.0, 16.0, 24.0));
        const vec3  cExponent3 = exp2(-vec3(0.0, 8.0, 16.0));

        float exponent = 0.0;
        float packedFloat = (frexp(encoded, exponent) - 0.5) * cExponent1;
        
        float z_sign2 = sign(packedFloat);
        packedFloat *= z_sign2;
        
        vec4 decoded = vec4(0.0);
        decoded.xyz  = mod(vec3(packedFloat), cExponent2);
        decoded.yz  -= decoded.xy;
        decoded.xyz *= cExponent3;
        decoded.w    = exponent + 125.0;
        
        if (z_sign2 < 0.0) decoded.z += 128.0;
        
        return decoded / vec4(254.0, 255.0, 255.0, 252.0);
    }

    float Encode2x16F(const vec2 decoded) {
        uvec2 v = uvec2(round(saturate(decoded) * 65535.0)) << uvec2(0, 16);

        return uintBitsToFloat(sum2(v));
    }

    vec2 Decode2x16F(const float encoded) {
        uvec2 decoded   = uvec2(floatBitsToUint(encoded));
              decoded.y = decoded.y >> 16;
              decoded.x = decoded.x & 65535;

        return vec2(decoded) / 65535.0;
    }

    float EncodeNormal(vec3 normal) {
        const float bits = 11.0;
        const float bitsExpA = exp2(bits);
        const float bitsExpB = exp2(bits + 2.0);

        normal    = clamp(normal, -1.0, 1.0);
        normal.xy = vec2(atan(normal.x, normal.z), acos(normal.y)) * piRCP;
        normal.x += 1.0;
        normal.xy = round(normal.xy * bitsExpA);

        return normal.y * bitsExpB + normal.x;
    }

    vec3 DecodeNormal(const float encoded) {
        const float bits = 11.0;
        const float bitsExpA = exp2(bits + 2.0);
        const vec2  bitsExpB = exp2(vec2(bits, bits * 2.0 + 2.0));

        vec4 normal = vec4(0.0);

        normal.y    = bitsExpA * floor(encoded / bitsExpA);
        normal.x    = encoded - normal.y;
        normal.xy  /= bitsExpB;
        normal.x   -= 1.0;
        normal.xy  *= pi;
        normal.xwzy = vec4(sin(normal.xy), cos(normal.xy));
        normal.xz  *= normal.w;

        return normal.xyz;
    }

    float EncodeAlbedo(vec3 decoded) {
        const vec3 values = exp2(vec3(5.0, 6.0, 5.0));
        const vec3 maxValues = values - 1.0;
        const vec3 positions = vec3(1.0, values.x, values.x * values.y);

        decoded = saturate(decoded);

        return dot(round(decoded * maxValues), positions) * uhalfMaxRCP;
    }

    vec3 DecodeAlbedo(const float encoded) {
        const vec3 values = exp2(vec3(5.0, 6.0, 5.0));
        const vec3 maxValues = values - 1.0;
        const vec3 maxValuesRCP = rcp(maxValues);
        const vec3 positions = vec3(1.0, values.x, values.x * values.y);
        const vec3 uhalfMaxOverPositions = uhalfMax / positions;

        return mod(encoded * uhalfMaxOverPositions, values) * maxValuesRCP;
    }

    #define EncodeColour(c) ( c * 1.0 )
    #define DecodeColour(c) ( c * 1.0 )

#endif
