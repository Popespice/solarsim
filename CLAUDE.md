# solarsim — Claude Code guide

## Project

Interactive cinematic simulation of the Sun (solar prominences, granulated photosphere, eruptions).
See [docs/PLAN.md](docs/PLAN.md) for the full approved implementation plan and milestone roadmap.

## Stack

| Layer | Choice |
|---|---|
| Engine | Unity 6 LTS (6000.x) |
| Render pipeline | **URP** (Universal Render Pipeline) — NOT HDRP |
| Particles / prominences | VFX Graph |
| Shaders | Shader Graph + Custom Function nodes backed by `.hlsl` files |
| UI | UI Toolkit (runtime panel) |
| Language | C# for all scripts |
| Targets | Windows 10/11 · macOS 12+ Apple Silicon (arm64, Metal) |
| VCS | Git + Git LFS (binary assets tracked via LFS) |

## Repository layout (once Unity project is created)

```
solarsim/
├── Assets/
│   ├── Scenes/          # Main.unity and any sub-scenes
│   ├── Scripts/
│   │   ├── Core/        # SimClock, OrbitCamera, Bootstrap
│   │   └── Prominences/ # ProminenceManager, EruptionEnvelope
│   ├── Shaders/
│   │   ├── Sun/         # SunSurface.shadergraph + Noise.hlsl, Fbm.hlsl, Palette.hlsl, DomainWarp.hlsl, Curl.hlsl
│   │   └── Corona/      # CoronaShell.shadergraph
│   ├── VFX/             # Prominences.vfx, Spicules.vfx
│   ├── UI/              # ControlPanel.uxml / .uss
│   └── Settings/        # SunParams.asset (ScriptableObject), URP asset, post Volume profile
├── Packages/            # package.json — includes com.unity.render-pipelines.universal, com.unity.visualeffectgraph
├── ProjectSettings/
├── docs/
│   └── PLAN.md          # Approved implementation plan
├── .gitignore
├── .gitattributes        # Git LFS rules + UnityYAMLMerge
├── LICENSE
└── README.md
```

## Key architecture rules

- **Single source of truth:** `SunParams` ScriptableObject owns every tunable parameter. Scripts read from it; the UI panel writes to it. No magic numbers in C# or shaders — always a uniform fed from `SunParams`.
- **Sim time:** drive all animation from an **accumulated sim-time** (`SimClock.Time`), integrated as `dt * timeScale` each frame. Never pass `Time.time` directly to shaders — pass `SimClock.Time` so pause/slow/fast/scrub work by changing one float.
- **No per-frame allocations:** cache `MaterialPropertyBlock`, `Vector4`, matrix temporaries. No `new` inside `Update()`.
- **Seam-free surface:** always sample noise on `normalize(positionOS)` (object-space position), never on UV coordinates.
- **Additive transparency ordering:** corona shells and prominences use `AdditiveBlending`, `ZWrite Off`, render queue after opaque. Never `ZWrite On` on a transparent additive object.
- **Shader portability:** use Unity's `UNITY_*` macros and `#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"` — no D3D/Metal-specific intrinsics so both targets compile cleanly.
- **Post ordering:** Bloom runs in linear HDR space → ACES Tonemapping is the last Volume override → Grain/CA/Vignette are applied after tonemapping.
- **Meshes are coarse:** surface detail lives in fragment shaders, not vertex count. Keep icosphere resolution moderate.

## Rendering technique reference

- **Noise:** 3D simplex noise (`snoise(float3)`) from `Noise.hlsl`, texture-free
- **FBM:** 4 octaves, lacunarity 2.0, gain 0.5, decorrelated per-octave with irrational offset
- **Two-scale convection:** `gran = fbm(N*40 + t)`, `supergran = fbm(N*6 + 0.2*t)`, blend 0.4/0.6
- **Domain warp (IQ):** `surf = fbm(p + 4*float3(fbm(p+o0), fbm(p+o1), fbm(p+o2)) + t)`
- **Hα palette:** IQ cosine — `a + b*cos(TWO_PI*(c*t+d))` with warm-fire coefficients
- **Limb darkening:** `mu = dot(N,V); L *= 1.0 - 0.93*(1-mu) + 0.23*(1-mu)*(1-mu)`
- **Rim glow:** `+ pow(1-mu, 3) * float3(1, 0.4, 0.15)`
- **Corona fresnel:** `pow(1 - dot(N,V), p)` on back-face additive shells
- **Prominence velocity:** `normalize(lerp(loopTangent, curlNoise(pos), 0.2))`
- **Tube sweeps:** parallel-transport (rotation-minimizing) frames — Frenet frames snap at apex

## Milestone status

| # | Goal | Status |
|---|---|---|
| M0 | Repo scaffold + URP project + HDR glowing sphere | 🔄 in progress |
| M1 | Animated granulated photosphere | ⬜ |
| M2 | Surface features + corona shells | ⬜ |
| M3 | Prominence loops (hero) | ⬜ |
| M4 | Dynamics, spicules, eruptions | ⬜ |
| M5 | Cinematic grade + full UI | ⬜ |
| M6 | Performance hardening + release builds | ⬜ |

Update the Status column as milestones complete.

## Common commands

```powershell
# Open project in Unity (adjust editor version path as needed)
& "C:\Program Files\Unity\Hub\Editor\6000.x.x\Editor\Unity.exe" -projectPath "D:\solarsim"

# Build Windows player (headless)
& "...\Unity.exe" -batchmode -quit -projectPath "D:\solarsim" -buildWindows64Player "Build\Windows\solarsim.exe" -logFile build.log

# Build macOS player (requires Mac or Unity Cloud Build)
# Run from a Mac: Unity.app/Contents/MacOS/Unity -batchmode -quit -projectPath . -buildOSXUniversalPlayer "Build/macOS/solarsim.app"

# Git LFS — verify tracked files
git lfs ls-files

# Push after a Unity session
git add Assets/ Packages/ ProjectSettings/
git commit -m "..."
git push
```

## What NOT to do

- Don't use HDRP-specific APIs (`HDAdditionalLightData`, `CustomPass`, etc.) — we are on URP.
- Don't sample noise on `uv` / `TEXCOORD0` on the sphere — use object-space position.
- Don't allocate inside `Update()` / the render loop.
- Don't commit the `Library/` or `Temp/` folders — they're in `.gitignore`.
- Don't commit large binary assets without confirming Git LFS is tracking them (`git lfs track "*.exr"` etc.).
