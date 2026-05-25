# Jalan Aman — Frontend Progress & TODO

Last updated: 2026-05-25

## Phase 0: Sync with Backend ✅ (complete)
- [x] Created `lib/models/report_type.dart` — `ReportType` enum with all 10 backend types (value, label, color, icon, TTL)
- [x] Removed fake status colors (`Pending`/`In Progress`/`Resolved`/`Rejected`) from `app_colors.dart`
- [x] Updated `map_page.dart` — pins now color-coded by `ReportType`, dummy data uses `reportType`
- [x] Updated `report_page.dart` — filters now use real report types, badges show type label/color, dummy data uses `reportType`
- [x] Deleted `temp.dart` (stale duplicate of `map_page.dart`)

## Phase 1: Create Report ✅ (complete)
- [x] Created `lib/services/report_service.dart` — `POST /reports` API call + pre-signed URL photo upload
- [x] Created `lib/providers/location_providers.dart` — `currentPositionProvider` + `addressFromPositionProvider`
- [x] Created `lib/pages/create_report_page.dart` — form with:
  - Report type grid (10 types, colored icons)
  - Description field with 256-char counter
  - **Photo** — camera/gallery picker with preview and two-step pre-signed URL upload flow
  - **Mini map picker** — tappable FlutterMap to reposition the pin, triggers reverse geocoding on tap
  - Editable address + zip code fields with geolocation refresh button
- [x] Wired `map_page.dart` FAB to navigate to `CreateReportPage`
- [x] Location permission fallback UI with retry button

### Phase 1 remaining:
- [ ] Wire report list (`report_page.dart`) to `GET /reports/user/me` API
- [ ] Wire map pins (`map_page.dart`) to `GET /reports/map` API
- [ ] Report detail page (`GET /reports/:id`)
- [ ] Photo upload (pre-signed URL flow)

---

## 🔨 TODO — Prioritized

### Phase 1: Wire Reports to Backend
The backend has **10 report endpoints** fully implemented. The frontend currently uses hardcoded Jakarta data.

- [x] **Create report page** (`POST /reports`)
  - Form fields: reportType (10 types), description, photo (camera/gallery → pre-signed upload), address (reverse-geocoded from current location), zipCode
  - Wired `address_service.dart` into the form
  - Mini map picker for movable location pin
- [ ] **Replace dummy data** in `report_page.dart` with `GET /reports/user/me` (auth required)
  - Cursor pagination
  - Wire status filters to `reportType` query param
- [ ] **Replace dummy pins** in `map_page.dart` with `GET /reports/map` (bounding box)
  - Load pins as the map moves (listen to map bounds changes)
  - Optional `reportType` filter
- [ ] **Report detail page** (`GET /reports/:id`)
  - Show full report info, attachments, vote summary, comments
  - Photo view via pre-signed download URL
  - Vote buttons (confirm/resolve): `POST /reports/:reportId/confirm`, `POST /reports/:reportId/resolve`
  - Edit button (proximity check → `PUT /reports/:id`)
  - Soft-delete button (`DELETE /reports/:id`)

### Phase 2: Comments
Backend has 4 comment endpoints ready.

- [ ] **Comment list** — `GET /reports/:reportId/comments` (cursor pagination)
- [ ] **Add comment** — `POST /reports/:reportId/comments`
- [ ] **Edit comment** — `PATCH /reports/:reportId/comments/:commentId` (own comments only)
- [ ] **Delete comment** — `DELETE /reports/:reportId/comments/:commentId`

### Phase 3: Navigation & Polish
- [ ] **Declarative routing** — migrate from imperative `Navigator` to `go_router`
  - Named routes: `/`, `/login`, `/register`, `/home`, `/reports/new`, `/reports/:id`
- [ ] **Delete `temp.dart`** — stale duplicate of `map_page.dart`, has class name conflict

### Phase 4: Backend Features Not Yet in Frontend
Features the backend supports but the frontend doesn't consume:

