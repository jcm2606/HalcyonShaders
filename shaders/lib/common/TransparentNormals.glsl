/*
  JCM2606.
  HALCYON.
  PLEASE READ "LICENSE.MD" BEFORE EDITING.
*/

#ifndef INTERNAL_INCLUDED_COMMON_TRANSPARENTNORMALS
  #define INTERNAL_INCLUDED_COMMON_TRANSPARENTNORMALS
  
  #include "/lib/common/util/Noise.glsl"

  // WATER
  float water0(in vec3 world) {
    float height = 0.0;

    vec2 position = world.xz - world.y;

    c(float) waveSpeed = 0.0017;
    c(vec2) waveDirection = swizzle2 * waveSpeed;
    vec2 move = waveDirection * frametime;

    c(mat2) rot = rot2(0.7);

    position *= 0.001;
    position *= rot;

    position *= vec2(1.0, 0.75);

    height += texnoise2D(noisetex, position + move * 0.25);
    height += texnoise2D(noisetex, position * 2.0 + move * 2.0) * 0.5;
    height -= texnoise2D(noisetex, position * 4.0 + move * 4.0) * 0.25;
    height += texnoise2D(noisetex, position * 8.0 + move * 8.0) * 0.125;
    height -= texnoise2D(noisetex, position * 16.0 + move * 16.0) * 0.0625;

    height *= 1.;

    return pow(abs(height * 2.0 - 1.0), 0.75) * 1.5;
  }

  float getWaterHeight(in vec3 world) {
    return water0(world);
  }

  // ICE
  float getIceHeight(in vec3 world) {
    return 0.0;
  }

  // STAINED GLASS
  float getGlassHeight(in vec3 world) {
    return 0.0;
  }
  
  // GENERIC
  float getHeight(in vec3 world, in float objectID) {
    return (comparef(objectID, OBJECT_WATER, ubyteMaxRCP)) ? getWaterHeight(world) : (
      (comparef(objectID, OBJECT_ICE, ubyteMaxRCP)) ? getIceHeight(world) : (
        (comparef(objectID, OBJECT_STAINED_GLASS, ubyteMaxRCP)) ? getGlassHeight(world) : 0.0
      )
    );
  }

  vec3 getNormal(in vec3 world, in float objectID) {
    c(float) normalDelta = 0.2;
    cRCP(float, normalDelta);

    float height0 = getHeight(world, objectID);
    float height1 = getHeight(world + vec3( normalDelta, 0.0, 0.0), objectID);
    float height2 = getHeight(world + vec3(-normalDelta, 0.0, 0.0), objectID);
    float height3 = getHeight(world + vec3(0.0, 0.0,  normalDelta), objectID);
    float height4 = getHeight(world + vec3(0.0, 0.0, -normalDelta), objectID);

    vec2 delta = vec2(
      ((height1 - height0) + (height0 - height2)),
      ((height3 - height0) + (height0 - height4))
    ) * normalDeltaRCP;

    return normalize(vec3(delta.x, delta.y, 1.0 - pow2(delta.x) - pow2(delta.y)));
  }

#endif /* INTERNAL_INCLUDED_COMMON_TRANSPARENTNORMALS */
