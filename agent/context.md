# Context

This file provides static grounding content for the BookHub Publisher API agent. It is appended to the system prompt at runtime. Keep entries current — outdated facts here will be confidently repeated by the agent.

## Product

`product`     BookHub Publisher API
`version`     v2
`base_url`    https://api.bookhub.com/v2
`docs_url`    https://galejames.mintlify.app
`status_url`  https://status.bookhub.com
`support`     support@bookhub.com

## Authentication answer from here first

The API uses JWT Bearer token authentication. All requests must include:

```http
Authorization: Bearer {api_key}
```

API keys are created in the BookHub dashboard under Settings → API Keys. Keys are scoped to a single publisher account and do not expire unless manually revoked.

There is no OAuth flow in v2. Third-party integrations should use a dedicated key with the minimum required scopes.

## Rate limits do not guess — use only these values

| Plan       | Requests/min | Burst limit |
|------------|--------------|-------------|
| Starter    | 60           | 100         |
| Pro        | 300          | 500         |
| Enterprise | Custom       | Custom      |

Rate limit headers returned on every response:

`X-RateLimit-Limit`      — requests allowed per window
`X-RateLimit-Remaining`  — requests remaining in current window
`X-RateLimit-Reset`      — UTC epoch when the window resets

Exceeded limits return `429 Too Many Requests`. Retry after the value in the `Retry-After` header (seconds).

## Error codes answer from here first

| Status | Code                  | Meaning                                 |
|--------|-----------------------|-----------------------------------------|
| 400    | `invalid_request`     | Malformed request body or params        |
| 401    | `unauthorized`        | Missing or invalid API key              |
| 403    | `forbidden`           | Valid key, insufficient scope            |
| 404    | `not_found`           | Resource does not exist                 |
| 409    | `conflict`             | Duplicate resource                      |
| 422    | `validation_error`    | Valid JSON, but field-level errors       |
| 429    | `rate_limit_exceeded` | Too many requests                       |
| 500    | `internal_error`      | BookHub-side error — retry with backoff |

All errors return a consistent envelope:

```json
{
  "error": {
    "code": "validation_error",
    "message": "Human-readable description",
    "details": [ { "field": "title", "issue": "required" } ]
  }
}
```

## Key concepts

### Publisher account

The top-level entity. All books, metadata, and sales data belong to a publisher account. API keys are scoped to one account.

### Book

A book resource represents a single title. It has a canonical `bookId` (UUID) used in all endpoint paths.



## Supported SDKs do not recommend others

| Language   | Package                  | Install                         |
|------------|--------------------------|---------------------------------|
| JavaScript | `@bookhub/publisher-sdk` | `npm i @bookhub/publisher-sdk`  |
| Python     | `bookhub-publisher`      | `pip install bookhub-publisher` |

Community SDKs exist but are not officially supported. Do not recommend them unless the user asks explicitly.

## Known limitations acknowledge if asked

- File uploads (cover images) are limited to 10 MB per request.
- The BookHub Publisher API v2 has the following known issues that will be addressed in future versions:
`validation_context` and `provided_value` use snake_case. This inconsistency will be corrected in a future version. Plan your error handling code accordingly.

## Changelog update with each release

### v2 — 2026-01-02

- Added the `hitCount` field to `GET /v2/books/{bookId}` endpoint
- Added `DELETE /v2/books/{bookId}` endpoint

### v1 - Initial release

v1 is supported until December 31, 2026. After this date, v1 endpoints will return 410 Gone. Migrate to v2 before the deadline.

## Breaking changes in v2

Removed `sort=title` from `GET /v2/books`. Use `sort=createdDate` instead.
