# solarsim — Interactive Cinematic Sun Simulation

## Context

We're building **solarsim** from scratch (the working dir `D:\solarsim` is empty, not yet a git repo): a high-quality, graphics-intensive, *interactive* simulation of the Sun, with the hero feature being the **solar prominences** — the arcing loops of glowing plasma that lift off the limb (see the user's H‑alpha / SDO reference imagery). The goal is a beautiful, living star you can orbit, with a granulated turbulent surface, a soft corona, prominences/filaments/sunspots/coronal holes, and on‑demand eruptions. We start with a runnable skeleton and improve iteratively.

**Decisions locked with the user:**
| Decision | Choice |
|---|---|
| Engine | **Unity** |
| Render pipeline | **URP** — cross‑platform (Windows + Apple‑Silicon macOS via Metal) with near‑zero friction; lighter, and still delivers the full look. (HDRP was considered but carries Apple‑Silicon risk for marginal gain on this scene.) |
| Fidelity | **Cinematic / art‑first** (physically *inspired*, beauty first) |
| Camera | **Free‑orbit 3D sun** (limb, full disk, and eruption views all fall out of one orbitable sphere) |
| Interactions | **All**: trigger eruptions/CMEs, solar‑activity slider, wavelength/filter presets (Hα / 171Å / 304Å / white‑light), time controls (pause/slow/fast/scrub) |
| Targets | **Windows + macOS (Apple Silicon, native arm64)** — Unity 6 builds both natively from one repo |

> Note: distribution is **native builds for Windows and macOS (Apple Silicon)** shipped via GitHub Releases. Unity 6 runs natively on Apple Silicon (Editor + arm64 player builds — no Intel/Rosetta), so the same repo builds smoothly for both.

## Tech stack

- **Unity 6 LTS (6000.x)**, **URP** ("Universal 3D" template). C# for logic. Builds natively for **Windows and macOS Apple Silicon** from one project.
- **Shaders:** Shader Graph for the material graph + **Custom Function nodes backed by `.hlsl` include files** for the heavy noise/lighting math (the seam‑free 3D noise, FBM, domain warp, curl advection, palette, limb darkening live in reusable HLSL — the Unity equivalent of the `#include` chunks the research recommends).
- **Prominences/spicules/CME:** **VFX Graph** (GPU‑resident particles, HDR‑emissive so they feed bloom, GPU events for eruptions). This was the whole reason Unity wins for this project.
- **Post:** URP **Volume** framework — Bloom (HDR, with Threshold), Tonemapping (ACES), Color Adjustments/exposure, Vignette, Film Grain, Chromatic Aberration, Lens Distortion. URP has no built‑in volumetric god‑rays, so (optional) god‑rays are a custom **ScriptableRendererFeature** full‑screen radial‑blur pass.
- **UI / state:** one **`SunParams` ScriptableObject** as the single source of truth, surfaced both in the Inspector (tuning) and a runtime **UI Toolkit** control panel (sliders/buttons/presets). All sim animation driven from an **accumulated sim‑time** integrated as `dt * timeScale` (never wall‑clock) so pause/slow/fast/scrub is one multiplier.
- **VCS:** Git + **Git LFS** for binaries, Unity `.gitignore`/`.gitattributes`, committed `.meta` files. Repo pushed to **github.com/Popespice/solarsim** (gh is authenticated as `Popespice`).

## Architecture (modules)

