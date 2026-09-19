# Roadmap

Development uses gated phases. A phase is complete only when its acceptance criteria pass.

## Phase 0 — Foundation

- [x] Repository initialized
- [x] Godot 4 project
- [x] Landscape prototype
- [x] Core/UI separation
- [x] Design docs
- [x] Headless validation workflow
- [x] iOS export workflow skeleton

## Phase 1 — Core combat

- [x] Tap damage
- [x] Enemy HP
- [x] Waves
- [x] Boss interval
- [x] Boss timer
- [x] Multiple target slots
- [x] Hit feedback
- [x] Damage numbers
- [x] Basic particles

**Gate:** combat is responsive and can run for 15 minutes without state errors.

## Phase 2 — Economy and team

- [x] Energy
- [x] Weapon levels
- [x] Three team units
- [x] Passive DPS
- [x] Buy ×10 / ×25 / MAX
- [x] Unit unlock milestones
- [x] Balance simulator scaffold (calibration pending)

**Gate:** no progression wall before first Fracture.

## Phase 3 — Fracture

- [x] Fracture reset scaffold
- [x] Fragment reward scaffold
- [x] Permanent upgrade tree — first 15 functional nodes
- [x] Prestige confirmation/summary
- [x] Per-run Fracture statistics

**Gate:** second run is measurably faster and remains interesting.

## Phase 4 — Persistence

- [x] JSON local save
- [x] Autosave scaffold
- [x] Basic offline reward
- [x] Version migrations
- [ ] Export/import save
- [ ] Accurate offline simulation

## Phase 5 — Artifacts

10–15 artifacts with mechanical effects rather than simple percentage bonuses.

## Phase 6 — Challenges

Rule-changing challenges with permanent rewards.

## Phase 7 — Automation

Auto Fire → Auto Buy → Auto Ability → Auto Fracture → conditional rules.

## Phase 8 — Convergence

Second prestige layer. Details remain intentionally open until Fracture progression is validated.

## Phase 9 — iOS production

- [x] iOS export preset template
- [x] macOS Godot → Xcode workflow
- [ ] unsigned iphoneos Xcode build — validation in progress
- [ ] unsigned IPA artifact — validation in progress
- [ ] signing secrets / signed IPA
- [ ] device installation test
- [ ] performance/battery profiling
- [ ] touch/Haptics/Safe Area polish


## Current prototype note — 2026-09-19

Implemented after the initial foundation:

- real five-slot battlefield state;
- multiple simultaneous targets;
- Basic / Armored / Shielded / Regenerator target states;
- manual critical hits;
- visual hit flash and floating damage;
- destruction shard feedback;
- unit-specific attack cadence;
- milestone unlocks for Pulse Drone / Beam Array / Rail Cannon;
- geometric bulk purchase math for ×10 / ×25 / MAX;
- headless gameplay smoke test;
- first automated balance simulator.

Next gate:

1. verify CI is green on Godot 4.7.2;
2. run and calibrate the balance simulator;
3. tune first-run time to Wave 100;
4. implement the first playable Fracture Tree nodes;
5. create the first iOS export pipeline.


## iOS pipeline status — 2026-09-19

Implemented:

- manual macOS GitHub Actions workflow;
- Godot 4.7.2 macOS download;
- matching iOS export template installation;
- project-only iOS export preset;
- Apple Team ID secret validation;
- Xcode project verification;
- Xcode project artifact upload.

Pending:

- configure repository secret `IOS_TEAM_ID`;
- verify first successful Xcode export;
- certificate/provisioning-profile secrets;
- Xcode archive;
- signed IPA;
- installation test on a real iPhone.

See `docs/IOS_BUILD.md`.


## Fracture summary milestone

Implemented on the Fracture-summary branch:

- per-run timer and depth tracking;
- per-run damage, Energy, kills, crits and bosses;
- Fracture confirmation before destructive reset;
- preview of expected Fragment reward;
- post-Fracture result screen;
- direct path from result screen to Fracture Tree;
- save format v4 with migration from v3;
- Fracture reward based on current-run depth rather than lifetime highest wave;
- regression test preventing repeated Fracture from reusing a lifetime record.

This closes the basic prestige UX loop. The next balance gate is to compare first-run and second-run times using the simulator.


## iOS unsigned-build gate

The iOS pipeline no longer requires a real Team ID merely to validate Godot → Xcode export. A 10-character placeholder is used only for project generation when `IOS_TEAM_ID` is absent, while Xcode compilation explicitly disables signing.

The current gate is successful creation of:

- a readable generated Xcode project;
- an unsigned Release `.app` for `iphoneos`;
- `ChronoExponent-unsigned.ipa` suitable for later re-signing.
