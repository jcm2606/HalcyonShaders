Within this document, you will find high-level explanations of various effects within shaders.

# Shadows
In the industry, there are many techniques used to render dynamic shadows, however the one we're interested in is a technique called "shadow mapping". Shadow mapping is a very simple, incredibly flexible, and very cheap (at least in comparison to other techniques) approach to rendering shadows, that fits right into a rasterisation pipeline perfectly.

With shadow mapping, the scene is re-rendered from the perspective of all light sources in your scene, and information about the scene, namely the distance from the light source to a given surface, are recorded and stored in special textures dedicated to the shadow map. You may also find other information stored, too, for instance Optifine gives us 2 depth buffers (one includes transparent blocks, the other doesn't, allows for us to better support transparency in shadows), and 2 arbitrary colour buffers, which we mainly use for storing the colour and normals, for things like global illumination and coloured shadows.

To actually render the shadows, when you're rendering the scene from the actual camera the player is using, for each pixel you're rendering, you calculate what the distance from that pixel to the light source is, then you compare your calculated depth to the depth stored in the shadow map's depth buffer(s). If your calculated depth is greater than your stored depth, then that pixel is in shadow, if it isn't, then that pixel isn't in shadow. This will give you a binary 1 or 0, true or false, which represents whether the pixel is in shadow or not, and you can use this to influence a constant colour for that light source.

## Filtering
The problem with this form of shadow mapping, though, is it gives hard edges to your shadows, which often doesn't look realistic, nor appealing. In order to fix this, you could use what is called a "filter".

Essentially, a filter is just a blur applied to your shadow sample. Rather than comparing your calculated depth against the depth at a single point, you instead compare your calculated depth against the depths at multiple points in an area, adding those comparisons up, then dividing them by the total amount of samples you took to get the average comparison. If that was hard to follow, this code shows a quick and dirty shadow filter:

```glsl
/*
  Assume that:
    - 'shadowmap' is our shadow map's depth buffer.
    - 'shadowpos' is the calculated shadow position, where the X and Y components are our coordinates used when reading the shadow map, and the Z component is our calculated depth.
*/

float shadow = 0.0; // This is our final shadowing result, it'll be in the range of 0.0 -> 25.0 until we divide it.

const float radius = 0.001; // The radius of our filter, this controls how blurred our shadows are.

// A 5x5 kernel for our filter, essentially the blur will be 5x5, 25 total samples.
for(int i = -2; i <= 2; i++) {
  for(int j = -2; j <= 2; j++) {
    float shadowSample = float(texture2D(shadowmap, vec2(i, j) * radius + shadowpos.xy).x < shadowpos.z); // This is a single shadow sample.
    shadow += shadowSample; // Add our shadow sample to the 'shadow' variable.
  }
}

shadow /= 25.0; // We divide the 'shadow' variable by 25.0 to bring it down to the 0.0 -> 1.0 range.
```

In short, the filter softens the edges of shadows up by giving us the average shadowing result over an area around the point we *really* want to shadow. The filter will give us a floating-point value, *between* 0.0 and 1.0.

Now, the problem with this filter is it samples in a perfect square, aligned perfectly and exactly the same for each pixel on the screen, so the individual samples will be incredibly easy to distinguish. This can be mitigated by rotating the offset, ie the `vec2(i, j) * radius` part. This can be done by creating a 2x2 matrix, and basically populating it like...

```glsl
mat2x2 rotationMatrix = mat2x2(
   cos(x), sin(x),
  -sin(x), cos(x)
);
```

... where `x` is a value between 0.0 and 1.0 randomly assigned to each pixel. How it is assigned is up to you: a noise texture tiled across the screen, a noise function that takes the screen coordinates as an input, a dither function that takes the screen coordinates as an input. They'll give the same output, but with different patterns. Multiplying the offset by this matrix we calculated will give the entire blur a random rotation for each pixel, which will tremendously help break the individual samples up, however, you may end up with your noise pattern becoming visible.

So, with that, your shadows should now be nice and soft, however they are the same softness, no matter how far from the object casting them...

### PCSS
... which brings us to PCSS. PCSS, or Percentage-Closer Soft Shadowing, is a modification of our simple filter, that allows it become softer with distance, so you have nice crisp shadows right up close to the object, and beautiful soft shadows further away.

All PCSS does is it makes the radius of our filter depend on the distance from the object casting the shadow, and the surface receiving the shadow. PCSS is broken up into three stages:

1. Blocker search. We search a small area of the shadow map using a very small filter, often only 3x3, centered on the point we wish to shadow, getting the average depth for that area.

2. Penumbra size estimation. Now that we have the average depth, we can estimate what our radius for our main filter should be. The simplest function for this is simply `radius = (surface - blocker) * lightDistance`, where `surface` is the calculated distance, or depth, for the surface, `blocker` is the average depth we acquired through the blocker search, and `lightDistance` is some constant that determines how quickly our shadows soften. This function works fine in situations where the shadows are drawn in an orthographic fashion, such as a directional light (like the sun/moon), however in situations where they're drawn in a perspective fashion, such as a point/spot light, `radius = (surface - blocker) * lightDistance / blocker` is the recommended function to use, instead.

3. Filter. Now that we've got our size esimation, we simply plug it into our existing filter as the radius, and boom, your shadows should be nice and crisp near the caster, and should soften with distance.

Naive PCSS implementations tend to be quite inefficient. Without the rotation we implemented earlier, you really need a large kernel, at least 11x11, in order to get your shadows looking acceptable at large distances. The problem with this is it **very** quickly drives the sample count up: a 3x3 kernel uses 9 samples, a 5x5 kernel uses 25, 7x7 uses 49, 9x9 uses 81, 11x11 uses 121, 13x13 uses 169, etc. With anything smaller than around 11x11, individual samples become **incredibly** easy to notice as the shadows get progressively softer. But with the rotation, there is next to no perceivable difference between 5x5 and even 13x13.

#### PCSS Edge Prediction
Now, the other problem with PCSS is the softer the shadows get, the more and more cache misses you'll get when you sample the shadow map, so your performance will quickly degrade. This can lead to losses of sometimes 30-40 FPS when comparing PCSS during noon (where shadows have a slight to mild blur) to PCSS during sunset (where shadows are basically at their softest). I, personally, don't think other PCSS implementations have anything to mitigate this, however, Halcyon's PCSS implementation does.

Halcyon uses a system which I call "edge prediction". Essentially, edge prediction uses the blocker search to make educated guesses on where the player will actually see the blur, compared to where they won't. Think about it, the only place you *actually* see shadows be soft is on the edges of shadows. The middle is always solid shadow, so it doesn't matter if the shader is calculating PCSS there or not. This is what edge prediction looks for, it looks for edges to shadows, where PCSS will be noticeable. What it actually gives is a mostly-binary, 0-or-1 value for where it predicts an edge to be.

Halcyon uses this value to influence the radius of the filter for certain shadow samples, specifically the back occlusion sample. When edge prediction returns 0, Halcyon basically sets the filter radius to 0, forcing all samples to sample the same point, which reduces the amount of cache misses, significantly improving performance in some scenarios. It would be far more effective to just perform a single, early sample prior to the filter, then return out of the function prematurely so the filter doesn't run at all, but in my case, I need the filter to run for transparent object shadows.