| Module | Responsibility | Approach |
|---|---|---|
| **Bootstrap & camera** (`Scripts/Core/`) | Orbit camera, sim‑time clock, drives all module params from `SunParams` each frame | Free‑orbit camera controller; `SimClock` integrates `dt*timeScale`; HDR URP camera on a true‑black background |
| **Photosphere surface** (`Shaders/Sun/`, `SunSurface.shadergraph` + `Noise.hlsl`/`Fbm.hlsl`/`Palette.hlsl`) | The living granulated disk | Icosphere + HDR‑emissive Shader Graph; sample 3D simplex noise on **`normalize(objectPos)`** (NEVER UV — avoids seam/pole pinch); 4‑octave FBM granulation + slow supergranulation; one domain‑warp pass; curl‑noise advection so cells shear/swirl; IQ cosine Hα palette; quadratic limb darkening + reddening; chromospheric rim glow |
| **Surface features** (same shader, mask layers) | Sunspots, plage/bright network, dark filaments, coronal holes | Thresholded low‑freq noise masks: subtract umbra/penumbra for spots, add plage, subtract elongated anisotropic noise for filaments |
| **Corona shells** (`Shaders/Corona/`) | Soft layered chromosphere→corona halo | 2–3 inverted‑Fresnel **additive** transparent shells (cull front / backside) at scale ~1.05/1.25/1.5, reddening gradient, animated polar fbm shimmer — cheap halo so bloom radius stays small |
| **Prominences (hero)** (`VFX/Prominences.vfx`, `Scripts/Prominences/`) | Arcing plasma loops at the limb | **Hybrid:** C# generates analytic semicircle/semi‑ellipse arc skeletons from footpoint pairs on the sphere → (a) swept procedural **tube mesh** with parallel‑transport (rotation‑minimizing) frame for the bright core, (b) **VFX Graph particle threads** seeded at footpoints, velocity = `mix(loopTangent ~80%, curlNoise ~20%)` up one leg, over apex, down the other; all additive HDR |
| **Spicules / limb fibrils** (`VFX/Spicules.vfx`) | Hairy plasma‑jet forest on the silhouette | VFX Graph near‑radial tapered jets, rise‑then‑fall life cycle, gated by view‑grazing angle so they only show at the limb |
| **Dynamics & eruptions** (`Scripts/Prominences/`) | Quiescent sway + eruptive CME | Quiescent: gentle apex/plane sway + slow drift. Eruptive: an **eruption envelope** ramps apex height & footpoint separation and switches VFX particle velocity to a radial burst, fired by a GPU event from the UI button |
| **Post / grade** (`PostProfile.asset`) | The SDO/Hα cinematic look | URP Volume: keep space true‑black so only the HDR‑emissive sun/prominences bloom (Bloom Threshold isolates them); ACES tonemap last; add vignette/grain/CA/lens‑distortion after tonemap; optional god‑rays via a custom radial‑blur Renderer Feature |
| **State & UI** (`SunParams.asset`, `UI/ControlPanel`) | Single source of truth + live controls | `SunParams` ScriptableObject bound to a UI Toolkit panel: activity slider (scales prominence count/sunspots/turbulence), wavelength presets (swap palette + post), eruption button, time controls |

## Repository & GitHub setup (first executable step)

1. `git init` in `D:\solarsim`; add Unity **`.gitignore`** (`Library/ Temp/ Obj/ Build/ Logs/ UserSettings/ *.csproj *.sln`), **`.gitattributes`** (Git LFS for `*.png *.psd *.tga *.fbx *.wav` + Unity YAML merge), `README.md`, `LICENSE` (MIT — matches the shareable intent).
2. Install **Unity 6 LTS** via Unity Hub (user action, GUI), create the **Universal 3D (URP)** project so its `Assets/`, `Packages/`, `ProjectSettings/` land at the **repo root**. Add the **Visual Effect Graph** package (URP target).
3. `git lfs install`; commit the scaffold (incl. `.meta` files); `gh repo create Popespice/solarsim --public --source . --remote origin --push`.

## Milestone roadmap

Each milestone is independently runnable and visually demoable in Play mode. Sequencing front‑loads the two biggest risks (bloom washout, surface seam) on simple scenes.

- **M0 — Repo + URP project + glowing sphere.** Scaffold above; black scene, orbit camera, HDR‑emissive sphere, URP Volume with Bloom + ACES; smoke‑test a build on **both Windows and macOS Apple Silicon**. *Proves the HDR→bloom pipeline (and cross‑platform builds) before any complexity.*
- **M1 — Animated granulated photosphere.** `SunSurface` shader: seam‑free 3D‑noise FBM granulation + supergranulation + domain warp + curl advection + Hα palette + limb darkening + rim glow. The core visual identity.
- **M2 — Surface features + corona.** Sunspots, plage, filaments, coronal holes as mask layers; 2–3 Fresnel corona shells with shimmer.
- **M3 — Prominence loops (hero).** Arc skeletons from footpoints → tube cores + VFX Graph particle threads, staged off the limb into black.
- **M4 — Dynamics, spicules, eruptions.** Quiescent sway; eruption envelope + radial CME burst; limb spicule forest; optional god‑rays.
- **M5 — Cinematic grade + full UI.** Complete post stack; UI Toolkit panel: activity slider, wavelength/filter presets, eruption button, time controls (pause/slow/fast/scrub).
- **M6 — Performance hardening + release.** URP render‑scale / dynamic‑resolution + quality tiers, cap octaves at 4, cache material property blocks (no per‑frame allocs), Profiler pass for 60fps; produce **Windows + macOS (Apple Silicon)** builds + GitHub Release.

## Rendering technique cheat‑sheet (harvested from research, HLSL)

