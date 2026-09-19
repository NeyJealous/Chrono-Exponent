# Balance Notes

## Baseline v0.1 — 2026-09-19

The first progression baseline is intentionally calibrated before implementing the full Fracture Tree.

### Target

A simple baseline player/bot using:

- 4 manual shots per second;
- cheapest-available purchase strategy;
- milestone unit unlocks;
- no artifacts;
- no challenge rewards;
- no advanced automation;

should reach the first Fracture around **30–60 minutes**.

The center target is roughly **45 minutes**.

### Initial problem

The original prototype values were:

- enemy HP growth: 1.145;
- Energy reward growth: 1.105;
- boss HP multiplier: 8.

A deterministic approximation stalled around **Wave 70 even after two simulated hours**.

That is considered a hard progression wall and is not acceptable for Prototype 0.1.

### Baseline adjustment

Current values:

- enemy HP growth: **1.135**;
- Energy reward growth: **1.115**;
- boss HP multiplier: **7**;
- boss reward multiplier: **6**;
- boss timer: **30 seconds**.

The simplified model reaches Wave 100 in roughly **46 minutes**.

This is a preliminary baseline, not a final balance result.

The in-engine headless simulator in `tools/balance_simulator.gd` is the authoritative next calibration step because it includes the actual GameState implementation.

### Required metrics

Future calibration should record:

- first Drone unlock time;
- first Beam unlock time;
- first Rail unlock time;
- Wave 10 / 25 / 50 / 75 / 100 timestamps;
- boss failures;
- longest period without an affordable meaningful upgrade;
- weapon and unit levels at Fracture;
- Fragments earned;
- second-run Wave 100 time;
- third-run Wave 100 time.

### Design rule

Do not compensate for a broken base economy by making permanent prestige bonuses absurdly large.

The first run must already have a healthy progression curve.


## Simulator diagnostics — Fracture summary milestone

The headless simulator now records, per run:

- Wave 10 / 25 / 50 / 75 / 100 timestamps;
- Pulse Drone / Beam Array / Rail Cannon unlock timestamps;
- boss failure count;
- longest period without a successful purchase;
- Fracture reward;
- weapon and unit levels;
- run-to-run time reduction and speed multiplier.

Preferred first-run target remains **30–60 minutes**.

A broader **20–80 minute guardrail** is reported separately so experimental balance changes can be diagnosed without immediately turning every tuning deviation into a hard CI failure.

Second and third runs should trend faster than the previous run. Exact acceleration targets remain intentionally unfixed until real simulator output and on-device playtesting are available.
