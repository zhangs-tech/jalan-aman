# Submit Report Use Case

User ("original poster"/OP) submits a report.

It should contain general description and current location.

Image is optional.

## Flow

1. User sees a problem
2. User submits a report
3. Report is saved and visible to other users

## Endpoints

### POST `/reports`

Creates a new report.

**REQUIRES AUTHENTICATED USER**

#### Request Body

Valid `reportType` values:

| Type | TTL |
|------|-----|
| `accident` | 2h |
| `police` | 2h |
| `hazard` | 2h |
| `crime` | 2h |
| `flood` | 12h |
| `pothole` | 12h |
| `closure` | 24h |
| `construction` | 24h |
| `broken_traffic_light` | 24h |
| `other` | 6h |

```json
{
    "reportType": "accident",
    "description": "description", // max 256 chars
    "latitude": 40.205, // float number
    "longitude": 21.443,
    "address": "address", // max 256 chars
    "zipcode": "51030", // optional
    "attachment": true
}
```

```mermaid
classDiagram
    class ReportSubmitDTO {
        +string reportType
        +string description
        +float latitude
        +float longitude
        +string address
        +string? zipcode
        +bool attachment
    }
```

#### Response

```json
{
    "report": {
        "id": "uuid",
        "reportType": "accident",
        "description": "description",
        "createdAt": "2026-05-23T10:00:00Z",
        "updatedAt": "2026-05-23T10:00:00Z",
        "expiresAt": "2026-05-23T12:00:00Z",
        "reportedBy": "uuid",
        "latitude": 40.205,
        "longitude": 21.443,
        "address": "address",
        "zipcode": "51030"
    },
    "attachment": { // only if "attachment": true
        "id": "uuid",
        "uploadUrl": "s3 pre-signed url",
        "s3Key": "reports/uuid/image.jpg",
        "createdAt": "2026-05-23T10:00:00Z"
    }
}
```

```mermaid
classDiagram
    class ReportSubmitResponse {
        +ReportDTO report
        +AttachmentUploadDTO? attachment
    }
    class ReportDTO {
        +string id
        +string reportType
        +string description
        +datetime createdAt
        +datetime updatedAt
        +datetime expiresAt
        +string reportedBy
        +float latitude
        +float longitude
        +string address
        +string? zipcode
    }
    class AttachmentUploadDTO {
        +string id
        +string uploadUrl
        +string s3Key
        +datetime createdAt
    }
```

#### Failure Responses

| Status | Condition |
|--------|-----------|
| `400` | Missing required fields or invalid values |
| `401` | Missing or invalid authentication |
| `422` | Unrecognized `reportType` |