- **Seam‑free surface:** sample noise on `normalize(positionOS)` passed from vertex stage, never on UV.
- **FBM:** lacunarity 2.0, gain 0.5, **~4 octaves** (sweet spot); decorrelate octaves with per‑octave irrational offset / rotation.
- **Two‑scale convection:** `gran = fbm(N*40 + t)`, `supergran = fbm(N*6 + 0.2t)`, combine ~0.4/0.6.
- **Domain warp (IQ):** `surf = fbm(p + 4*vec3(fbm(p), fbm(p+o1), fbm(p+o2)) + t)` for the curdled plasma look.
- **Curl advection (makes it alive):** advect sample coord by divergence‑free curl of an fbm potential so cells shear instead of cross‑fading.
- **Hα palette (IQ cosine):** `a + b*cos(2π(c*t + d))`, warm‑fire coeffs → deep red→orange→yellow‑white.
- **Limb darkening:** `mu = dot(N,V); L *= 1 - 0.93*(1-mu) + 0.23*(1-mu)^2`; redden near limb. **Rim glow:** add `pow(1-mu,3) * vec3(1,0.4,0.15)`.
- **Sunspots:** `smoothstep(0.55,0.75, fbm(N*3+off))` subtracted; plage added; filaments = thresholded anisotropic (stretched) noise subtracted.
- **Corona shells:** `pow(1 - dot(N,V), p)` fresnel, additive, depth‑write off, reddening outward.
- **Prominence particles:** velocity `= normalize(mix(loopTangent, curlNoise(pos), 0.2))`; eruption switches to radial.
- **Tube cores:** sweep with **parallel‑transport frames** (Frenet snaps at the apex inflection).

## Risks & mitigations (Unity‑specific)

- **Bloom washout (top visual failure):** keep space true‑black; only the sun/prominences are HDR‑emissive >1; tune Bloom intensity/scatter modestly; get the soft halo from additive Fresnel shells, not a huge bloom. If global URP bloom over‑blooms the surface, raise the Bloom **Threshold** or isolate via emissive intensity tiers (or a custom pass).
- **Surface seam/pole pinch:** 3D position noise only (covered above).
- **Additive transparency ordering:** prominences/corona need depth‑write off + correct render queue (after opaque) or they punch black holes / z‑fight.
- **Post ordering:** Bloom/god‑rays in linear HDR → ACES tonemap → grain/CA/vignette last, or the glow desaturates / grain gets blurred away.
- **Frame hitches vs 60fps:** cache `MaterialPropertyBlock`/uniforms, no per‑frame `new`, keep meshes coarse (detail is in the fragment shader), cap octaves, clamp resolution; lean on HDRP **Dynamic Resolution** + a quality tier that drops god‑rays/CA on weaker GPUs.
- **Cross‑platform shader portability:** custom `.hlsl` must use Unity's macros (avoid platform‑specific intrinsics) so Metal (Apple Silicon) and D3D (Windows) both compile; Shader Graph + VFX Graph cross‑compile automatically. Test the surface/prominence shaders on a Mac early (by ~M1) rather than discovering Metal quirks late.

## Verification

- **Per milestone:** open the main scene, enter **Play mode**, visually confirm the milestone's deliverable (e.g. M1: surface churns with no visible seam; M3: loops arc off the limb into black; M5: each control changes the sim live). Use the **Game view Stats** + **Profiler** to confirm ~60fps and bounded draw calls.
- **Surface seam check:** orbit a full 360° around the poles and meridian — no line/pinch.
- **Bloom check:** confirm black space stays black and only emissive features bloom.
- **Build check (M0 smoke + M6 final):** build **Windows and macOS Apple‑Silicon** players, run them, confirm parity with the editor and 60fps; attach to a GitHub Release.
- Where useful, capture screenshots (and computer‑use driving the editor) to confirm visuals between iterations.

## Key references

- IQ Domain Warping — https://iquilezles.org/articles/warp/ · IQ Cosine Palettes — https://iquilezles.org/articles/palettes/
- Codrops "Recreating FDL's Sun in Three.js" — https://tympanus.net/codrops/2021/01/25/recreating-frontier-development-labs-sun-in-three-js/
- Ben Podgursky procedural star — https://bpodgursky.com/2017/02/01/procedural-star-rendering-with-three-js-and-webgl-shaders/
- GLSL 3D simplex + FBM (P. Gonzalez Vivo) — https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
- Curl noise (Dziewanowski) — https://emildziewanowski.com/curl-noise/
- Solar prominences review — https://link.springer.com/article/10.1007/s41116-018-0016-2
- Unity Docs: URP, Visual Effect Graph, Volume post‑processing, UI Toolkit (translate the GLSL techniques to HLSL Custom Function nodes)
