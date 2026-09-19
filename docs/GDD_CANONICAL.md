# Chrono Exponent — Canonical Game Design v0.2

> Этот документ восстанавливает и фиксирует полный замысел, который был сформирован до переключения разговора на GitHub-репозиторий.
>
> Статус: **каноническая концепция проекта**.
>
> Текущие уточнения:
> - игра полностью 2D;
> - движок Godot 4;
> - язык GDScript;
> - основная платформа iOS;
> - ориентация landscape;
> - Exponential Idle пока исключён из источников вдохновения;
> - основные ориентиры: Time Clickers, Antimatter Dimensions и Revolution Idle;
> - дерево Fracture описывается отдельно в `docs/FRACTURE_TREE.md`.

---

# 1. Концепция

Chrono Exponent — 2D action/incremental-игра, которая начинается как активный шутер по волнам целей, а со временем превращается в глубокую систему автоматизации, prestige-циклов, билдов, испытаний и оптимизации.

Главная идея:

```text
Сначала игрок сам управляет системой.
Потом усиливает систему.
Потом автоматизирует знакомые действия.
Потом оптимизирует автоматизацию.
Потом открывается новая система,
которая снова требует ручного понимания.
```

Игра не должна становиться статичным "калькулятором генераторов". Даже когда большая часть прогрессии автоматизирована, визуальный бой остаётся центральным экраном.

---

# 2. Основные источники вдохновения

## Time Clickers

Берём как ориентир:

- активную стрельбу;
- волны;
- боссов;
- автоматические боевые юниты;
- рост DPS;
- prestige/reset;
- постоянные улучшения;
- быстрое повторное прохождение уже освоенного контента;
- понятное дерево постоянного развития.

Не копируем код, графику, названия, баланс и контент один в один.

## Antimatter Dimensions

Берём как ориентир:

- длинную мета-прогрессию;
- несколько prestige-слоёв;
- challenges;
- сильное ощущение ускорения;
- постепенное превращение ручной игры в автоматизированную;
- очень большие числа;
- новые механики как награду за продвижение.

## Revolution Idle

Берём как ориентир:

- постепенное раскрытие автоматизации;
- настройку условий;
- сильную взаимосвязь систем;
- необходимость оптимизировать цикл reset → build → reset;
- долгосрочный endgame.

## Exponential Idle

На текущем этапе **не используется как ориентир**.

---

# 3. Главный игровой цикл

Базовый цикл:

```text
Tap / Fire
    ↓
Damage
    ↓
Enemy destroyed
    ↓
Energy
    ↓
Upgrades
    ↓
Higher DPS
    ↓
Higher Waves
    ↓
Boss
    ↓
Fracture
    ↓
Fragments
    ↓
Permanent upgrades
    ↓
Faster next run
```

Цикл должен быть понятен за первые минуты, но развиваться десятки часов и дальше.

---

# 4. Основной экран

Игра проектируется в landscape.

Пример структуры:

```text
┌─────────────────────────────────────────────┐
│ WAVE 174                     7.42e31 ENERGY │
│                                             │
│      ◇          ■          ◇                │
│                                             │
│              ███████                        │
│             █  BOSS █                       │
│              ███████                        │
│          HP 5.28e29 / 8.00e29               │
│                                             │
│                    ⊕                        │
│                                             │
│ TAP 4.2e24               DPS 8.7e26         │
├─────────────────────────────────────────────┤
│ GUN │ TEAM │ UPGRADES │ FRACTURE │ SYSTEMS │
└─────────────────────────────────────────────┘
```

Основной экран должен:

- показывать живой бой;
- позволять стрелять одним касанием;
- отображать DPS и tap damage;
- показывать HP целей;
- показывать текущую волну;
- позволять быстро открыть покупку и улучшения;
- не заставлять игрока постоянно уходить в отдельные меню.

---

# 5. Поле боя

Базовая арена рассчитана на пять target slots:

