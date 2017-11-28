/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_OPAQUE_AMBIENTLIGHT
  #define INTERNAL_INCLUDED_OPAQUE_AMBIENTLIGHT

  #define hammersley(i, N) vec2( float(i) / float(N), float( bitfieldReverse(i) ) * 2.3283064365386963e-10 )
  #define circlemap(p) (vec2(cos((p).y*tau), sin((p).y*tau)) * p.x)

  // AMBIENT OCCLUSION
  /*
  float getAmbientOcclusion(io GbufferObject gbuffer, io PositionObject position, in vec2 p) {
    c(int) steps = 8;
    cRCP(float, steps);
    c(float) r = 2.0;

    int x = int(p.x * viewWidth) % 4;
    int y = int(p.y * viewHeight) % 4;
    int index = x * 4 + y;

    vec3 p3 = clipToView(p, position.depthBack);
    vec3 normal = normalize(gbuffer.normal);
    vec2 clipRadius = 4 * vec2(viewHeight / viewWidth, 1.0) / length(p3);

    vec3 v = -normalize(p3);
    
    float nvisibility = 0.0;
    float vvisibility = 0.0;

    for(int i = 0; i < steps; i++) {
      vec2 circlePoint = circlemap(
        hammersley(i * 15 + index + 1, 16 * steps)
      ) * clipRadius;

      vec3 o = 
    }
  }
  */
  // AMBIENT DIFFUSE
  #include "/lib/common/Sky.glsl"

  float BurleyScatter(in vec3 V, in vec3 L, in vec3 N, in float r) {
    vec3 H = normalize(V + L);

    float NdotL = clamp01(dot(N, L));
    float LdotH = clamp01(dot(L, H));
    float NdotV = clamp01(dot(N, V));

    float f90 = 2.0 * r * (pow2(LdotH) + 0.25) - 1.0;

    float lightScatter = f90 * pow5(1.0 - NdotL) + 1.0;
    float viewScatter = f90 * pow5(1.0 - NdotV) + 1.0;

    return lightScatter * viewScatter;
  }

  float FullBurley(in vec3 V, in vec3 L, in vec3 N, in float r) {
    r *= r;

    vec3 H = normalize(V + L);
    
    float NdotL = clamp01(dot(N, L));
    float LdotH = clamp01(dot(L, H));
    float NdotV = clamp01(dot(N, V));

    float f90 = 2.0 * r * (pow2(LdotH) + 0.25) - 1.0;
    float energyFactor = -r * 0.337748344 + 1.0;

    float lightScatter = f90 * pow5(1.0 - NdotL) + 1.0;
    float viewScatter = f90 * pow5(1.0 - NdotV) + 1.0;

    return NdotL * energyFactor * lightScatter * viewScatter;
  }

  vec3 _clipToView(in vec2 screenCoord) { return clipToView(screenCoord, texture2D(depthtex2, screenCoord).x); }

  vec3 getAmbientDiffuse(io GbufferObject gbuffer, io PositionObject position, in vec2 p) {
    c(int) steps = 12;
    cRCP(float, steps);
    c(float) r = 8.0;
    c(float) aoRadius = 16.0;
    c(int) skyMode = 2;

    float roughness = gbuffer.roughness;

    roughness *= roughness;

    int x = int(p.x * viewWidth) % 4;
    int y = int(p.y * viewHeight) % 4;
    int index = x * 4 + y;

    vec3 p3 = position.viewPositionBack;

    vec3 normal = normalize(gbuffer.normal);
    vec2 clipRadius = 4 * vec2(viewHeight / viewWidth, 1.0) / length(p3);
    vec3 v = -normalize(p3);

    vec3 totalAmbient = vec3(0.0);

    float normalVisibility = 0.0;
    float viewVisibility = 0.0;

    float NdotU = dot(upVector, normal);

    vec3 skyAtNormal = drawSky(normal, skyMode);
    float burleyAtNormal = BurleyScatter(v, normal, normal, roughness);
    float earthOcclusionAtNormal = NdotU * 0.5 + 0.5;

    for(int i = 0; i < steps; i++) {
      vec2 circlePoint = circlemap(
        hammersley(i * 15 + index + 1, 16 * steps)
      ) * clipRadius;

      vec3 horizon1 = _clipToView(circlePoint + p) - p3;
      vec3 horizon2 = _clipToView(circlePoint * 0.125 + p) - p3;

      float len1 = length(horizon1);
      float len2 = length(horizon2);

      horizon1 /= len1;
      horizon2 /= len2;

      // AO
      normalVisibility += clamp(1.0 - max(
        dot(horizon1, normal) - clamp01((len1 - aoRadius) / aoRadius),
        dot(horizon2, normal) - clamp01((len2 - aoRadius) / aoRadius)
      ), 0.0, 1.0);

      viewVisibility += clamp(1.0 - max(
        dot(horizon1, v) - clamp01((len1 - aoRadius) / aoRadius),
        dot(horizon2, v) - clamp01((len2 - aoRadius) / aoRadius)
      ), 0.0, 1.0);

      // AD
      #if 0
        bool trueHorizon = dot(horizon2, normal) > dot(horizon1, normal);

        vec3 horizon = trueHorizon ? horizon2 : horizon1;
        float len = trueHorizon ? len2 : len1;

        float tooFar = step(r, len);

        vec3 lightVector = normalize(mix(normal, horizon, 0.7));

        float NdotH = clamp01(dot(horizon, normal)/* - tooFar*/);
        float NdotL = clamp01(dot(lightVector, normal));

        vec3 sky = (skyAtNormal * 0.5 + drawSky(lightVector, skyMode) * NdotL) / (0.5 + NdotL);

        float earthOcclusion = (earthOcclusionAtNormal * 0.7 + step(0.0, dot(upVector, lightVector)) * tooFar * NdotL) / (0.7 + NdotL);

        earthOcclusion = max(earthOcclusion, earthOcclusionAtNormal);

        float burley = (burleyAtNormal * 0.5 + BurleyScatter(v, lightVector, normal, roughness) * NdotL) / (0.5 + NdotL);

        totalAmbient += (1.0 - pow2(NdotH)) * burley * earthOcclusion * sky;
      #endif
    }

    float ao = clamp01(pow2(min(viewVisibility * 2.0, normalVisibility) * stepsRCP));

    #if 1
    return vec3(ao);
    #else
    totalAmbient *= stepsRCP;

    float energyFactor = -roughness * 0.337748344 + 1.0;

    return totalAmbient * energyFactor * ao;
    #endif
  }
  
#endif /* INTERNAL_INCLUDED_OPAQUE_AMBIENTLIGHT */
