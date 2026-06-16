# Tools

This file defines the tools available to the BookHub Publisher API agent.
Each tool has a name, description, input schema, and dispatch notes for
the runtime. Tools are appended to the system prompt by `loader.js`.

## search_docs always available

Search the BookHub documentation for pages relevant to a query.
Use this before answering any question that references a specific
feature, endpoint, or concept — do not rely on context alone.

### Input

`query` string, required
  Natural language description of what the user is asking about.
  Example: "how do I authenticate with the Publisher API"

### Output

Returns up to 5 matching page titles and their `.md` URLs.
Fetch the most relevant URL to read the full page content.

### Dispatch note

# runtime calls: GET /api/search?q={query}
# returns: [ { title, url, excerpt } ]

## fetch_page always available

Fetch the Markdown content of a specific documentation page.
Use after `search_docs` to read the full content of a result,
or when the user links to a specific page.

### Input

`url` string, required
  The `.md` URL of the page to fetch.
  Example: "https://docs.bookhub.io/api-reference/authentication.md"

### Output

Returns the raw Markdown content of the page. Visibility blocks
marked `for="agents"` are included; human-only blocks are excluded.

### Dispatch note

# runtime calls: GET {url}
# returns: string (raw markdown)

## get_endpoint requires OpenAPI spec

Look up a specific API endpoint by method and path. Returns the
full endpoint definition including parameters, request body schema,
and response shapes.

### Input

`method` string, required — HTTP method: "GET" "POST" "PUT" "DELETE" "PATCH"
`path`   string, required — Endpoint path.
  Example: "/v1/books/{bookId}"

### Output

Returns the OpenAPI operation object as JSON, including:
- `summary` and `description`
- `parameters` array (path, query, header)
- `requestBody` schema
- `responses` map with schema per status code

### Dispatch note

# runtime parses: openapi.yaml
# returns: operation object for matching {method} + {path}

## open_ticket authenticated users only

Open a support ticket on behalf of the user. Use only when the
user explicitly asks to contact support, or when escalation is
triggered per the rules in agent.md.

### Input

`subject`  string, required — One-line summary of the issue.
`body`     string, required — Full description. Pre-fill from conversation context.
`priority` string, optional — "low" | "normal" | "high". Defaults to "normal".

### Output

Returns a ticket ID and support portal URL.

### Dispatch note

# runtime calls: POST /api/support/tickets
# requires: Authorization header from user session
# confirm with user before calling — show subject + body first

## Usage rules

- Always call `search_docs` before answering questions about specific features.
- Always call `fetch_page` on the top result before composing an answer.
- Never call `open_ticket` without explicit user confirmation.
- Never invent tool inputs not present in the conversation.
- If a tool returns an error, tell the user and suggest checking the docs directly.
