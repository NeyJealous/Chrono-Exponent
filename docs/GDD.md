# Chrono Exponent — GDD v0.1

## Identity

A 2D action/incremental game that starts with active shooting and gradually becomes a deep optimization and automation game.

Inspirations:
- Time Clickers — active combat, waves, bosses, visible automatic DPS;
- Antimatter Dimensions — layered progression, challenges, very long-term growth;
- Revolution Idle — progressive automation and increasingly self-running systems.

Exponential Idle is currently excluded.

## Core loop

```text
Tap / automatic fire
        ↓
Damage
        ↓
Kill targets
        ↓
Energy
        ↓
Weapon + Team upgrades
        ↓
Higher waves
        ↓
Bosses
        ↓
Fracture
        ↓
Fragments
        ↓
Faster next run
```

## Prototype combat

- One visual target in Prototype 0.1.
- Boss every 10 waves.
- Boss timer: 30 seconds.
- Failed boss sends the player back one wave.
- Manual taps remain useful alongside passive DPS.

## Economy

### Energy
Run currency. Reset by Fracture.

### Fragments
First prestige currency. Persistent across Fractures.

Fragments provide permanent power in the prototype; later they fund a permanent upgrade tree.

## Team

Prototype units:
1. Pulse Drone — cheap early passive DPS.
2. Beam Array — mid-tier passive DPS.
3. Rail Cannon — expensive high-tier passive DPS.

Future units will have mechanically different attack behavior rather than only different DPS coefficients.

## Fracture

First prestige layer.

Initial unlock target: Wave 100.

Resets:
- wave;
- Energy;
- weapon level;
- team unit levels.

Keeps:
- Fragments;
- statistics;
- future artifacts/challenge rewards.

## Planned progression

```text
Combat
→ Fracture
→ Fragment upgrades
→ Artifacts
→ Challenges
→ Automation
→ Convergence
→ Unit evolutions
→ Advanced automation
→ later layers TBD
```

Later prestige layers are intentionally not fully specified until the first loop is validated.

## Automation philosophy

Automation is progression.

Planned order:
1. manual fire;
2. Auto Fire;
3. Auto Buy;
4. Auto Ability;
5. Auto Fracture;
6. conditional rules;
7. advanced automation.

The player first learns a repetitive task and later earns the ability to automate it.

## Prototype success criteria

1. Tapping feels responsive.
2. Buying upgrades creates a clearly visible acceleration.
3. The first Fracture strongly accelerates the next run.
4. Automatic DPS is enjoyable to watch while manual action remains useful.

## Art direction

2D only.

Initial visuals use placeholder geometric targets and native Godot UI. Final direction should emphasize:
- geometric/time-fracture motifs;
- clear hit feedback;
- particles;
- cracks and destruction stages;
- lasers/projectiles without 3D assets;
- readable scientific-number UI.
