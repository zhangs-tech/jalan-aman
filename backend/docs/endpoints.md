# Jalan Aman API — Endpoints Reference

Base URL: `http://localhost:3000`
Auth: JWT Bearer token (`Authorization: Bearer <token>`)

---

## Auth

### `POST /auth/register`

Creates a new user account.

| | |
|---|---|
| **Auth** | No |
| **Status** | `201 Created` |

**Request Body**
```json
{
  "name":     "string (required)",
  "email":    "string email (required)",
  "phone":    "string (required)",
  "password": "string (required, min 8, 1 uppercase, 1 lowercase, 1 digit)"
}
```

**Response 201**
```json
{
  "message": "Registration successful",
  "user":    { "id": "uuid", "email": "string", "name": "string", "phone": "string", "role": "user" }
}
```
**Errors:** `400` (validation), `409` (email already registered)

---

### `POST /auth/login`

Authenticates and returns a JWT token.

| | |
|---|---|
| **Auth** | No |
| **Status** | `200 OK` |

**Request Body**
```json
{
  "email":    "string (required)",
  "password": "string (required)"
}
```

**Response 200**
```json
{
  "message":     "Login successful",
  "accessToken": "string (JWT)",
  "user":        { "id": "uuid", "email": "string", "name": "string", "phone": "string", "role": "user" }
}
```
**Errors:** `400` (validation), `401` (invalid credentials)

---

### `GET /auth/me`

Returns the current authenticated user's profile.

| | |
|---|---|
| **Auth** | Bearer token |
| **Status** | `200 OK` |

**Request Body** — none

**Response 200**
```json
{
  "user": { "id": "uuid", "email": "string", "name": "string", "phone": "string", "role": "user" }
}
```
**Errors:** `401` (missing/invalid token)

---

### `POST /auth/logout`

Signs out the current user (client-side token discard).

| | |
|---|---|
| **Auth** | Bearer token |
| **Status** | `200 OK` |

**Request Body** — none

**Response 200**
```json
{
  "message": "Logout successful"
}
```

---

## Reports

### `POST /reports`

Creates a new report. Optionally attach a file via pre-signed S3 upload URL.

| | |
|---|---|
| **Auth** | Bearer token |
| **Status** | `201 Created` |

**Request Body**
```json
{
  "reportType":  "accident | police | hazard | crime | flood | pothole | closure | construction | broken_traffic_light | other (required)",
  "description": "string (required, max 256)",
  "latitude":    "float (required, -90..90)",
  "longitude":   "float (required, -180..180)",
  "address":     "string (required, max 256)",
  "zipCode":     "string (optional)",
  "attachment":  { "mimeType": "string", "fileSize": "integer" } (optional)
}
```

**Response 201**
```json
{
  "report": {
    "id": "uuid", "reportType": "string", "description": "string",
    "createdAt": "datetime", "updatedAt": "datetime", "expiresAt": "datetime",
    "reportedBy": "uuid", "latitude": 0.0, "longitude": 0.0,
    "address": "string", "zipCode": "string|null"
  },
  "attachment": { "id": "uuid", "uploadUrl": "url", "s3Key": "string", "mimeType": "string", "fileSize": 0, "createdAt": "datetime" } | null
}
```
**Errors:** `400` (validation), `401` (unauthorized)

---

### `GET /reports`

Cursor-paginated feed of active reports (public, with optional auth).

| | |
|---|---|
| **Auth** | Optional (populates `userVoted` if provided) |
| **Status** | `200 OK` |

**Query Parameters**
| Param | Type | Default | Description |
|---|---|---|---|
| `cursor` | string | — | Opaque cursor for next page |
| `limit` | int 1–50 | `20` | Page size |
| `reportType` | string | — | Comma-separated filter: `accident,flood` |
| `sort` | `createdAt` \| `expiresAt` | `createdAt` | Sort field |
| `order` | `asc` \| `desc` | `desc` | Sort direction |

