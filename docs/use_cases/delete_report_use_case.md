# Delete Report Use Case

Only the OP (original poster) can delete their report.

## Flow

1. OP navigates to their report
2. OP deletes the report
3. Report and its associated votes, comments, and attachments are removed

## Endpoints

### DELETE `/reports/:reportId`

**REQUIRES AUTHENTICATED USER**

User must be the `reportedBy` user.

#### Response

`204 No Content`

```json
{}
```

#### Failure Responses

| Status | Condition |
|--------|-----------|
| `401` | Missing or invalid authentication |
| `403` | Authenticated user is not the OP |
| `404` | Report not found |
