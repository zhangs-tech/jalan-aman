# Jalan Aman — Report & Comment Pages Design Spec

---

## Context & Current State

| Page | Status |
|---|---|
| Map Page | ✅ Done (needs API sync — see Map Updates section) |
| Report List Page | 🔲 To build |
| Report Detail Page | 🔲 To build |
| Create Report Page | ✅ Exists (needs review) |
| Profile Page | ✅ Done, no spec needed |

State management: **Riverpod** throughout.
Navigation: `Navigator.push` (named routes or MaterialPageRoute).

---

## Map Page — Required Updates

The map currently uses hardcoded dummy data. It needs to sync with:

**Endpoint:** `GET /reports/map`
**Params:** `swLat`, `swLng`, `neLat`, `neLng` (current map viewport bounds)
**Trigger:** On map load + every time the user moves the map (debounced ~500ms)

### New Riverpod Provider needed
```
mapPinsProvider(MapBounds bounds) → AsyncValue<List<PinModel>>
```
Calls `GET /reports/map` with the current viewport. Refresh when bounds change.

### Pin tap → Bottom Sheet (not push)
When a report pin is tapped, show a bottom sheet preview. Do NOT push to a new page directly.

**Bottom sheet contents:**
- Report type badge (icon + label, colored per `ReportType`)
- Address
- Description (2 lines, truncated)
- Time ago (derived from `createdAt`)
- Vote summary: confirm count + resolve count (two small chips)
- "Lihat Detail →" button → pushes to Report Detail Page

**Dismiss:** swipe down or tap map backdrop.

### Marker layering fix
Split into two `MarkerLayer`s — report pins in layer 1, user dot in layer 2 — so the user dot is always rendered on top regardless of coordinate overlap.

### Filter chips on map
Existing filter chips should pass `reportType` as a comma-separated query param to `GET /reports/map`.

---

## Page 1 — Report List Page

**Route:** tab 2 in `MainScreen`
**Endpoint:** `GET /reports/user/me`
**Purpose:** Shows all reports ever submitted by the logged-in user, newest first. Includes expired reports.

### AppBar
- Title: "My Reports" (centered, primary color)
- No leading icon, no trailing icon

### Filter
- Horizontal scrollable pill chips below AppBar
- Options: All, Accident, Police, Hazard, Crime, Flood, Pothole, Closure, Construction, Traffic Light, Other
- Each chip uses `ReportType.color` as its active background
- Filtering is client-side (filter already-loaded list) since the endpoint supports `reportType` as a query param — use query param filtering for cleanliness
- Active chip: colored fill + white text. Inactive: white fill + border

### Report Card (reusable `ReportCard` widget)
```
┌──────────────────────────────────────────────┐
│ [Icon 48x48  ]  [Type badge]       time ago  │
│ [colored bg  ]  Address line 1               │
│               Description truncated 2 lines  │
│                              [Confirm ✓] [Resolve ✓] │
└──────────────────────────────────────────────┘
```
- Icon area: `ReportType.color` background circle with `ReportType.icon`
- Type badge: pill with type label + type color (same as existing status badge pattern)
- Vote chips: small read-only chips showing confirm + resolve counts
- Tapping card → pushes to Report Detail Page
- No swipe-to-delete (user can delete from detail page)

### States
- **Loading:** skeleton list (5 cards)
- **Empty:** illustration + "You haven't made any reports yet." + "Make a Report" button → navigates to Create Report
- **Error:** error message + retry button
- **Pull to refresh:** RefreshIndicator, re-calls `GET /reports/user/me`

### Pagination
The endpoint uses cursor-based pagination (`cursor` + `limit`).
Implement infinite scroll: load next page when user scrolls near the bottom, append to existing list. Show a small loading spinner at the bottom while fetching more.

---

## Page 2 — Report Detail Page

**Route:** pushed from Map bottom sheet or Report List card
**Endpoint:** `GET /reports/:id`
**Purpose:** Full report view with votes and comment thread.

### AppBar
- Back arrow (pop)
- Title: report type label (e.g. "Pothole")
- Trailing: share icon (optional, lower priority)

### Hero Section
- Full-width image if attachment exists (16:9, tappable to fullscreen)
- Placeholder if no attachment: colored banner using `ReportType.color` with centered icon

