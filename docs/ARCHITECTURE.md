# Architecture v0.1

## Principle

Gameplay math is separated from presentation so progression can later be simulated headlessly without rendering the battle scene.

## Current modules

```text
Presentation
└── scripts/ui/main.gd
        │
        ▼
GameCore
├── GameState
├── Balance
└── SaveSystem
```

### Balance

Pure formulas and static configuration:
- enemy HP;
- rewards;
- upgrade prices;
- tap damage;
- unit DPS;
- Fracture reward;
- number formatting.

### GameState

Mutable run/player state:
- current/highest wave;
- enemy HP;
- currencies;
- weapon/team levels;
- combat tick;
- boss timer;
- prestige;
- statistics.

### SaveSystem

JSON persistence using `user://`.

## Planned split

As Prototype 0.1 grows, GameCore will be separated into:

```text
core/
├── number_system
├── economy_engine
├── combat_engine
├── wave_engine
├── enemy_system
├── unit_system
├── ability_system
├── prestige_system
├── artifact_system
├── challenge_system
├── automation_engine
├── offline_engine
└── statistics_engine
```

Do not put balance constants directly in UI scripts.
Do not make visual particles authoritative for damage.
All progression must be reproducible from GameCore state.
