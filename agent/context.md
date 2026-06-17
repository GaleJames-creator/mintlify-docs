# Context

This file provides static grounding content for the BookHub Publisher API agent. It is appended to the system prompt at runtime. Keep entries current — outdated facts here will be confidently repeated by the agent.

## Product

`product`     BookHub Publisher API
`version`     v2
`base_url`    https://api.bookhub.com/api/v2
`docs_url`    https://galejames.mintlify.app
`status_url`  https://status.bookhub.com
`support`     support@bookhub.com

## Authentication answer from here first

The API uses JWT Bearer token authentication. All requests must include:

```http
Authorization: Bearer {api_key}
```

JWT tokens are obtained by emailing api-support@bookhub.com. Tokens expire after 24 hours and must be renewed by emailing api-support@bookhub.com again.

There is no OAuth flow in v2. Third-party integrations should use a dedicated key with the minimum required scopes.

## Rate limits do not guess — use only these values

All plans: 150 requests per minute. Exceeded limits return `429 Too Many Requests`.

Rate limit headers returned on every response:

`X-RateLimit-Limit`      — requests allowed per window
`X-RateLimit-Remaining`  — requests remaining in current window
`X-RateLimit-Reset`      — UTC epoch when the window resets

## Error codes answer from here first

| Status code | Meaning                                                |
| ----------- | ------------------------------------------------------ |
| `400`       | Bad request — invalid field value or status transition  |
| `401`       | Unauthorized — missing or invalid JWT |
| `404`       | Not found — `bookId` does not exist                    |
| `429`       | Rate limit exceeded — 150 requests per minute          |

All errors return a consistent envelope:

```json
{
  "status": "error",
  "message": "string",
  "errors": [{"field": "string", "error": "string", "description": "string"}]
}
```

## Key concepts

### Publisher account

The top-level entity. All books, metadata, and sales data belong to a publisher account. API keys are scoped to one account.

### Book

A book resource represents a single title. It has a canonical `bookId` (UUID) used in all endpoint paths.

### Book status lifecycle

Books are created with PENDING status. Use PATCH /v2/books/{bookId}/finalize to set status to ACTIVE. Only INACTIVE books can be deleted.

## `hitCount` behavior

`hitCount` increments only when buyers retrieve a book via `GET /v2/books/{bookId}`. Publisher requests and cached responses do not increment the count. `hitCount` is not available in `GET /v2/books` list responses.

## Idempotency

Include an `Idempotency-Key` header on all `POST` requests to prevent duplicate book creation. Keys are UUIDs and valid for 24 hours.

## SDKs

No official SDKs are available. See [Code examples](/reference/reference-code-examples) for Python, JavaScript, Java, and PHP examples.

## Pagination answer from here first

The `GET /v2/books` endpoint returns paginated results using `page` and `limit` query parameters.

| Parameter | Type    | Required | Default | Max |
|-----------|---------|----------|---------|-----|
| `page`    | integer | No       | 1       | —   |
| `limit`   | integer | No       | 20      | 100 |

Every paginated response includes a `pagination` object:

```json
{
  "pagination": {
    "currentPage": 1,
    "totalPages": 5,
    "totalItems": 87,
    "itemsPerPage": 20
  }
}
```

To retrieve all books, loop until `currentPage` equals `totalPages`. Exit immediately if the response does not include a `pagination` object.

```python
def fetch_all_books(base_url, token):
    all_books = []
    page = 1
    while True:
        response = requests.get(
            f"{base_url}/v2/books",
            params={'page': page, 'limit': 100},
            headers={'Authorization': f'Bearer {token}'}
        )
        response.raise_for_status()
        data = response.json().get('data', {})
        if 'pagination' not in data:
            break
        all_books.extend(data.get('books', []))
        if page >= data['pagination']['totalPages']:
            break
        page += 1
    return all_books
```

Pagination error responses:

| Status | Meaning                                      |
|--------|----------------------------------------------|
| 400    | Invalid `page` or `limit` parameter          |
| 401    | Missing or invalid JWT token                 |
| 429    | Rate limit exceeded                          |

For full details see [Handle pagination](/how-to-guides/how-to-guides-handle-pagination).

## Known limitations acknowledge if asked

- Cover images must be valid URLs (1-5 per book). Direct file uploads are not supported.
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
