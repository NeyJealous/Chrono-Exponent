# Chrono Exponent

2D action/incremental game for iOS.

The project combines:
- the active combat loop and visible DPS growth of Time Clickers;
- the long-form prestige/progression depth of Antimatter Dimensions;
- the automation philosophy of Revolution Idle.

Exponential Idle is intentionally not part of the current design direction.

## Tech

- Godot 4
- GDScript
- 2D only
- Landscape-first iOS UI
- GitHub Actions for CI/iOS build automation

## Current milestone — Prototype 0.1

Implemented foundation:
- tap damage;
- enemy HP and wave scaling;
- boss every 10 waves;
- boss timer;
- Energy economy;
- weapon upgrades;
- three automatic combat units;
- passive DPS;
- first prestige layer: Fracture / Fragments;
- functional 15-node Fracture Tree;
- five-target battlefield;
- Basic / Armored / Shielded / Regenerator targets;
- critical hits and combat feedback;
- ×1 / ×10 / ×25 / MAX purchasing;
- milestone unit unlocks;
- headless gameplay smoke tests;
- automated balance simulator;
- local save;
- basic offline reward;
- statistics foundation;
- manual GitHub Actions iOS/Xcode export pipeline.

## Run locally

1. Install Godot 4.x.
2. Clone this repository.
3. Open `project.godot`.
4. Run the project.

## Design

- `docs/GDD_CANONICAL.md` — **canonical full game design and current source of truth**.
- `docs/GDD.md` — early compact GDD.
- `docs/FRACTURE_TREE.md` — permanent Fracture upgrade tree.
- `docs/ARCHITECTURE.md` — technical architecture.
- `docs/ROADMAP.md` — implementation roadmap.
- `docs/BALANCE_NOTES.md` — progression calibration notes.
- `docs/IOS_BUILD.md` — staged iOS/Xcode/IPA build pipeline.

When documents disagree, follow `docs/GDD_CANONICAL.md` unless a newer decision explicitly supersedes it.

The prototype deliberately uses native Godot UI and placeholder shapes. Art direction comes after the gameplay loop is validated.
