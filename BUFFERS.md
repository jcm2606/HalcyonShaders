# colortex0
Framebuffer. Stores the colour of the pixel throughout the pipeline.

Format: RGBA16F.

Notes:
* colortex0 is a HDR colour buffer, and as such contains values > 1.0.

# colortex1
First gbuffer. Stores information regarding to the surfaces in the scene.

Format: RGB32F.

Channels:
* R: Encoded vec3, albedo.
* G: Encoded vec2, lightmaps.
* B: Raw float, object ID.

Notes:
* Before transparent programs, gbuffers both contain information for opaque blocks behind transparent blocks. After transparent programs, information for opaque blocks behind transparent blocks is lost, overwritten by information for transparent blocks.

# colortex2
Second gbuffer. Stores information regarding to the surfaces in the scene.

Format: RGB32F.

Channels:
* R: Encoded vec3, normal.
* G: Encoded vec2, first half of material data.
* B: Encoded vec2, second half of material data.

Notes:
* Before transparent programs, gbuffers both contain information for opaque blocks behind transparent blocks. After transparent programs, information for opaque blocks behind transparent blocks is lost, overwritten by information for transparent blocks.

# colortex3
Temporal passthrough. Stores information that is temporally blended between frames, using the 'skip clear' feature of Optifine.

Format: RGBA16.

Channels:
* R: Screen luma.
* G: Center depth.
* B: Free.
* A: Free.

# colortex4
Working buffer 0. Used to pass data between programs, usually for filtering. The data stores changes throughout the pipeline.

Format: RGBA16F.

Buffer/Channel Usage:
* deferred -> deferred1: AO stored in R.
* gbuffers_water -> composite: transparent reflections stored in RGB.
* composite -> composite1: volumetrics stored in RGBA.
* composite4 -> final: bloom stored in RGB.

Notes:
* colortex4 is a HDR buffer, and as such contains values > 1.0.

# colortex5
Working buffer 0. Used to pass data between programs, usually for filtering. The data stores changes throughout the pipeline.

Format: RGBA16.

Buffer/Channel Usage:
* composite -> composite1: volumetric clouds stored in RGBA.

# colortex6

# colortex7