**Response 200**
```json
{
  "reports": [
    {
      "id": "uuid", "reportType": "string", "description": "string",
      "createdAt": "datetime", "updatedAt": "datetime", "expiresAt": "datetime",
      "reportedBy": "uuid", "latitude": 0.0, "longitude": 0.0,
      "address": "string", "zipCode": "string|null",
      "voteSummary": { "confirms": 0, "resolves": 0, "userVoted": "confirm|resolve|null" }
    }
  ],
  "nextCursor": "string|null"
}
```
**Errors:** `400` (invalid params)

---

### `GET /reports/map`

Lightweight pin data for map rendering (public, no auth). Limited to 500 pins.

| | |
|---|---|
| **Auth** | No |
| **Status** | `200 OK` |

**Query Parameters** (all required except `reportType`)
| Param | Type | Description |
|---|---|---|
| `swLat` | float -90..90 | South-west latitude |
| `swLng` | float -180..180 | South-west longitude |
| `neLat` | float -90..90 | North-east latitude |
| `neLng` | float -180..180 | North-east longitude |
| `reportType` | string | Comma-separated filter (optional) |

**Response 200**
```json
{
  "pins": [
    { "id": "uuid", "reportType": "string", "latitude": 0.0, "longitude": 0.0 }
  ]
}
```
**Errors:** `400` (missing/invalid geo params)

---

### `GET /reports/user/me`

Reports created by the authenticated user (newest first). Includes expired reports but excludes soft-deleted ones.

| | |
|---|---|
| **Auth** | Bearer token |
| **Status** | `200 OK` |

**Query Parameters**
| Param | Type | Default | Description |
|---|---|---|---|
| `cursor` | string | — | Opaque cursor |
| `limit` | int 1–50 | `20` | Page size |
| `reportType` | string | — | Comma-separated filter |

**Response 200** — same shape as `GET /reports` response.

**Errors:** `400` (invalid filter), `401` (unauthorized)

---

### `GET /reports/:id`

Full detail including attachments, vote summary, and comment count.

| | |
|---|---|
| **Auth** | Optional (populates `userVoted`) |
| **Status** | `200 OK` |

**Request Body** — none

**Response 200**
```json
{
  "report": {
    "id": "uuid", "reportType": "string", "description": "string",
    "createdAt": "datetime", "updatedAt": "datetime", "expiresAt": "datetime",
    "reportedBy": "uuid", "latitude": 0.0, "longitude": 0.0,
    "address": "string", "zipCode": "string|null",
    "commentCount": 0,
    "voteSummary": { "confirms": 0, "resolves": 0, "userVoted": "confirm|resolve|null" },
    "attachments": [
      { "id": "uuid", "s3Key": "string", "mimeType": "string", "fileSize": 0, "createdAt": "datetime" }
    ]
  }
}
```
**Errors:** `404` (not found or soft-deleted)

---

### `PUT /reports/:id`

Edit a report. Only the original poster can edit. Must be within 100 m of the report location (Haversine check).

| | |
|---|---|
| **Auth** | Bearer token |
| **Status** | `200 OK` |

**Request Body**
```json
{
  "description": "string (required, max 256)",
  "address":     "string (required, max 256)",
  "userLat":     "float (required, -90..90) — user's current latitude",
  "userLng":     "float (required, -180..180) — user's current longitude"
}
```

**Response 200**
```json
{
  "report": { /* ReportDTO */ }
}
```
**Errors:** `400` (validation), `401` (unauthorized), `403` (not OP or too far), `404` (not found)

---

### `DELETE /reports/:id`

Soft-deletes a report. Only the original poster can delete.

| | |
|---|---|
| **Auth** | Bearer token |
| **Status** | `200 OK` |

**Request Body** — none

**Response 200**
```json
{
  "message": "Report deleted"
}
```
**Errors:** `401` (unauthorized), `403` (not OP), `404` (not found)

---

### `GET /reports/:reportId/attachments/:attachmentId/download`

Returns a pre-signed S3 download URL (valid 5 min).

| | |
|---|---|
| **Auth** | No |
| **Status** | `200 OK` |

**Request Body** — none

**Response 200**
```json
{
  "downloadUrl": "https://s3-presigned-url..."
}
```
**Errors:** `404` (report/attachment not found)

