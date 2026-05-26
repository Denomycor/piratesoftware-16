# POC TO FINAL GAME ROADMAP

## Project Overview

Current project is a Godot survival arena game created during a game jam.

Core concept:
- Player is an alien mounted on top of a car
- The car cannot steer, accelerate, or brake traditionally
- Movement is entirely recoil-based:
  - Shoot backwards to accelerate
  - Shoot sideways to turn
  - Shoot forward to slow down
- Player survives against enemy hordes in an arena
- Score is gained by surviving and killing enemies

Goal:
Transform the current prototype into a polished vertical slice suitable for:
- Steam testing/release
- Potential future mobile adaptation
- Foundation for a commercial indie game

The game should keep its current "Mad Max chaos" identity and recoil-driving uniqueness.

---

# DEVELOPMENT PRINCIPLES

## Keep What Already Works
Do NOT redesign:
- Core recoil movement
- Camera feel
- Current visual identity
- Current weapon swap flow
- Existing audio
- Existing enemy archetypes

The goal is polish and scalability, not reinventing the prototype.

---

# PRIMARY OBJECTIVES

## Technical
- Migrate project from Godot 4.3 to Godot 4.6.3
- Stabilize performance with 100–200 enemies
- Remove shader runtime stutter
- Improve enemy spawning reliability
- Add minimal automated/manual testing workflow

## Gameplay
- Finish grappling hook
- Add meta progression
- Add boost system expansion
- Prepare architecture for future cars/aliens/loadouts

## UX
- Add loading screen
- Add progression screens
- Improve overall game flow polish

---

# HIGH LEVEL MILESTONES

# MILESTONE 1 — PROJECT MIGRATION & STABILIZATION

## Goals
Get the project fully running on Godot 4.6.3 with stable gameplay.

## Tasks

### Engine Migration
- Open project in Godot 4.6.3
- Resolve all migration warnings/errors
- Fix deprecated APIs
- Validate:
  - Physics behavior
  - Particle systems
  - Materials/shaders
  - Input handling
  - UI rendering
  - Audio playback

### Rendering Validation
Determine whether the game currently uses:
- Forward+
- Compatibility renderer

Then benchmark both renderers.

Expected outcome:
- Choose renderer with best enemy count performance while preserving visuals.

### Stability Pass
Fix:
- Runtime errors
- Null references
- Broken scene references
- Missing resources
- Shader compile warnings

### Acceptance Criteria
- Game launches without errors
- Full gameplay loop works
- Existing weapons function correctly
- Existing enemies function correctly
- No migration-related crashes

---

# MILESTONE 2 — PERFORMANCE FOUNDATION

## Goals
Eliminate runtime stutter and prepare for high enemy counts.

## Tasks

### Shader Preloading System
Problem:
Shaders compile during gameplay causing stutters.

Solution:
Create async loading pipeline.

Implement:
- Loading screen scene
- Resource preloading manager
- Shader warmup process
- Material preload registry

Preload:
- Weapon effects
- Explosion shaders
- Post-processing shaders
- Enemy shaders
- Environmental shaders

### Loading Screen
Add:
- Progress bar
- Background art/logo
- Async loading
- Scene transition handling

### Enemy Optimization Pass
Investigate:
- Physics processing
- AI update frequency
- Particle counts
- Collision layers
- Expensive materials
- Navigation cost

Potential optimizations:
- Distance-based processing
- Reduced tick rates for distant enemies
- Object pooling
- Shared materials
- GPU particles where appropriate

### Acceptance Criteria
- No shader stutter during gameplay
- Stable gameplay with 100+ enemies
- Smooth arena transitions/loads

---

# MILESTONE 3 — ENEMY SPAWN SYSTEM FIXES

## Goals
Fix invalid enemy spawn locations and improve scalability.

## Current Problem
Enemies sometimes spawn:
- Inside obstacles
- In stuck positions
- In invalid navigation areas

## Tasks

### Spawn Validation System
Implement:
- Spawn collision checks
- Nav-validity checks
- Minimum obstacle distance checks
- Retry system for failed spawns

