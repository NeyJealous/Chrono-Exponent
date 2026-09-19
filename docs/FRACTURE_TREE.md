# Fracture Upgrade Tree v0.1

Chrono Exponent uses a permanent upgrade tree inspired structurally by Time Clickers' post-prestige artifact progression, while using original names, effects, balance, and visuals.

## Core structure

Five permanent branches unlock after the first Fracture:

1. Arsenal — manual weapon / tap combat
2. Squadron — automatic team DPS
3. Reactor — Energy economy
4. Temporal — progression / run acceleration
5. Systems — abilities and automation

Nodes unlock upward through prerequisites. Each branch ends in a capstone that requires the main nodes beneath it.

Fragments are the currency for this tree.

## Layout concept

```text
                         FRACTURE CORE
                              │
          ┌───────────┬───────┼───────┬───────────┐
          │           │       │       │           │
       ARSENAL     SQUADRON  REACTOR TEMPORAL   SYSTEMS
          │           │       │       │           │
        Tier 1      Tier 1   Tier 1  Tier 1      Tier 1
          │           │       │       │           │
        Tier 2      Tier 2   Tier 2  Tier 2      Tier 2
          │           │       │       │           │
        Tier 3      Tier 3   Tier 3  Tier 3      Tier 3
          │           │       │       │           │
       CAPSTONE     CAPSTONE CAPSTONE CAPSTONE   CAPSTONE
```

The five branches are intentionally visible at once so the player can compare permanent priorities after each Fracture.

---

# 1. Arsenal

Focus: active/manual combat.

### Tier 1
- Residual Caliber — permanent tap damage multiplier.
- Critical Memory — permanent critical chance.
- Heavy Chamber — permanent critical damage.

### Tier 2
- Split Shot — chance for a manual shot to fire an additional projectile.
- Penetration — part of manual damage ignores armor.
- Weak Point Scan — manual hits against bosses gain increasing damage.

### Tier 3
- Recursive Trigger — critical hits can trigger another reduced hit.
- Kill Momentum — manual kills temporarily raise manual fire power.
- Overpressure — damage rises while continuously attacking the same target.

### Capstone: Fractured Arsenal
Manual attacks inherit a fraction of Team DPS and selected automatic bonuses.

Goal: manual play remains useful deep into progression instead of becoming obsolete.

---

# 2. Squadron

Focus: automatic units.

### Tier 1
- Team Synchronization — total Team DPS multiplier.
- Calibration — automatic unit attack speed.
- Targeting Network — bonus damage against priority targets.

### Tier 2
- Crossfire — units gain damage for every other active unit type.
- Boss Protocol — team damage against bosses.
- Overkill Routing — excess damage partially transfers to another target.

### Tier 3
- Shared Criticals — automatic attacks can use a team-wide critical system.
- Formation Bonus — all unlocked unit classes increase global team efficiency.
- Adaptive Targeting — automatic units gain damage against enemies surviving too long.

### Capstone: Unified Battery
All automatic units contribute to a shared multiplier based on total purchased unit levels.

Goal: encourage developing the whole team, not only one mathematically dominant unit.

---

# 3. Reactor

Focus: Energy income and purchasing power.

### Tier 1
- Residual Energy — bonus Energy from kills.
- Boss Harvest — additional Energy from bosses.
- Efficient Conversion — general Energy multiplier.

### Tier 2
- Salvage — chance for defeated targets to drop an extra Energy burst.
- Compound Yield — Energy gain increases during long runs.
- Price Compression — reduces effective upgrade cost growth slightly.

### Tier 3
- Overflow — excess boss damage converts partially into Energy.
- Chain Salvage — consecutive kills raise temporary Energy gain.
- Deep Extraction — higher waves gain an additional reward multiplier.

### Capstone: Closed Reactor
A small percentage of all Energy spent during a run is returned over time.

Goal: the economy branch affects both income and spending efficiency.

---

# 4. Temporal

Focus: reaching meaningful content faster after reset.

### Tier 1
- Starting Charge — begin each run with Energy.
- Wave Memory — start above Wave 1 after Fracture.
- Fragment Echo — increases Fragments earned.

### Tier 2
- Accelerated Timeline — early waves receive a large damage bonus.
- Boss Memory — previously defeated milestone bosses are easier on future runs.
- Temporal Skip — chance to skip an ordinary wave after instantly clearing it.

### Tier 3
- Compressed Beginning — automatically resolves trivial early waves.
- Milestone Recall — selected unlocks remain available immediately after Fracture.
- Deep Fracture — rewards disproportionately deeper runs.

### Capstone: Timeline Compression
The game automatically skips content whose estimated clear time is below a small threshold, while still granting the appropriate rewards.

Goal: eliminate repetitive replay of solved early game without deleting the feeling of progression.

---

# 5. Systems

Focus: abilities and later automation.

### Tier 1
- Coolant Loop — shorter ability cooldowns.
- Extended Cycle — longer ability duration.
- Reserve Charge — abilities begin a run partially charged.

### Tier 2
- Auto Fire — unlocks continuous player weapon fire.
- Auto Buy I — automatically purchases a selected upgrade category.
- Ability Queue — allows abilities to trigger in a chosen order.

### Tier 3
- Auto Buy II — priority-based purchasing.
- Auto Fracture — prestige at a configurable Fragment threshold.
- Trigger Conditions — simple IF conditions for abilities.

### Capstone: Control Kernel
Unlocks the first rule-based automation editor.

Example:
```text
IF boss
AND boss_time < 15
THEN use Overdrive

IF fracture_reward >= previous_reward * 5
THEN Fracture
```

Goal: automation is earned gradually and becomes a major progression system.

---

# Costs

The first prototype should not copy Time Clickers' exact costs.

Recommended form:

```text
cost(level, node) =
base_cost(node) * growth(node)^level
```

Node families should use different curves:

- basic multiplier nodes: many relatively cheap levels;
- mechanic nodes: few expensive levels;
- unlock nodes: usually one level;
- capstones: single major purchase.

This produces a mix of incremental spending and milestone decisions.

---

# Respec

Fracture tree respec should be supported.

Initial design:

- free respec while the feature is still being balanced;
- later, respec remains cheap or free;
- no permanent punishment for experimenting with builds.

The goal is to encourage testing rather than forcing players to follow a guide.

---

# Design rule

No branch should be universally mandatory.

A player should be able to favor:

- active manual play;
- idle/team damage;
- economy;
- rapid prestige progression;
- automation.

Some upgrades will naturally be stronger at different stages, but the tree should avoid a single permanent optimal purchase order.

---

# Prototype scope

For Prototype 0.1, implement only 3 nodes per branch plus one branch capstone placeholder.

Full branch depth comes after balance simulation proves that Fracture itself is fun.
