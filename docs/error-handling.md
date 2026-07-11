# Error handling

Phase B prepares for safer error handling around content and storage.

## Required behavior

The app should handle:

- Missing content
- Invalid JSON
- Content validation failures
- Database migration failure
- Corrupted preferences
- No internet
- Future ad, purchase, analytics, and sync failures

The game must never crash because optional online services are unavailable.
