# Halcyon Pipeline
* deferred: AO generation.
* deferred1: Opaque shading.
* deferred2: Opaque reflections.
* gbuffers_water: Refraction, surface -> eye water absorption, transparent reflection generation.
* composite: Volumetrics generation, volumetric cloud generation, transparent reflection application.
* composite1: Volumetrics application, volumetric cloud application.
* composite2: Camera exposure with temporally accmulated luma compensation.
* composite3: Depth-of-field with temporally accumulated center depth.
* composite4: Bloom tile generation.
* final: Bloom application, tonemapping.
