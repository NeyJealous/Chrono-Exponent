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
- [x] Push / Farm progression modes
- [x] Manual current-run wave selection
- [x] Boss failure → automatic Farm mode

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
- [x] unsigned iphoneos Xcode build
- [x] unsigned IPA artifact
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

1. install the unsigned IPA on a real iPhone after re-signing;
2. verify touch targets, safe areas and landscape UX;
3. profile FPS, battery usage and device temperature;
4. implement export/import save;
5. replace basic offline reward with accurate offline simulation.


## iOS pipeline status — validated

Implemented and validated:

- macOS GitHub Actions workflow;
- Godot 4.7.2 macOS runtime;
- matching iOS export templates;
- iOS export preset;
- Godot → Xcode project export;
- Xcode project validation;
- unsigned Release build for `iphoneos`;
- `.app` creation;
- unsigned IPA packaging;
- IPA and Xcode artifacts.

Pending:

- Apple signing / re-signing for installation;
- installation test on a real iPhone;
- touch / Safe Area / Haptics validation;
- performance, battery and temperature profiling.

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


## iOS unsigned-build milestone — validated

Validated in GitHub Actions macOS run **#13**:

- Godot 4.7.2 macOS launch: passed;
- matching iOS export templates: passed;
- Godot project import: passed;
- Godot → Xcode project export: passed;
- generated Xcode project validation: passed;
- unsigned Release build for `iphoneos`: passed;
- `.app` bundle creation: passed;
- unsigned IPA packaging: passed;
- IPA artifact upload: passed;
- Xcode project artifact upload: passed.

Artifacts from the validation run:

- `ChronoExponent-unsigned-IPA` — ~27.4 MiB;
- `ChronoExponent-iOS-Xcode` — ~394.8 MiB.

The next iOS gate is **signing / re-signing and installation on a real iPhone**. The unsigned IPA itself is not directly installable until a valid Apple signature is applied.


## Real-device feedback — boss loop / wave control

Implemented after the first successful iPhone test:

- boss failure no longer forces an automatic retry loop;
- failed boss switches to FARM on the previous normal wave;
- FARM repeats the selected wave until the player chooses otherwise;
- PUSH resumes normal forward progression;
- player can select any wave reached during the current run;
- boss waves cannot be used as permanent FARM targets;
- wave-control state is persisted in save version 5;
- balance simulator farms until an upgrade is purchased, then retries in PUSH.