### Spawn Zones
Refactor random spawning into:
- Arena spawn regions
- Safe spawn boundaries
- Weighted spawn areas

### Spawn Visibility Rules
Enemies should preferably:
- Spawn outside immediate player visibility
- Avoid spawning directly on player
- Avoid tight geometry

### Scaling System
Improve wave scaling:
- Enemy count scaling
- Enemy stat scaling
- Spawn rate scaling over 15-minute run

### Acceptance Criteria
- No visibly stuck enemies
- No enemies spawning inside props/walls
- Stable enemy flow during long runs

---

# MILESTONE 4 — GRAPPLING HOOK COMPLETION

## Goals
Turn the grappling hook into a reliable utility/mobility tool.

## Design Intent
The hook is NOT:
- A physics swing system
- A realistic rope simulation

The hook IS:
- Utility tool
- Tight-corner movement tool
- Pickup retrieval tool
- Physics interaction tool

---

## Hook Behavior Rules

### Wall Hook
When attached to walls:
- Hook anchors correctly
- Car gets pulled toward anchor point
- Walls themselves never move

### Barrel Hook
When attached to barrels:
- Barrel is dragged toward player
- Barrels retain explosion functionality
- Hook interaction should feel physical but arcade-like

### Enemy Hook
Current enemy pulling already exists.
Refine and stabilize behavior.

### Boost Hook
When attached to boosts:
- Boost travels all the way to player
- Boost activates properly upon reaching player

---

## Technical Tasks

### Hook State Machine
Implement clear hook states:
- Idle
- Fired
- Attached
- Pulling
- Retracting
- Cooldown

### Collision Filtering
Hook must distinguish:
- Walls
- Enemies
- Boosts
- Physics props
- Invalid surfaces

### Physics Cleanup
Stabilize:
- Pull force
- Rope visuals
- Attachment logic
- Cancellation behavior

### Acceptance Criteria
- Hook reliably attaches
- Hook movement feels responsive
- No physics explosions/jitter
- Boost retrieval is reliable

---

# MILESTONE 5 — META PROGRESSION FOUNDATION

## Goals
Create long-term progression structure.

## Important
This is a STRUCTURE implementation only.
Do NOT spend time balancing skills yet.

---

# Progression Design

## Dual Progression Tracks
Separate progression for:
- Alien
- Car

Each should:
- Gain XP independently
- Level independently
- Support future content expansion

This enables:
- Future alien types
- Future car types
- Future build/loadout variety

---

## Run Flow

### During Run
Player earns:
- Score
- Kill count
- Survival time

### End of Run
Convert score into XP.

### Progression Loop
- XP increases level
- Levels grant skill points
- Skill points unlock nodes

---

# Skill Tree Requirements

## Initial Scope
Simple implementation:
- Basic node grid/list UI
- Unlockable nodes
- Placeholder bonuses allowed

## Avoid
Do NOT implement:
- Complex branching systems
- Full RPG mechanics
- Deep balancing
- Respec systems

---

# Technical Tasks

## Save System
Implement simple JSON persistence:
- Alien XP
- Car XP
- Levels
- Skill points
- Unlocked nodes

Requirements:
- Local save only
- Minimal versioning support
- Easy future expansion

## Skill Tree UI
Add:
- Car progression screen
- Alien progression screen
- Unlock interaction
- Level indicators

## Data Structure
Use data-driven definitions where possible:
- Skill node resources
- XP requirements
- Unlock metadata

Avoid hardcoding progression trees directly in UI scripts.

### Acceptance Criteria
- XP persists between sessions
- Skill points can be spent
- Trees are expandable later
- Future cars/aliens are supported structurally

---

# MILESTONE 6 — BOOST SYSTEM EXPANSION

## Goals
Expand temporary powerup gameplay.

## Existing Boost
- Health pack

Health pack remains:
- Instant heal
- Permanent HP recovery

---

# New Boosts

## 2x Points
Effect:
- Doubles score gain temporarily

## Temporary Immunity
Effect:
- Prevent damage for limited duration

