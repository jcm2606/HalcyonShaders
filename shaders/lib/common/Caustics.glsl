/*
  JCM2606.
  HALCYON 2.
  PLEASE READ "LICENSE.MD" BEFORE EDITING THIS FILE.
*/

#ifndef INTERNAL_INCLUDED_COMMON_CAUSTICS
  #define INTERNAL_INCLUDED_COMMON_CAUSTICS

  #if PROGRAM == DEFERRED1 || PROGRAM == COMPOSITE0
    vec3 getCausticsNormal(in vec3 position) {
      position.xz -= cameraPosition.xz;
      position.xz *= 0.03125;
      position.xz /= _length(position.xz) + 1.0;

      return texture2D(colortex5, position.xz * 0.5 + 0.5).xzy * 2.0 - 1.0;
    }

    float waterCaustics(in vec3 position, in vec3 shadowPosition, in float waterDepth, in vec3 lightVector, in vec3 flatRefractVector, in vec3 invFR, in float depthScale) {
      cv(int) samples = 9;
      cv(float) kernel = (sqrt(samples) - 1.0) * 0.5;
      cv(float) radius = 0.3;
      cv(float) scale = radius / kernel;
      
      cv(float) defocus = 1.0;
      cv(float) distancePower = 1.0;
      cv(float) distanceThreshold = (sqrt(samples) - 1.0) / (radius * defocus);
      cv(float) resultPower = 1.0;

      waterDepth *= depthScale;

      position += cameraPosition;

      //waterDepth = min(abs(position.y - 63.0), 2.0);

      vec3 surfacePosition = position - flatRefractVector * (waterDepth * invFR.y);

      float result = 0.0;

      for(float x = -kernel; x <= kernel; x++) {
        for(float y = -kernel; y <= kernel; y++) {
          vec3 samplePos     = surfacePosition;
               samplePos.xz += vec2(x, y) * scale;

          vec3 refractVector = refract(lightVector, getCausticsNormal(samplePos), 0.75);

              samplePos     = refractVector * (waterDepth / refractVector.y) + samplePos;

          result += pow(1.0 - saturate(distance(position, samplePos) * distanceThreshold), distancePower);
        }
      }

      return pow(result * distancePower / _sqr(defocus), resultPower);
    }
  #endif

  #if PROGRAM == DEFERRED0
    #include "/lib/common/Normals.glsl"

    vec3 calculateCausticsNormal(in vec2 screenCoord) {
      vec3 coord = vec3(screenCoord * 2.0 - 1.0, 63.0);

      coord.xy /= 1.0 - _length(coord.xy);
      coord.xy *= 32.0;
      coord.xy += cameraPosition.xz;

      return getNormal(coord.xzy, OBJECT_WATER) * 0.5 + 0.5;
    }
  #endif

  #if PROGRAM == DEFERRED1
    
  #endif

#endif /* INTERNAL_INCLUDED_COMMON_CAUSTICS */