```text
[1]        [2]        [3]

      [4]        [5]
```

Обычная цель занимает один слот.

Крупные противники и боссы могут занимать визуально несколько слотов.

Позже тип цели влияет на приоритет атаки:

- обычная;
- бронированная;
- щитовая;
- регенерирующая;
- поддержка;
- splitter;
- phase;
- elite.

Это позволяет сохранить смысл активного участия игрока даже после роста автоматического DPS.

---

# 6. Ручной урон

Игрок начинает только с собственного оружия.

Базовые параметры:

- Power;
- Critical Chance;
- Critical Damage;
- Multishot;
- Attack Speed / Auto Fire позже;
- Armor Penetration;
- Boss Damage;
- Splash / Chain / Pierce позднее.

Ручной урон **не должен стать бесполезным** после появления автоматических юнитов.

Поздние permanent upgrades и артефакты могут связывать manual и Team DPS.

Пример:

```text
Manual Damage =
Base Weapon Power
× Critical
× Manual Multipliers
× Prestige Multipliers
× Temporary Effects
```

---

# 7. Автоматические боевые системы

Первый набор:

## Pulse Drone

- дешёвый;
- частые атаки;
- слабый единичный урон;
- ранний источник passive DPS.

## Beam Array

- постоянный луч;
- усиливается при удержании одной цели;
- полезен против длительных целей.

## Rail Cannon

- медленная атака;
- высокий burst;
- сильная связь с critical damage;
- хорош против боссов.

Позднее:

- Missile Battery;
- Prism Core;
- другие классы.

Ключевое правило:

> Автоматические юниты не должны отличаться только коэффициентом DPS.

У каждого должна быть собственная механика, визуальное поведение и специализация.

---

# 8. Волны

Базовая структура:

- обычные волны;
- boss каждые 10 волн;
- крупные milestone-боссы через более длинные интервалы;
- специальные модификаторы на поздних стадиях.

Пример:

| Wave | Content |
|---|---|
| 1–9 | Normal |
| 10 | Boss |
| 20 | Boss |
| 50 | Elite Boss |
| 100 | Major milestone |
| 250 | Special Boss |
| 500 | Major milestone |
| 1000 | Major milestone |

---

# 9. Боссы

У босса есть ограничение времени.

Базовое значение prototype:

```text
30 seconds
```

Если игрок не успевает:

```text
Boss failed
    ↓
возврат на безопасную волну
    ↓
фарм / покупка улучшений
    ↓
повторная попытка
```

Это создаёт естественные progression walls вместо искусственного запрета на продвижение.

Позже боссы получают отдельные механики:

- несколько фаз;
- щиты;
- вызов adds;
- отключение части автоматических систем;
- изменение target priorities;
- ускорение таймера;
- временную неуязвимость.

---

# 10. Energy

Energy — основная run currency.

Получается за:

- уничтожение обычных целей;
- боссов;
- milestones;
- специальные эффекты;
- offline progress.

Тратится на:

- weapon level;
- team units;
- combat upgrades;
- ability upgrades.

Energy сбрасывается при Fracture.

---

# 11. Экономика

Базовая модель стоимости:

```text
Cost(level) =
BaseCost × Growth^level
```

Каждая система имеет собственный Growth.

Задача баланса:

- ранние покупки должны быть частыми;
- позже решения становятся менее очевидными;
- нельзя допускать длинных участков без meaningful purchase;
- нельзя допускать одну универсально лучшую кнопку на всю игру.

Поддерживаем:

```text
BUY ×1
BUY ×10
BUY ×25
BUY ×100
BUY MAX
```

Позже:

- Buy Max by efficiency;
- Auto Buy;
- priority-based purchasing.

---

# 12. Первый Prestige — Fracture

Fracture — первый крупный reset.

Предварительный unlock:

```text
Wave 100
```

Fracture сбрасывает:

- Wave;
- Energy;
- Weapon Levels;
- Team Levels;
- временные run upgrades.