- [x] **Photo upload flow** — get pre-signed upload URL from `POST /reports`, upload to S3/SeaweedFS directly
- [ ] **Photo download** — `GET /reports/:reportId/attachments/:attachmentId/download` → pre-signed download URL
- [ ] **Edit report** — `PUT /reports/:id` (requires proximity check: user must be ≤100m from report)
- [ ] **Soft-delete report** — `DELETE /reports/:id` (own reports only)
- [ ] **Voting system** — confirm/resolve votes that adjust report TTL
- [ ] **Public report list** — `GET /reports` (cursor pagination, filters) for a discover/browse tab
- [ ] **Map pin filters** — `GET /reports/map` with `reportType` query param

### Phase 5: Polish & Gaps (Backend)
Features the backend doesn't have yet:

- [ ] Refresh tokens (JWT expires in 1h with no refresh mechanism)
- [ ] Role-based access control (admin/moderator)
- [ ] Password reset flow
- [ ] Email verification
- [ ] User profile editing (`PATCH /auth/me`)
- [ ] Push notifications

### Phase 6: Testing
- [ ] Widget tests for auth pages (login, register)
- [ ] Widget tests for report list (loading, empty, filtered states)
- [ ] Unit tests for `AuthNotifier`, `userProfileProvider`
- [ ] Integration tests for auth flow (register → login → home → logout)

---

## 📊 Backend API Coverage

| Backend Endpoint | Frontend Status |
|---|---|
| `POST /auth/register` | Done |
| `POST /auth/login` | Done |
| `GET /auth/me` | Done (used in `AuthNotifier._checkAuth()`) |
| `POST /auth/logout` | Done (client-side clear) |
| `POST /reports` | Done |
| `GET /reports` | TODO (public list) |
| `GET /reports/map` | TODO |
| `GET /reports/user/me` | TODO |
| `GET /reports/:id` | TODO |
| `PUT /reports/:id` | TODO |
| `DELETE /reports/:id` | TODO |
| `GET /reports/:id/attachments/:id/download` | TODO |
| `POST /reports/:id/confirm` | TODO |
| `POST /reports/:id/resolve` | TODO |
| `POST /reports/:id/comments` | TODO |
| `GET /reports/:id/comments` | TODO |
| `PATCH /reports/:id/comments/:id` | TODO |
| `DELETE /reports/:id/comments/:id` | TODO |

**5 of 19 backend endpoints are consumed by the frontend (26%).**

---

## 🗂 File Structure (Current)

```
lib/
├── main.dart                    # ProviderScope + MyApp + _AuthGate
├── providers/
│   ├── auth_providers.dart      # AuthNotifier + authStateProvider
│   └── profile_providers.dart   # userProfileProvider
├── models/
│   └── report_type.dart         # ReportType enum (10 backend types)
├── pages/
│   ├── landing_page.dart        # Register / Login buttons
│   ├── login_page.dart          # Email/password login
│   ├── register_page.dart       # Registration with password criteria
│   ├── home_page.dart           # IndexedStack with 3 tabs
│   ├── map_page.dart            # flutter_map with pins + greeting
│   ├── report_page.dart         # Report list with filters (dummy data)
│   ├── create_report_page.dart  # New report form
│   └── profile_page.dart        # Profile display + logout
├── services/
│   ├── api/
│   │   ├── api_client.dart      # HTTP client (static)
│   │   └── auth_service.dart    # Auth API calls (static)
│   ├── location_service.dart    # GPS + permissions
│   ├── address_service.dart     # Geocoding
│   └── secure_storage.dart      # Token persistence
│   └── report_service.dart      # Report CRUD API calls
├── components/
│   ├── app_icon.dart
│   ├── buttons.dart
│   ├── card.dart
│   ├── text_field.dart
│   └── outline_button.dart
├── theme/
│   ├── theme.dart               # Barrel export
│   ├── app_colors.dart
│   ├── app_dimensions.dart
│   ├── app_text_styles.dart
│   └── app_theme.dart
└── utils/
    └── form_validator.dart
```
