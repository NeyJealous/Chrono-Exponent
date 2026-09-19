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


## Mirrored model sanity check — 2026-09-19

A separate deterministic mirror of the current GameState formulas and the simulator's "4 taps/sec + cheapest purchase" strategy was used as a sanity check while GitHub Actions was unavailable for connector-created commits.

Approximate result:

| Run | Time to Fracture | Relative trend |
|---|---:|---:|
| 1 | 47:40 | baseline |
| 2 | 35:00 | ~26% faster |
| 3 | 30:12 | ~14% faster than Run 2 |

This is **not authoritative** and must not replace the Godot headless simulator. It exists only to catch major logic errors and confirm that the current coefficients are in the intended region before CI/on-device verification.

The authoritative target remains actual `GameState` execution under Godot.


## Authoritative Godot baseline — CI run #51

Validated under **Godot 4.7.2 stable** using the actual `GameState` and deterministic simulator seed `1337`.

Strategy:

- 4 manual shots per second;
- cheapest-available Energy purchase;
- automatic Fracture Tree spending between runs;
- no artifacts;
- no challenge rewards;
- no advanced automation.

| Metric | Run 1 | Run 2 | Run 3 |
|---|---:|---:|---:|
| Time to Fracture | **48:09** | **36:36** | **29:33** |
| Wave 10 | 00:33 | 00:28 | 00:21 |
| Wave 25 | 04:03 | 02:37 | 01:46 |
| Wave 50 | 13:22 | 08:50 | 06:12 |
| Wave 75 | 32:20 | 23:25 | 18:19 |
| Wave 100 | 48:09 | 36:36 | 29:33 |
| Fragment reward | +2 | +2 | +2 |
| Boss failures | 61 | 43 | 32 |
| Longest purchase drought | 01:06 | 00:36 | 00:35 |
| Weapon level at Fracture | 69 | 68 | 69 |
| Unit levels | [59, 41, 25] | [58, 41, 25] | [58, 41, 25] |

First-run unlock timings:

- Pulse Drone: **00:13**
- Beam Array: **01:36**
- Rail Cannon: **08:33**

Runs 2 and 3 start with all three prototype units already milestone-unlocked because unit availability is based on lifetime progression.

### Prestige acceleration

- Run 1 → Run 2: **1.32× faster**, **24.0% less time**
- Run 2 → Run 3: **1.24× faster**, **19.3% less time**
- Run 1 → Run 3: approximately **38.6% less time**

### Current conclusion

The first Fracture lands almost exactly in the intended **30–60 minute** window, and the next two runs accelerate materially without collapsing into near-instant resets.

Therefore the current base economy is accepted as the **Prototype 0.1 balance baseline**.

This is not final release balance. It remains subject to real-device playtesting, changes to combat feel, additional Fracture Tree tiers, artifacts, challenges and automation.


## Push/Farm baseline — CI run #73

Validated after introducing explicit PUSH/FARM progression and boss-failure farming.

Simulator strategy:

- 4 manual shots/sec;
- cheapest available Energy purchase;
- boss failure automatically enters FARM;
- simulator remains in FARM until at least one upgrade is purchased;
- then it switches back to PUSH and retries progression.

| Run | Time to Fracture | Boss failures | Longest purchase drought |
|---|---:|---:|---:|
| 1 | **45:45** | 56 | 00:37 |
| 2 | **35:39** | 41 | 00:36 |
| 3 | **29:42** | 32 | 00:35 |

Prestige acceleration:

- Run 1 → Run 2: **1.28× faster**, 22.1% less time;
- Run 2 → Run 3: **1.20× faster**, 16.7% less time.

The first Fracture remains within the preferred 30–60 minute target. The explicit farming behavior therefore replaces the old automatic boss-retry loop without requiring a base-economy rebalance.
