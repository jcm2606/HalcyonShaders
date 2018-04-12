/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_UTILITY
    #define INCLUDED_UTILITY

    // Generic Typing.
    #define DEFINE_genFType(func) func(float) func(vec2) func(vec3) func(vec4)
    #define DEFINE_genVType(func) func(vec2) func(vec3) func(vec4)
    #define DEFINE_genDType(func) func(double) func(dvec2) func(dvec3) func(dvec4)
    #define DEFINE_genIType(func) func(int) func(ivec2) func(ivec3) func(ivec4)
    #define DEFINE_genUType(func) func(uint) func(uvec2) func(uvec3) func(uvec4)
    #define DEFINE_genBType(func) func(bool) func(bvec2) func(bvec3) func(bvec4)

    // Constant Values.
    const float pi    = 3.14159265358979;
    const float piRCP = rcp(pi);

    const float tau    = 2.0 * pi;
    const float tauRCP = rcp(tau);

    const float phi    = 1.61803398875;
    const float phiRCP = rcp(phi);

    const float ubyteMax    = exp2(8);
    const float ubyteMaxRCP = rcp(ubyteMax);

    const float uhalfMax    = exp2(16);
    const float uhalfMaxRCP = rcp(uhalfMax);

    const float uintMax    = exp2(32);
    const float uintMaxRCP = rcp(uintMax);

    const float ulongMax    = exp2(64);
    const float ulongMaxRCP = rcp(ulongMax);

    // Constant Ops.
    // AMD supposedly doesn't have a constant radians function, so I've implemented it manually using a macro.
    // radians should have a hardware optimised implementation, so this is not for use in dynamic expressions, ONLY constant expressions.
    #define cRadians(x) ( (pi * x) / 180.0 )
    
    // Generic Ops.
    #define pow2_DEF(type) type pow2(const type x) { return x * x; }
    DEFINE_genFType(pow2_DEF)
    DEFINE_genIType(pow2_DEF)

    #define pow3_DEF(type) type pow3(const type x) { return pow2(x) * x; }
    DEFINE_genFType(pow3_DEF)
    DEFINE_genIType(pow3_DEF)

    #define pow4_DEF(type) type pow4(const type x) { return pow2(pow2(x)); }
    DEFINE_genFType(pow4_DEF)
    DEFINE_genIType(pow4_DEF)

    #define pow5_DEF(type) type pow5(const type x) { return pow2(pow2(x)) * x; }
    DEFINE_genFType(pow5_DEF)
    DEFINE_genIType(pow5_DEF)

    #define pow6_DEF(type) type pow6(const type x) { return pow2(pow2(x) * x); }
    DEFINE_genFType(pow6_DEF)
    DEFINE_genIType(pow6_DEF)

    #define pow7_DEF(type) type pow7(const type x) { return pow2(pow2(x) * x) * x; }
    DEFINE_genFType(pow7_DEF)
    DEFINE_genIType(pow7_DEF)

    #define pow8_DEF(type) type pow8(const type x) { return pow2(pow2(pow2(x))); }
    DEFINE_genFType(pow8_DEF)
    DEFINE_genIType(pow8_DEF)

    // Float Ops.
    bool CompareFloat(const float a, const float b, const float width) { return abs(a - b) < width; }
    bool CompareFloat(const float a, const float b) { return abs(a - b) < ubyteMaxRCP; }

    #define max3f(a, b, c) ( max(a, max(b, c)) )
    #define max4f(a, b, c, d) ( max(a, max(b, max(c, d))) )

    #define min3f(a, b, c) ( min(a, min(b, c)) )
    #define min4f(a, b, c, d) ( min(a, min(b, min(c, d))) )

    // Vector Ops.
    #define fLengthSqr_DEF(type) float fLengthSqr(const type x) { return dot(x, x); }
    DEFINE_genFType(fLengthSqr_DEF)

    #define fLength_DEF(type) float fLength(const type x) { return sqrt(dot(x, x)); }
    DEFINE_genFType(fLength_DEF)

    #define fInverseLength_DEF(type) float fInverseLength(const type x) { return inversesqrt(dot(x, x)); }
    DEFINE_genFType(fInverseLength_DEF)

    #define sum2(v) ( (v).x + (v).y )
    #define sum3(v) ( (v).x + (v).y + (v).z )
    #define sum4(v) ( (v).x + (v).y + (v).z + (v).w )

    #define max0_DEF(type) type max0(const type x) { return max(type(0.0), x); }
    DEFINE_genFType(max0_DEF)

    #define max1_DEF(type) type max1(const type x) { return max(type(1.0), x); }
    DEFINE_genFType(max1_DEF)

    #define min0_DEF(type) type min0(const type x) { return min(type(0.0), x); }
    DEFINE_genFType(min0_DEF)

    #define min1_DEF(type) type min1(const type x) { return min(type(1.0), x); }
    DEFINE_genFType(min1_DEF)

    #define max2v(v) ( max(v.x, v.y) )
    #define max3v(v) ( max(v.x, max(v.y, v.z)) )
    #define max4v(v) ( max(v.x, max(v.y, max(v.z, v.w))) )

    #define min2v(v) ( min(v.x, v.y) )
    #define min3v(v) ( min(v.x, min(v.y, v.z)) )
    #define min4v(v) ( min(v.x, min(v.y, min(v.z, v.w))) )

    vec2 rotate2(vec2 v, float r) {
        return v * mat2(cos(r), -sin(r), sin(r), cos(r));
    }
    #define cRotateMat2(r, var) \
        const mat2 var = mat2( \
            cos(r), -sin(r), \
            sin(r),  cos(r) \
        ); \

    // Matrix Ops.
    #define transMAD(mat, v) ( mat3(mat) * (v) + (mat)[3].xyz )

    #define diagonal2(mat) vec2((mat)[0].x, (mat)[1].y)
    #define diagonal3(mat) vec3(diagonal2(mat), (mat)[2].z)
    #define diagonal4(mat) vec4(diagonal3(mat), (mat)[2].w)

    #define projMAD3(mat, v) ( diagonal3(mat) * (v) + (mat)[3].xyz  )
    #define projMAD4(mat, v) ( diagonal4(mat) * (v) + (mat)[3].xyzw )

    // Colour Ops.
    const float gammaCurveScreen    = 2.2;
    const float gammaCurveScreenRCP = rcp(gammaCurveScreen);

    #define toGamma_DEF(type) type ToGamma(const type x) { return pow(x, type(gammaCurveScreenRCP)); }
    DEFINE_genFType(toGamma_DEF)

    #define toLinear_DEF(type) type ToLinear(const type x) { return pow(x, type(gammaCurveScreen)); }
    DEFINE_genFType(toLinear_DEF)

    const vec3 lumaCoefficient = vec3(0.2125, 0.7154, 0.0721);

    #define luma(x) ( dot(x, lumaCoefficient) )

    vec3 SaturationMod(const vec3 x, const float s) { return mix(vec3(dot(x, lumaCoefficient)), x, s); }
    #define saturationMod(x, s) ( mix(vec3(dot(x, lumaCoefficient)), x, s) )

    vec3 Blackbody(const float K) {
        const vec4 vx = vec4(-0.2661239e9, -0.2343580e6, 0.8776956e3, 0.179910);
        const vec4 vy = vec4(-1.1063814, -1.34811020, 2.18555832, -0.20219683);

        const mat3 xyzToSrgb = mat3(
             3.2404542, -1.5371385, -0.4985314,
            -0.9692660,  1.8760108,  0.0415560,
             0.0556434, -0.2040259,  1.0572252
        );

        float kRCP  = rcp(K);
        float kRCP2 = kRCP * kRCP;

        float x  = dot(vx, vec4(kRCP * kRCP2, kRCP2, kRCP, 1.0));
        float x2 = x * x;
        float y  = dot(vy, vec4(x * x2, x2, x, 1.0));
        float z  = 1.0 - x - y;

        return max0(vec3(x / y, 1.0, z / y) * xyzToSrgb);
    }

    #define CFUNC_Blackbody(t, var) \
        const vec4 vx = vec4(-0.2661239e9, -0.2343580e6, 0.8776956e3, 0.179910); \
        const vec4 vy = vec4(-1.1063814, -1.34811020, 2.18555832, -0.20219683); \
         \
        const mat3 xyzToSrgb = mat3( \
             3.2404542, -1.5371385, -0.4985314, \
            -0.9692660,  1.8760108,  0.0415560, \
             0.0556434, -0.2040259,  1.0572252 \
        ); \
         \
        const float K     = t; \
        const float kRCP  = rcp(K); \
        const float kRCP2 = kRCP * kRCP; \
         \
        const float x  = dot(vx, vec4(kRCP * kRCP2, kRCP2, kRCP, 1.0)); \
        const float x2 = x * x; \
        const float y  = dot(vy, vec4(x * x2, x2, x, 1.0)); \
        const float z  = 1.0 - x - y; \
         \
        const vec3 var = max(vec3(0.0), vec3(x / y, 1.0, z / y) * xyzToSrgb); \

    // Scene Ops.
    #define getLandMask(x) ( x < 1.0 - near / far / far )

    // Point Mapping.
    vec2 MapLattice(const float i, const float n) { return vec2(mod(i * pi, sqrt(n)) * inversesqrt(n), i / n); }

    vec2 MapSpiral(const float i, const float n) {
        float theta = i * tau / (phi * phi);

        return vec2(sin(theta), cos(theta)) * sqrt(i / n);
    }

    vec2 MapCircle(const float i) { return vec2(cos(i), sin(i)); }

    vec2 Map2D(const int i, const int t) {
        float tSqrt = sqrt(t);

        return vec2(floor(float(i) / tSqrt), mod(i, tSqrt));
    }

    vec2 Map2DCentered(const int i, const int t) {
        float tSqrt = sqrt(t);
        
        return vec2(floor(float(i) / tSqrt), mod(i, tSqrt)) - floor(tSqrt * 0.5);
    }

    // Bayer Dither Matrices.
    float Bayer2(vec2 a) {
        a = floor(a);
        return fract(dot(a, vec2(0.5, a.y * 0.75)));
    }
    #define Bayer4(a)   ( Bayer2( 0.5 * (a)) * 0.25 + Bayer2(a) )
    #define Bayer8(a)   ( Bayer4( 0.5 * (a)) * 0.25 + Bayer2(a) )
    #define Bayer16(a)  ( Bayer8( 0.5 * (a)) * 0.25 + Bayer2(a) )
    #define Bayer32(a)  ( Bayer16(0.5 * (a)) * 0.25 + Bayer2(a) )
    #define Bayer64(a)  ( Bayer32(0.5 * (a)) * 0.25 + Bayer2(a) )
    #define Bayer128(a) ( Bayer64(0.5 * (a)) * 0.25 + Bayer2(a) )

    // Tile Ops.
    bool CanWriteToTile(const vec2 screenCoord, ivec2 tile, const int width) {
        float widthRCP = rcp(width);

        tile = min(tile, width - 1);

        return all(greaterThan(screenCoord, vec2(widthRCP * tile))) && all(lessThan(screenCoord, vec2(widthRCP * tile + widthRCP)));
    }

    vec4 ReadFromTile(const sampler2D tex, const ivec2 tile, const int width) { return texture2D(tex, (tile + vec2(0.5)) * rcp(width)); }

    // Volume Ops.
    vec3 TransmittedScatteringIntegral(const float opticalDepth, const vec3 coeff) {
        const vec3 a = -coeff / log(2.0);
        const vec3 b = -1.0 / coeff;
        const vec3 c =  1.0 / coeff;

        return exp2(a * opticalDepth) * b + c;
    }

    float TransmittedScatteringIntegral(const float opticalDepth, const float coeff) {
        const float a = -coeff / log(2.0);
        const float b = -1.0 / coeff;
        const float c =  1.0 / coeff;

        return exp2(a * opticalDepth) * b + c;
    }

    float PhaseG(float theta, const float G) {
        const float G2 = G * G;
        const float p1 = (0.75 * (1.0 - G2)) / (tau * (2.0 + G2));

        const float G2_p2 = 1.0 + G2;
        const float G_p2  = 2.0 * G;

        float p2 = (theta * theta + 1.0) * pow(G2_p2 - G_p2 * theta, -1.5);

        return p1 * p2;
    }
    #define PhaseG0() ( 0.25 )

    // Jitter Ops.
    #define DitherJitter(dither, size) fract((dither * size + frameCounter * 7.0) / size)

    // Utility Includes.
    #include "/lib/util/Encoding.glsl"
    #include "/lib/util/EntityList.glsl"
    #include "/lib/util/MaterialList.glsl"
    #include "/lib/util/TileList.glsl"

#endif