### Report Info Section
- Report type badge (icon + label + color)
- Address (bold)
- Description (full text, not truncated)
- Posted by: "Reported X ago" (derived from `createdAt`)
- Expiry notice if close to `expiresAt`: "Expires in 2h" in amber

### Vote Section
Two buttons side by side:
- **Confirm** — "Still happening" — thumbs up icon — shows confirm count
  - Active state: primary green fill
  - Calls `POST /reports/:reportId/confirm`
- **Resolve** — "Fixed now" — check icon — shows resolve count
  - Active state: success green fill
  - Calls `POST /reports/:reportId/resolve`
- `userVoted` from API response determines which button (if any) is active
- If user already voted within 24h: show `422` snackbar "You already voted recently"
- Both buttons disabled if user is the report author

### Comment Section
**Header:** "Comments (N)" where N = `commentCount`

**Comment item:**
```
[Avatar initial]  UserName · time ago
                  Comment text
                  [Edit] (only if userId matches current user)
```
- Avatar: colored circle with first initial
- Edit taps inline edit mode (text field replaces comment text, Save/Cancel buttons)
- Delete: long-press → confirmation dialog → `DELETE /reports/:reportId/comments/:commentId`
- Load more: cursor pagination, "Load more comments" button at bottom of list

**Comment Input (pinned to bottom):**
- Text field: "Add a comment..." placeholder
- Send button (green, disabled when empty)
- Calls `POST /reports/:reportId/comments`
- On success: append new comment to top of list, clear input

### Riverpod providers needed
```
reportDetailProvider(String id) → AsyncValue<ReportDetail>
commentsProvider(String reportId) → AsyncValue<CommentPage>
```

---

## Page 3 — Create Report Page (Review)

Already exists. Ensure it handles:

- **Report type selector:** grid or horizontal scroll of `ReportType` options, each showing icon + label + color. Required field.
- **Description:** text area, max 256 chars, show character counter
- **Location:** auto-filled from `currentPositionProvider` + `addressFromPositionProvider`. Address and zip code editable. Show map preview with draggable pin (optional, nice to have).
- **Photo attachment:** optional. On select, get file size + MIME type, pass to `POST /reports` body as `attachment: { mimeType, fileSize }`. On 201, use returned `uploadUrl` to PUT the file bytes directly to S3 via `ReportService.uploadAttachment`.
- **Submit flow:**
  1. `POST /reports` → get report + uploadUrl
  2. If photo selected → `PUT uploadUrl` with file bytes
  3. On success → pop back to map, show success snackbar

---

## Shared Widgets

These should live in `lib/shared/widgets/`:

| Widget | Used in |
|---|---|
| `ReportCard` | Report List Page |
| `ReportTypeBadge` | Report Card, Report Detail, Map bottom sheet |
| `VoteChip` | Report Card (read-only), Report Detail (interactive) |
| `CommentItem` | Report Detail |
| `CommentInput` | Report Detail |

---

## Riverpod Provider Summary

| Provider | Type | Endpoint |
|---|---|---|
| `userProfileProvider` | `FutureProvider` | `GET /auth/me` |
| `currentPositionProvider` | `FutureProvider<LatLng?>` | device GPS |
| `addressFromPositionProvider` | `FutureProvider.family<AddressResult?, LatLng>` | geocoding |
| `mapPinsProvider(bounds)` | `FutureProvider.family` | `GET /reports/map` |
| `myReportsProvider(filter)` | `StateNotifierProvider` | `GET /reports/user/me` |
| `reportDetailProvider(id)` | `FutureProvider.family` | `GET /reports/:id` |
| `commentsProvider(reportId)` | `StateNotifierProvider.family` | `GET /reports/:reportId/comments` |

---

## API Notes

- `GET /reports/map` returns only `id`, `reportType`, `lat`, `lng` — lightweight for map rendering. Fetch full detail only on pin tap via `GET /reports/:id`.
- Cursor pagination used on: Report List, Comments. Always pass `limit=20`. Store `nextCursor` in provider state; pass it on next fetch.
- Vote endpoints return `422` when voted within 24h — handle with a snackbar, not an error screen.
- `PUT /reports/:id` requires user to be within 100m of report — only show Edit option if distance check passes client-side first.
- Attachment upload is two-step: POST report → get `uploadUrl` → PUT bytes to S3. If S3 upload fails, the report still exists but has no attachment.