## Aura Damage
Effect:
- Damages nearby enemies over time

---

# Drop Rules

## Source
- Random enemy drops

## Lifetime
Boosts:
- Expire after time
- Can be hook-retrieved

---

# Technical Tasks

## Generic Boost Framework
Create reusable boost system:
- Timed effects
- Pickup behavior
- Expiration logic
- UI indicator support

## Boost Base Class
Recommended structure:
- Activate()
- Deactivate()
- Duration
- Visual effect hooks

## Pickup Feedback
Add:
- Pickup VFX
- UI timers
- Audio feedback hooks

### Acceptance Criteria
- All boosts function reliably
- Boosts expire correctly
- Hook retrieval works
- Multiple boosts can exist simultaneously

---

# MILESTONE 7 — GAME FLOW POLISH

## Goals
Improve overall structure and long-term usability.

## Tasks

### Victory Condition
Implement:
- 15-minute survival victory state
- Victory screen
- XP summary

### Run Summary
Display:
- Time survived
- Kills
- Score
- XP earned

### Main Flow
Target loop:
1. Main Menu
2. Start Run
3. Loading Screen
4. Gameplay
5. Death/Victory
6. XP Summary
7. Return to Menu

### Acceptance Criteria
- Complete loop functions cleanly
- No dead-end screens
- Proper restart flow

---

# ARCHITECTURE GUIDELINES

## Keep Refactors Moderate
Allowed:
- Moderate cleanup
- Better separation
- Reusable systems

Avoid:
- Full rewrites
- ECS conversion
- Overengineering

---

# PRIORITY SYSTEMS TO MAKE MODULAR

## Must Be Expandable
Design these systems for future content:
- Cars
- Aliens
- Skill trees
- Boosts
- Arenas

## Can Stay Hardcoded For Now
- Weapons
- Enemy roster
- Run structure

---

# RECOMMENDED TECHNICAL STRUCTURE

## Suggested Systems
- GameManager
- ProgressionManager
- SaveManager
- SpawnManager
- BoostManager
- LoadingManager
- HookController

## Suggested Data Resources
Use Resources or JSON for:
- Skill definitions
- XP curves
- Boost definitions
- Arena configs

---

# TESTING & QA MILESTONES

# Goal
Introduce minimal but real testing practices.

---

# QA PHASE 1 — CORE STABILITY

## Manual Test Checklist
After every milestone validate:
- Start game
- Start run
- Weapon swapping
- Enemy spawning
- Hook functionality
- Death flow
- Pause menu
- Save/load

---

# QA PHASE 2 — PERFORMANCE

## Benchmark Tests
Measure:
- FPS at 50 enemies
- FPS at 100 enemies
- FPS at 200 enemies

Track:
- Frame spikes
- Memory growth
- Shader stutter
- Physics spikes

---

# QA PHASE 3 — GAMEPLAY STABILITY

## Stress Tests
Test:
- Massive enemy counts
- Multiple explosions
- Simultaneous boosts
- Repeated hook usage
- Long sessions (30+ mins)

---

# NON-GOALS FOR THIS ROADMAP

Do NOT spend time on:
- Mobile controls
- Multiplayer
- Controller support
- Advanced balancing
- New enemy types
- Procedural generation
- Complex narrative
- Major camera redesign
- Full weapon modularity
- Advanced VFX polish

These belong in later production phases.

---

# FINAL TARGET STATE

At the end of this roadmap the game should:

- Run smoothly on Godot 4.6.3
- Support 100–200 enemies reliably
- Have no major shader stutter
- Have fully functional grappling hook utility gameplay
- Have a complete 15-minute run structure
- Include persistent meta progression
- Include expandable progression architecture
- Include several temporary boosts
- Feel like a polished commercial vertical slice rather than a game jam prototype

---

# DEVELOPMENT ORDER SUMMARY

1. Migration & stabilization
2. Performance foundation
3. Enemy spawn fixes
4. Grappling hook completion
5. Meta progression framework
6. Boost expansion
7. Flow polish & victory state
8. QA/performance validation

```