Сохраняет:

- Fragments;
- permanent upgrades;
- achievements/statistics;
- challenge rewards;
- позднее — часть artifact progression.

---

# 13. Fragments

Fragments — первая permanent currency.

Предварительная формула для прототипа:

```text
Fragments =
floor((HighestWave / 50)^1.5)
```

Это **не финальная формула**.

Финальная функция должна учитывать:

- глубину run;
- diminishing/accelerating returns;
- отсутствие выгодной стратегии "reset каждую секунду";
- заметное вознаграждение за pushing;
- возможность позже добавлять multipliers.

Ключевой эффект:

> Первый Fracture должен резко ускорить второй run.

Пример целевого ощущения:

```text
Первый run:
Wave 100 ≈ 30–60 min

После нескольких Fracture:
Wave 100 ≈ несколько минут
```

Конкретные времена определяются симулятором, а не вручную.

---

# 14. Permanent Upgrade Tree

После первого Fracture Fragments тратятся в permanent tree.

Текущая структура подробно зафиксирована в:

`docs/FRACTURE_TREE.md`

Пять направлений:

- Arsenal;
- Squadron;
- Reactor;
- Temporal;
- Systems.

Архитектурно дерево вдохновлено понятностью Time Clickers, но эффекты, названия, баланс и развитие оригинальные.

---

# 15. Активные способности

Первый пул:

## Overdrive
Кратковременно резко увеличивает Team DPS.

## Rapid Fire
Увеличивает частоту ручных/автоматических выстрелов игрока.

## Critical Mass
Временно гарантирует или сильно усиливает критические попадания.

## Time Freeze
Останавливает или замедляет boss timer.

## Barrage
Наносит крупный мгновенный AoE/burst damage.

На ранней стадии:

```text
abilities = manual
```

Позже:

```text
abilities = configurable automation
```

---

# 16. Automation Progression

Автоматизация — не quality-of-life опция, выданная сразу.

Она сама является progression.

## Stage 0 — Manual

Игрок вручную:

- стреляет;
- покупает;
- активирует abilities;
- решает момент Fracture.

## Stage 1 — Auto Fire

Оружие получает автоматический огонь.

## Stage 2 — Auto Buy

Игрок выбирает:

- Weapon;
- Unit;
- Cheapest;
- priority list.

## Stage 3 — Auto Ability

Способности могут использоваться автоматически.

## Stage 4 — Auto Fracture

Пример:

```text
Fracture when reward >= 500
```

или:

```text
Fracture when reward >= previous × 5
```

## Stage 5 — Rule Automation

Пример:

```text
IF boss
AND boss_time < 15
THEN use Overdrive

IF fracture_gain >= previous_gain * 5
THEN Fracture
```

## Stage 6 — Advanced Automation

Позднее:

- conditions;
- priorities;
- loadouts;
- chained actions;
- different rules for push/farm/prestige.

Главный принцип:

> Сначала игрок учится делать действие хорошо вручную. Потом получает инструмент, позволяющий автоматизировать это действие.

---

# 17. Offline Progress

Offline progress должен быть частью настоящего progression engine, а не простой выдачей фиксированного процента валюты.

При возвращении:

```text
OFFLINE: 07h 42m

Waves cleared: 18,421
Bosses defeated: 1,842
Energy earned: 7.18e94
Fractures performed: 26
Fragments earned: 82,410
```

## Важное ограничение

Офлайн-прогресс не должен автоматически проходить механику, которую текущий билд объективно не способен пройти.

То есть симуляция должна учитывать boss walls.

Пример:

```text
Offline simulation
        ↓
доходит до boss
        ↓
проверяет estimated clear
        ↓
если boss не может быть убит
        ↓
останавливает progression
        ↓
фармит доступную волну
```

Позже automation может позволять offline Fracture и дальнейшее продвижение.

В ранней версии можно использовать offline cap, например 12 часов, с permanent upgrades, увеличивающими лимит.

