# Halcyon Pipeline
* deferred: AO generation.
* deferred1: Sky, opaque shading.
* deferred2: Opaque reflections.
* gbuffers_water: Refraction, surface-to-eye water absorption generation, transparent reflection generation.
* composite: Volumetrics generation, volumetric cloud generation, surface-to-eye water absorption application, transparent reflection application.
* composite1: Volumetrics application, volumetric cloud application.
* composite2: Camera exposure with temporally accumulated luma compensation.
* composite3: Depth-of-field with temporally accumulated center depth.
* composite4: Bloom tile generation.
* final: Bloom application, tonemapping.
