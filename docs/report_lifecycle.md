# Report Lifecycle

## Report Creation

### Report Types

**Transient Hazards (2 hours)**

1. `accident`
2. `police`
3. `hazard`
4. `crime`

**Environmental Condition (12 hours)**

1. `flood`
2. `pothole`

**Infrastructure Issues (24 hours)**

1. `closure`
2. `construction`
3. `broken_traffic_light`

`other`: 6 hours

## Report Confirm

User taps "Still an Issue" -> type: `confirm`

Extends `expiresAt` by 1 hour, up to 48 hours past `createdAt`. Rate-limited: the same user may cast at most one confirm vote per report per 24-hour rolling window.

Confirm and resolve votes are tracked independently, casting one does not block the other.

## Report Resolve

User taps "Resolved" -> type: `resolve`

Shortens `expiresAt` by 1 hour, down to 1 hour past `createdAt`. Rate-limited: the same user may cast at most one resolve vote per report per 24-hour rolling window. 

Confirm and resolve votes are tracked independently, casting one does not block the other.

## Report Expiration

When `expiresAt` ≤ now, the report is automatically marked as expired and removed from the map.

Expired reports can still be accessed in the report history for reference.
