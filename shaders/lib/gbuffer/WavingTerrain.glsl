/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_GBUFFER_WAVINGTERRAIN
  #define INTERNAL_INCLUDED_GBUFFER_WAVINGTERRAIN

  #if PROGRAM == GBUFFERS_TERRAIN || PROGRAM == SHADOW
    // MOVEMENT
    vec3 moveFullVertex(in vec3 position, cin(vec2) speed0, cin(vec2) speed1, in vec3 strength0, in vec3 strength1) {
      c(vec3) v0 = vec3(2.0) / 16.0;
      c(vec3) v1 = vec3(-3.0, 3.0, 3.0) / 16.0;

      c(float) pi2 = 2.0 * pi;

      float pi2ft = pi2 * frametime;

      float s0 = sin(pi2ft * speed0.x + dot(pi2 * v0, position));
      float s1 = sin(pi2ft * speed0.y + dot(pi2 * v1, position));

      vec3 move0 = (normalize(v0) * s0 + normalize(v1) * s1) * strength0;

      position += move0;

      c(vec3) v2 = vec3(5.0, 5.0, 6.0) / 16.0;
      c(vec3) v3 = vec3(-6.0, 5.0, 5.0) / 16.0;

      float s2 = sin(pi2ft * speed1.x + dot(pi2 * v2, position));
      float s3 = sin(pi2ft * speed1.y + dot(pi2 * v3, position));

      vec3 move1 = (normalize(v2) * s2 + normalize(v3) * s3) * (abs(s0 * s1) * 0.6 + 0.4) * strength1;

      return move0 + move1;
    }

    vec3 moveTopVertex(in vec3 position) {
      float fy = fract(position.y + 0.001);

      if(fy > 0.002) return vec3(0.0);

      c(float) pi2 = 2.0 * pi;
      c(float) rcp16 = 1.0 / 16.0;

      float wave = 0.05 * sin(pi2 / 4.0 * frametime + pi2 * 2.0 * rcp16 * position.x + pi2 * 5.0 * rcp16 * position.z) + 0.05 * sin(pi2 / 3 * frametime - pi2 * 3.0 * rcp16 * position.x + pi2 * 4.0 * rcp16 * position.z);

      return vec3(0.0, clamp(wave, -fy, 1.0 - fy), 0.0);
    }

    // MAIN
    vec3 getMovedVertex(in vec3 position, in vec3 world, in vec2 entity, in float objectID) {
      bool topVertex = gl_MultiTexCoord0.y < mc_midTexCoord.y;

      if(topVertex && (
        false
        #ifdef WAVING_GRASS
          || entity.x == TALLGRASS.x
        #endif
        #ifdef WAVING_FLOWERS
          || entity.x == FLOWER_RED.x || entity.x == FLOWER_YELLOW.x || entity.x == DEADBUSH.x || entity.x == SAPLING.x
        #endif
        #ifdef WAVING_CROPS
          || entity.x == MUSHROOM_BROWN.x || entity.x == MUSHROOM_RED.x || entity.x == WHEAT.x || entity.x == NETHERWART.x || entity.x == CARROTS.x || entity.x == POTATOES.x
        #endif
      )) {
        position.xyz += moveFullVertex(world, vec2(0.3, 0.31), vec2(1.1, 0.9), vec3(0.03, 0.0, 0.03), vec3(0.03, 0.0, 0.03));
      }

      return position;
    }
  #endif

#endif /* INTERNAL_INCLUDED_GBUFFER_WAVINGTERRAIN */