---

### `POST /reports/:reportId/confirm`

Cast a "confirm" vote. Rate-limited: 1 vote per user per report per 24 h.

| | |
|---|---|
| **Auth** | Bearer token |
| **Status** | `200 OK` |

**Request Body** — none

**Response 200**
```json
{
  "vote":   { "id": "uuid", "reportId": "uuid", "userId": "uuid", "type": "confirm", "createdAt": "datetime" },
  "report": { /* ReportDTO */ }
}
```
**Errors:** `401` (unauthorized), `404` (not found), `422` (already voted within 24 h)

---

### `POST /reports/:reportId/resolve`

Cast a "resolve" vote. Rate-limited: 1 vote per user per report per 24 h.

| | |
|---|---|
| **Auth** | Bearer token |
| **Status** | `200 OK` |

**Request Body** — none

**Response 200**
```json
{
  "vote":   { "id": "uuid", "reportId": "uuid", "userId": "uuid", "type": "resolve", "createdAt": "datetime" },
  "report": { /* ReportDTO */ }
}
```
**Errors:** `401` (unauthorized), `404` (not found), `422` (already voted within 24 h)

---

## Comments

All comment endpoints are mounted under `/reports/:reportId/comments`.

### `POST /reports/:reportId/comments`

Add a comment to a report.

| | |
|---|---|
| **Auth** | Bearer token |
| **Status** | `201 Created` |

**Request Body**
```json
{
  "details": "string (required, min 1, max 1024)"
}
```

**Response 201**
```json
{
  "comment": {
    "id": "uuid", "reportId": "uuid", "userId": "uuid", "userName": "string",
    "details": "string", "createdAt": "datetime", "updatedAt": "datetime"
  },
  "report": { /* ReportDTO */ }
}
```
**Errors:** `400` (validation), `401` (unauthorized), `404` (report not found)

---

### `GET /reports/:reportId/comments`

Cursor-paginated comments on a report (public).

| | |
|---|---|
| **Auth** | No |
| **Status** | `200 OK` |

**Query Parameters**
| Param | Type | Default | Description |
|---|---|---|---|
| `cursor` | string | — | Opaque cursor |
| `limit` | int 1–100 | `20` | Page size |

**Response 200**
```json
{
  "comments": [
    { "id": "uuid", "reportId": "uuid", "userId": "uuid", "userName": "string",
      "details": "string", "createdAt": "datetime", "updatedAt": "datetime" }
  ],
  "nextCursor": "string|null"
}
```
**Errors:** `400` (invalid limit), `404` (report not found)

---

### `PATCH /reports/:reportId/comments/:commentId`

Update a comment. Only the author can update.

| | |
|---|---|
| **Auth** | Bearer token |
| **Status** | `200 OK` |

**Request Body**
```json
{
  "details": "string (required, min 1, max 1024)"
}
```

**Response 200**
```json
{
  "message": "Comment updated successfully",
  "comment": { /* CommentDTO */ }
}
```
**Errors:** `400` (validation), `401` (unauthorized), `403` (not author), `404` (not found)

---

### `DELETE /reports/:reportId/comments/:commentId`

Delete a comment. Only the author can delete.

| | |
|---|---|
| **Auth** | Bearer token |
| **Status** | `200 OK` |

**Request Body** — none

**Response 200**
```json
{
  "message": "Comment deleted successfully"
}
```
**Errors:** `401` (unauthorized), `403` (not author), `404` (not found)

---

## Error Response Shape

All errors follow:
```json
{
  "message": "Human-readable error message"
}
```

## Report Types

| Type | TTL |
|---|---|
| `accident` | 2 h |
| `police` | 2 h |
| `hazard` | 2 h |
| `crime` | 2 h |
| `flood` | 12 h |
| `pothole` | 12 h |
| `closure` | 24 h |
| `construction` | 24 h |
| `broken_traffic_light` | 24 h |
| `other` | 6 h |

Expired reports are excluded from feeds and map pins (except `GET /reports/user/me` which includes them).
