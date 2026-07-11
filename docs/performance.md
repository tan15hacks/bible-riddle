# Performance

The app must remain smooth with 1,000+ riddles and future content packs.

## Phase B performance direction

- SQLite will replace large in-memory JSON-only state.
- Level lists can be paginated later if needed.
- Content imports should happen once per version, not on every screen open.
- Nonessential services such as ads, analytics, and remote content must not block startup.

## Future checks

- Cold-start timing
- Level-list scrolling
- Database query performance
- App Bundle size
- Lower-end Android device testing
