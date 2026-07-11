# Architecture

The project is moving toward a feature-first architecture while preserving the Phase A playable loop.

## Layers

- `lib/domain` — pure entities and repository contracts.
- `lib/data` — import, validation, and future repository implementations.
- `lib/core/database` — Drift/SQLite schema and migrations.
- `lib/main.dart` — Phase A runtime UI loop. This will be split into feature screens during later cleanup.

## Phase B decision

The Drift schema and repository interfaces are added now, but the UI is not yet fully wired to SQLite. This avoids risky partial migration while still preparing the production storage layer.

## Phase C integration plan

1. Generate Drift code with build_runner.
2. Add database providers.
3. Import bundled JSON into SQLite on first launch.
4. Migrate SharedPreferences progress into `level_progress` and economy/statistics tables.
5. Replace direct SharedPreferences writes in the UI with repository calls.
