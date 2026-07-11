# Phase B risk notes

## Main risks

- Drift-generated files are not committed and must be generated locally.
- The current UI still uses the Phase A SharedPreferences path.
- The branch adds architecture, not final runtime SQLite integration.
- The sample content remains unreviewed.

## Mitigation

- CI runs build_runner before analysis.
- Docs clearly state the Phase C migration plan.
- Content validation blocks critical import errors.
