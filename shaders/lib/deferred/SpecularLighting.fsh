/*
    Jcm2606.
    Halcyon.
    Please read "LICENSE.md" before editing this file.
*/

#if !defined INCLUDED_DEFERRED_SPECULARLIGHTING
    #define INCLUDED_DEFERRED_SPECULARLIGHTING

    #include "/lib/deferred/Raytracer.fsh"

    const int   reflectionSamples    = SPECULAR_SSR_ROUGH_SAMPLES;
    const float reflectionSamplesRCP = rcp(reflectionSamples);

    // Helper Functions.
    vec3 Fresnel(const vec3 f0, const float f90, const float LoH) {
        return (f90 - f0) * exp2((-5.55473 * LoH - 6.98316) * LoH) + f0;
    }

    float ExactCorrelatedG2(float a, const float NoV, const float NoL) {
        #if 0
            // Full.
            a *= a;

            float y = (1.0 - a);

            return saturate((2.0 * NoL * NoV) / (NoV * sqrt(y * pow2(NoL) + a) + (NoL * sqrt(a + y * pow2(NoV)))));
        #else
            // Approximate.
            float x = 2.0 * NoL * NoV + 1.0e-36;

            return saturate(x / mix(x, NoL + NoV + 1.0e-36, a));
        #endif
    }

    float D_GGX(const float a2, const float NoH) {
        return a2 / pow2((NoH * a2 - NoH) * NoH + 1.0);
    }

    vec3 BRDF(const vec3 V, const vec3 L, const vec3 N, const float r, const vec3 f0) {
        // Cleaned and optimised version of Joey's GGX.
        // Has issues with going inf.

        float a  = r * r;
        float a2 = a * a;

        vec3 H = normalize(L + V);

        float NoL = saturate(dot(N, L));
        float NoV = abs(dot(N, V) + 1.0E-6);

        #define NoH saturate(dot(N, H))
        #define LoH saturate(dot(L, H))

        return max(vec3(0.0), (Fresnel(f0, 1.0, LoH) * D_GGX(a2, NoH)) * ExactCorrelatedG2(a, NoV, NoL) / (pi * 4.0 * NoL * NoV)) * NoL;

        #undef NoH
        #undef LoH
    }

    float GGX(const vec3 V, const vec3 L, const vec3 N, const float r, const float f0) {
        // Cleaned and optimised version of Jodie's GGX.

        float a2 = pow4(r);

        vec3 H = normalize(L + V);

        float HoL = saturate(dot(H, L));

        #define NoL saturate(dot(N, L))
        #define NoH saturate(dot(N, H))

        #define F ( (1.0 - f0) * pow5(1.0 - HoL) + f0 )

        #define denom ( pow2(NoH) * (a2 - 1.0) + 1.0 )

        return NoL * a2 / (pi * pow2(denom)) * F / (pow2(HoL) * (1.0 - a2) + a2);

        #undef NoL
        #undef NoH

        #undef F

        #undef denom
    }

    float ComputeLod(float samplesRCP, float alpha2, float NoH) {
        return 0.125 * (log2(float(viewWidth * viewHeight) * samplesRCP) - log2(D_GGX(alpha2, NoH)));
    }

    vec3 MakeSample(const float p, const float alpha2) {
        const float phi = sqrt(5.0) * 0.5 + 0.5;
        const float goldenAngle = tau / phi / phi;
        const float _y = float(reflectionSamples) * 64.0 * 64.0 * goldenAngle;

        float x = (alpha2 * p) / (1.0 - p);
        float y = p * _y;

        float c = inversesqrt(x + 1.0);
        float s = sqrt(x) * c;

        return vec3(cos(y) * s, sin(y) * s, c);
    }

    #define Specular_Raytracer RaytraceClip1

    vec3 RoughSSR(const vec3 viewPosition, const vec3 clipPosition, const vec3 N, const vec3 V, const vec2 dither, const float roughness, const vec3 f0, const float skyLight) {
        const int   samples    = reflectionSamples;
        const float samplesRCP = rcp(samples);

        float a  = pow2(roughness);
        float a2 = pow4(roughness);

        float NoV = saturate(dot(N, V));

        vec3 tangent = normalize(cross(gbufferModelView[1].xyz, N));
        mat3 tbn = mat3(tangent, cross(N, tangent), N);

        vec3 colour = vec3(0.0);

        for(int i = 0; i < samples; ++i) {
            vec3 H = normalize(tbn * MakeSample((dither.x + float(i)) * samplesRCP, a2));
            vec3 L = -reflect(V, H);

            float VoH = saturate(dot(V, H));
            #define NoL saturate(dot(N, L))

            colour += (SPECULAR_RAYTRACER(viewPosition, L, clipPosition, skyLight) * Fresnel(f0, 1.0, VoH) * ExactCorrelatedG2(a, NoV, NoL)) * samplesRCP;

            #undef NoL
        }

        return colour;
    }

    vec3 SmoothSSR(const vec3 viewPosition, const vec3 clipPosition, const vec3 N, const vec3 V, const vec2 dither, const float roughness, const vec3 f0, const float skyLight) {
        return vec3(0.0);
    }

    // Specular Function.
    vec3 CalculateSpecularLighting(SurfaceObject surfaceObject, mat2x3 atmosphereLighting, vec3 diffuse, vec3 shadow, vec3 viewPosition, vec2 screenCoord, vec2 dither, float depth) {
        vec3 V = normalize(-viewPosition);
        
        bool metalness = surfaceObject.f0 > 0.5;

        vec3 specular = SPECULAR_SSR(viewPosition, vec3(screenCoord, depth), surfaceObject.normal, V, dither, surfaceObject.roughness, vec3(surfaceObject.f0), surfaceObject.skyLight);

        if(metalness)
            specular *= surfaceObject.albedo;

        return diffuse * float(!metalness) + specular;
    }

#endif