---

# 18. Challenges

Challenges должны менять правила, а не просто увеличивать HP врагов.

Примеры:

## Lone Gun
Team DPS = 0.

Награда:
постоянное усиление manual damage.

## Silent Trigger
Manual fire отключён.

Награда:
усиление Team DPS.

## No Critical
Critical hits отключены.

Награда:
постоянное улучшение critical system.

## One System
Разрешён только один тип автоматического юнита.

Награда:
team synergy.

## Time Pressure
Boss timer сильно сокращён.

Награда:
улучшение boss timer / boss damage.

## Expensive Reality
Cost scaling повышен.

Награда:
снижение cost scaling.

Challenge должен заставлять игрока иначе использовать уже знакомые системы.

---

# 19. Modular Builds

Игрок должен иметь несколько разумных направлений развития.

Примеры:

## Active build
Сильный tap/manual damage.

## Idle build
Фокус на Team DPS и offline progression.

## Boss build
Burst, Rail, boss multipliers, abilities.

## Farm build
AoE, Energy multipliers, fast wave clear.

## Prestige build
Fragment gain, run acceleration, start wave, automation.

Позже необходимы:

- saved loadouts;
- быстрый switch;
- automation rules per loadout.

---

# 20. Artifacts

Artifacts добавляются после того, как Fracture loop доказал свою жизнеспособность.

Они должны в основном **менять механику**, а не быть простыми процентами.

Примеры:

- каждый 20-й выстрел повторяет предыдущий crit;
- kill уменьшает cooldown;
- Rail crit создаёт splash;
- manual hits временно усиливают Team DPS;
- multishot может рекурсивно вызвать дополнительный shot;
- unused ability постепенно заряжается сильнее.

Artifacts создают build diversity.

---

# 21. Большие числа

Игра не должна зависеть от обычного диапазона float как от предела progression.

Для MVP нужен собственный numeric abstraction.

Минимальная форма:

```text
sign
mantissa
exponent
```

Отображение:

```text
1,250
1.42e6
8.71e54
4.28e1200
```

Архитектура должна позволять позже перейти к более высоким слоям:

```text
1e1,000,000
ee100
...
```

Но сложные многослойные нотации не должны внедряться, пока реальный progression их не требует.

Number system должен быть изолирован от UI и gameplay presentation.

---

# 22. Statistics

Минимальный набор:

- Play Time;
- Current Run Time;
- Highest Wave;
- Total Waves;
- Total Damage;
- Total Energy;
- Bosses Defeated;
- Critical Hits;
- Fractures;
- Fastest Fracture;
- Best Fragments/min;
- Offline Time;
- Challenges Completed.

Позже:

- progression graphs;
- DPS history;
- build comparisons;
- prestige efficiency.

---

# 23. Save System

Save data должен иметь versioning с первого прототипа.

Пример:

```text
save_version
timestamp
player_state
currencies
units
upgrades
prestiges
artifacts
challenges
automation
statistics
settings
```

Сохранение:

- периодически;
- при background/close;
- после Fracture;
- после важных permanent purchases.

Обязательно позже:

- Export Save;
- Import Save;
- migration between versions;
- backup slot.

---

# 24. Баланс-симулятор

Баланс нельзя настраивать только "на ощущениях".

GameCore должен запускаться без renderer.

Нужен headless simulator, способный прогонять виртуальные runs.

Пример:

```text
Run #1
00:00 Start
05:10 First Drone
13:40 First Beam
24:50 Wave 50
43:20 Wave 100
43:25 First Fracture

Run #2
00:00 Start
01:30 First Drone
05:20 Wave 50
11:40 Wave 100
```

Симулятор должен измерять:

- time to wave X;
- time to first boss wall;
- purchase frequency;
- first Fracture time;
- Fragments/hour;
- second-run acceleration;
- dominant upgrade choices;
- progression walls;
- useless upgrades;
- runaway multipliers.

