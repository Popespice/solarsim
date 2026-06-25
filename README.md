# solarsim

A high-quality, graphics-intensive interactive simulation of the Sun — with a focus on **solar prominences**: the arcing loops of glowing plasma that lift off the limb. Built in Unity 6 LTS with URP, targeting Windows and macOS Apple Silicon.

![Solar prominence reference](docs/assets/reference_prominence.jpg)

## Features

- **Living photosphere** — seam-free granulation, supergranulation, domain-warped turbulence, H-alpha palette, limb darkening
- **Surface features** — sunspots, plage/bright network, dark filaments, coronal holes
- **Solar prominences** — procedural arcing plasma loops (tube cores + VFX Graph particle threads), staged against black space
- **Spicules** — limb fibril forest via VFX Graph
- **Eruptions / CMEs** — on-demand eruptive prominences with radial burst
- **Soft corona** — layered Fresnel additive shells
- **Cinematic post** — Bloom, ACES tonemap, vignette, film grain, chromatic aberration

## Interactive controls

| Control | Description |
|---|---|
| **Orbit camera** | Left-drag to orbit, scroll to zoom |
| **Activity slider** | Scale overall solar activity (prominences, sunspots, turbulence) |
| **Wavelength presets** | H-alpha · 171 Å · 304 Å · white-light |
| **Trigger eruption** | Fire an eruptive prominence / CME on demand |
| **Time controls** | Pause · slow-mo · fast-forward · scrub |

## Requirements

- Unity 6 LTS (6000.x) with **Universal Render Pipeline** and **Visual Effect Graph** packages
- Windows 10/11 (DirectX 11+) **or** macOS 12+ on Apple Silicon (Metal)

## Getting started

1. Clone the repo:
   ```
   git clone https://github.com/Popespice/solarsim.git
   ```
2. Open **Unity Hub**, click **Add project from disk**, select the cloned folder.
3. Open in **Unity 6 LTS** — packages resolve automatically.
4. Open `Assets/Scenes/Main.unity` and press **Play**.

## Roadmap

See [docs/PLAN.md](docs/PLAN.md) for the full milestone breakdown.

| Milestone | Goal | Status |
|---|---|---|
| M0 | Repo + URP scaffold + glowing sphere | 🔄 in progress |
| M1 | Animated granulated photosphere | ⬜ |
| M2 | Surface features + corona shells | ⬜ |
| M3 | Prominence loops (hero feature) | ⬜ |
| M4 | Dynamics, spicules, eruptions | ⬜ |
| M5 | Cinematic grade + full UI | ⬜ |
| M6 | Performance hardening + release builds | ⬜ |

## License

MIT — see [LICENSE](LICENSE).
