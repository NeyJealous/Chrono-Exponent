# Roadmap

Development uses gated phases. A phase is complete only when its acceptance criteria pass.

## Phase 0 — Foundation

- [x] Repository initialized
- [x] Godot 4 project
- [x] Landscape prototype
- [x] Core/UI separation
- [x] Design docs
- [ ] Headless validation workflow
- [ ] iOS export workflow skeleton

## Phase 1 — Core combat

- [x] Tap damage
- [x] Enemy HP
- [x] Waves
- [x] Boss interval
- [x] Boss timer
- [ ] Multiple target slots
- [ ] Hit feedback
- [ ] Damage numbers
- [ ] Basic particles

**Gate:** combat is responsive and can run for 15 minutes without state errors.

## Phase 2 — Economy and team

- [x] Energy
- [x] Weapon levels
- [x] Three team units
- [x] Passive DPS
- [ ] Buy ×10 / ×25 / MAX
- [ ] Unit unlock milestones
- [ ] Balance simulation

**Gate:** no progression wall before first Fracture.

## Phase 3 — Fracture

- [x] Fracture reset scaffold
- [x] Fragment reward scaffold
- [ ] Permanent upgrade tree
- [ ] Prestige confirmation/summary
- [ ] Run statistics

**Gate:** second run is measurably faster and remains interesting.

## Phase 4 — Persistence

- [x] JSON local save
- [x] Autosave scaffold
- [x] Basic offline reward
- [ ] Version migrations
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

- iOS export preset
- signing secrets
- GitHub Actions IPA
- device testing
- performance/battery profiling
- touch/Haptics/Safe Area polish
