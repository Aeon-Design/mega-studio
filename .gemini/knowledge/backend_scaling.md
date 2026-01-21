# ⚙️ Backend Scaling Grimoire (Cloud & API)

> **Owner:** Backend Specialist / Database Architect
> **Purpose:** Scalability patterns, database optimization, and security protocols.

## 🏗️ Architecture Patterns

### 1. The "Separation of Concerns" (SoC)
*   **Controller:** Validates input, sends response. No business logic.
*   **Service:** Contains business logic (If/Else, Calculations).
*   **Repository:** Database Access Object (DAO). SQL/NoSQL queries.

### 2. Caching Strategy (The Speed Layer)
*   **L1 (In-Memory):** Redis/Memcached. For session data, user preferences. TTL: 5-15 mins.
*   **L2 (CDN):** Cloudflare/AWS CloudFront. For static assets, public GET responses.
*   **Rule:** "The fastest query is the one you don't make."

## 💾 Database Optimization (SQL/NoSQL)

### 1. Indexing Strategy (The B-Tree)
*   **Rule:** Every column used in `WHERE`, `JOIN`, or `ORDER BY` needs an index.
*   **Composite Indexes:** For queries like `WHERE category = 'A' AND status = 'active'`, create a multi-column index `(category, status)`. Order matters (Cardinality).

### 2. N+1 Problem Prevention
*   **Symptom:** Fetching 100 users, then running 100 queries to get their profiles.
*   **Fix:** Use `JOIN` (SQL) or `$lookup` (Mongo) to fetch in 1 query. Or use Batch Loading (GraphQL).

## 🛡️ Security Protocols (OWASP Top 10)

1.  **Rate Limiting:** Every public API must have a leaky bucket limiter (e.g., 100 req/min).
2.  **Sanitization:** Never trust input. Use Parameterized Queries (Prepared Statements) to kill SQL Injection.
3.  **JWT Handling:** Short-lived Access Token (15m), Long-lived Refresh Token (7d). Store Refresh Token in HTTPOnly Cookie (Web) or Secure Storage (Mobile).

## 🚨 Incident Response
*   **502 Bad Gateway:** Check Nginx/Load Balancer logs. Is the Node node down?
*   **High Latency:** Check Database Slow Query Log. Check CPU usage on worker nodes.
