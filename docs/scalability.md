# Scalability

The master requirement expects support for more than 1,000 riddles and future growth to larger content packs.

## Phase B scalability choices

- Riddle content is modeled for SQLite instead of widget-level hardcoding.
- Content metadata includes story event IDs and concept tags.
- Validation tooling blocks duplicate IDs, repeated story events, invalid choices, and missing required fields.
- CSV import allows batch authoring from spreadsheets.

## Future improvements

- Paginated level queries
- Dedicated challenge history table
- Remote content manifest support
- Content version migration reports