Позже можно прогонять тысячи вариантов баланса.

---

# 25. MVP / Prototype 0.1

Первый playable prototype должен доказать core loop.

Обязательное:

- 2D battlefield;
- tap shooting;
- visible hit feedback;
- enemy HP;
- 100+ waves;
- boss system;
- Energy;
- Weapon upgrades;
- 3 automatic units;
- passive DPS;
- critical system;
- damage numbers;
- Fracture;
- Fragments;
- первые permanent upgrades;
- save/load;
- offline progress;
- statistics;
- big-number abstraction;
- headless balance simulator;
- iOS build.

Не обязательно для первого playable:

- полный Artifact system;
- большой набор Challenges;
- advanced automation;
- Convergence;
- endgame;
- final graphics.

---

# 26. Prototype Success Criteria

Prototype считается успешным, если:

1. Стрелять приятно даже без progression.
2. Покупки заметно ускоряют прохождение.
3. Автоматические юниты приятно наблюдать.
4. Ручное участие остаётся полезным.
5. Boss walls ощущаются понятными, а не случайными.
6. Первый Fracture вызывает желание немедленно начать следующий run.
7. Второй run заметно быстрее первого.
8. Игрок регулярно принимает решения, а не только нажимает единственную оптимальную кнопку.

---

# 27. Первая iOS-сборка

Не ждать завершения всей игры.

Как только работают:

- living combat;
- базовая economy;
- первый Fracture;
- save/load;
- offline progression;

необходимо собрать первый IPA.

Pipeline:

```text
Windows / Codex
      ↓
GitHub
      ↓
GitHub Actions
      ↓
macOS runner
      ↓
Godot iOS export
      ↓
Xcode
      ↓
IPA
      ↓
real iPhone
```

На физическом устройстве проверяются:

- tap responsiveness;
- размеры targets;
- размеры текста;
- safe areas;
- landscape UX;
- скорость purchase flow;
- haptics;
- FPS;
- battery usage;
- нагрев;
- background/resume;
- save reliability.

---

# 28. Technical Architecture

Боевая математика отделяется от presentation.

Целевая структура:

```text
GameCore
├── NumberSystem
├── EconomyEngine
├── CombatEngine
├── WaveEngine
├── EnemySystem
├── UnitSystem
├── AbilitySystem
├── PrestigeSystem
├── ArtifactSystem
├── ChallengeSystem
├── AutomationEngine
├── OfflineEngine
├── StatisticsEngine
└── SaveSystem

Presentation
├── Battle
├── HUD
├── Menus
├── Animation
├── Particles
├── Audio
├── Haptics
└── Input
```

Правило:

> Ни одна визуальная анимация не должна быть authoritative gameplay state.

---

# 29. Технический стек

Основной выбор:

```text
Godot 4
+
GDScript
+
GitHub
+
GitHub Actions
+
Xcode export for iOS
```

Причины:

- 2D отлично подходит под Godot;
- удобная разработка на Windows;
- простой headless runtime;
- хорошая модульность;
- нет необходимости в 3D pipeline;
- GDScript снижает сложность iOS export по сравнению с экспериментальными C#-сценариями;
- проект удобно автоматизировать через Codex.

---

# 30. Метапрогрессия

Предварительный порядок систем:

```text
Active Combat
      ↓
Energy
      ↓
Team
      ↓
Fracture
      ↓
Fragments
      ↓
Permanent Tree
      ↓
Artifacts
      ↓
Challenges
      ↓
Automation
      ↓
Convergence
      ↓
Unit Evolutions
      ↓
Advanced Automation
      ↓
Future prestige layers
```

Поздние prestige layers специально не фиксируются полностью сейчас.

Сначала должен быть доказан первый цикл.

---

# 31. Второй Prestige — Convergence

Convergence планируется как второй крупный reset, но пока не должен разрабатываться подробно.

Он может сбрасывать:

