# Delete Report Use Case

Only the OP (original poster) can soft-delete their report. The report and its associated data are retained in the database but excluded from normal queries (map, history) unless explicitly requested.

## Flow

1. OP navigates to their report
2. OP deletes the report
3. Report's `deletedAt` is set to the current timestamp; the report is excluded from map and history views

## Endpoints

### DELETE `/reports/:reportId`

**REQUIRES AUTHENTICATED USER**

User must be the `reportedBy` user.

#### Response

`200 OK`

```json
{
    "message": "Report deleted"
}
```

#### Failure Responses

| Status | Condition |
|--------|-----------|
| `401` | Missing or invalid authentication |
| `403` | Authenticated user is not the OP |
| `404` | Report not found |