- текущий run;
- Fragments;
- большую часть Fracture upgrades;
- часть промежуточных систем.

Взамен:

- новая currency;
- unit evolutions;
- более глубокая automation;
- новые challenge layers;
- новые правила progression.

Ключевое правило:

> Новый prestige layer обязан открывать новую механику, а не только новый multiplier.

---

# 32. Монетизация

Для текущей личной / prototype-версии:

**монетизация отсутствует.**

Никаких:

- forced ads;
- rewarded ads;
- paywalls;
- premium currency;
- energy timers.

Если когда-нибудь проект станет публичным, монетизация проектируется отдельно и не должна ломать баланс.

Предпочтительные безопасные варианты для будущего обсуждения:

- cosmetic themes;
- soundtrack/supporter pack;
- one-time premium purchase;
- purely cosmetic customization.

Core progression не должен проектироваться вокруг платежей.

---

# 33. Основной принцип контента

Новая система не должна существовать только ради:

```text
Damage ×10
```

Хорошее открытие меняет поведение:

```text
Fracture
→ ускоряет повторные runs

Permanent Tree
→ позволяет выбрать направление

Artifacts
→ создают builds

Challenges
→ заставляют иначе использовать системы

Automation
→ удаляет освоенную рутину

Convergence
→ меняет структуру progression
```

---

# 34. Что делаем сейчас

Текущий порядок:

## Phase A
Довести living combat:
- multiple target slots;
- hit feedback;
- damage numbers;
- particles;
- real unit attacks.

## Phase B
Довести economy:
- Buy ×10/25/MAX;
- crit;
- unit unlocks;
- proper scaling.

## Phase C
Сделать headless simulator и настроить первые 1–3 часа.

## Phase D
Реализовать Fracture Tree.

## Phase E
Сделать первый полноценный Fracture loop.

## Phase F
Собрать IPA и тестировать на iPhone.

Только после этого:

- Artifacts;
- Challenges;
- Automation;
- Convergence.

---

# 35. Главная формула проекта

```text
PLAY
 ↓
UNDERSTAND
 ↓
UPGRADE
 ↓
AUTOMATE
 ↓
OPTIMIZE
 ↓
RESET
 ↓
UNLOCK NEW RULES
 ↓
REPEAT
```

Это является главным дизайн-принципом Chrono Exponent.

---

# 9A. PUSH / FARM и ручной выбор волн

Игрок должен сам контролировать, когда продвигаться вперёд, а когда остановиться для фарма.

## PUSH

```text
Wave cleared
    ↓
next Wave
    ↓
Boss
    ↓
continue progression
```

В режиме PUSH после зачистки текущей волны игра переходит на следующую.

## FARM

В режиме FARM выбранная обычная волна повторяется бесконечно:

```text
Wave 39
  ↓ clear
Wave 39
  ↓ clear
Wave 39
```

Это позволяет накопить Energy и купить усиления перед новой попыткой продвижения.

## Поведение после поражения боссу

Boss failure больше не должен автоматически создавать цикл:

```text
Boss → previous wave → Boss → previous wave → ...
```

Вместо этого:

```text
Boss failed
    ↓
previous normal Wave
    ↓
FARM automatically enabled
    ↓
player farms / upgrades
    ↓
player presses PUSH
    ↓
next clear returns to Boss
```

## Ручной выбор волны

Игрок может вручную перейти на любую волну, уже достигнутую **в текущем run**.

Нельзя выбирать волну выше `run_highest_wave`.

Это важно: lifetime-рекорд не даёт возможности после Fracture мгновенно прыгнуть обратно на старую максимальную волну.

## Boss waves и FARM

Boss waves нельзя выбирать как постоянную FARM-цель.

Причина — boss reward выше обычной волны и бесконечный фарм босса ломал бы экономику.

Для попытки босса используется PUSH.

## Сохранение

Текущий режим и farm-wave входят в save state и восстанавливаются после перезапуска приложения.
