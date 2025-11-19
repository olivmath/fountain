# 🏗️ Fountain Dashboard Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                          USER BROWSER                                │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │                    Next.js Dashboard                            │ │
│  │                  (http://localhost:3000)                        │ │
│  │                                                                  │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │ │
│  │  │   Overview   │  │ Stablecoins  │  │   Settings   │         │ │
│  │  │     Tab      │  │     Tab      │  │     Tab      │         │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘         │ │
│  │                                                                  │ │
│  │  Real-time Components:                                          │ │
│  │  • PlatformActivity (metrics + chart)                          │ │
│  │  • TransactionsChart (line graph)                              │ │
│  │  • StatusBreakdown (pie chart)                                 │ │
│  │  • OperationsTable (filterable table)                          │ │
│  │  • ClientAnalytics (performance)                               │ │
│  │  • StablecoinsPanel (list + details)                           │ │
│  │                                                                  │ │
│  │  ┌────────────────────────────────────────────────────┐        │ │
│  │  │  useDashboardData() Hook                            │        │ │
│  │  │  • Auto-refresh every 60s                           │        │ │
│  │  │  • Loading/Error states                             │        │ │
│  │  │  • Fetch from /api/dashboard                        │        │ │
│  │  └────────────────────────────────────────────────────┘        │ │
│  └──────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ HTTP GET /api/dashboard
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        Next.js API Route                             │
│                    (app/api/dashboard/route.ts)                      │
│                                                                       │
│  Orchestrates 3 parallel requests:                                  │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │ Promise.all([                                                 │  │
│  │   fetchFromBackend('list-client-stablecoins'),              │  │
│  │   fetchFromBackend('list-client-operations'),               │  │
│  │   fetchFromBackend('get-stablecoin-stats')  // per coin     │  │
│  │ ])                                                            │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                       │
│  Returns aggregated response:                                        │
│  {                                                                    │
│    stablecoins: [...],                                               │
│    operations: [...],                                                │
│    statsByStablecoin: { ... },                                      │
│    fetchedAt: "..."                                                  │
│  }                                                                    │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ HTTPS + x-api-key header
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      Supabase Edge Functions                         │
│        https://bzxdqkttnkxqaecaiekt.supabase.co/functions/v1       │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  list-client-stablecoins                                    │    │
│  │  • Validates API key                                        │    │
│  │  • Queries stablecoins table                                │    │
│  │  • Filters by client_id                                     │    │
│  │  • Returns paginated results                                │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  list-client-operations                                     │    │
│  │  • Validates API key                                        │    │
│  │  • Queries operations table                                 │    │
│  │  • Filters by client_id                                     │    │
│  │  • Joins with stablecoins                                   │    │
│  │  • Returns paginated results                                │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  get-stablecoin-stats                                       │    │
│  │  • Validates API key                                        │    │
│  │  • Aggregates operation data                                │    │
│  │  • Calculates:                                              │    │
│  │    - Total deposits/withdrawals                             │    │
│  │    - Success counts                                         │    │
│  │    - Volume metrics                                         │    │
│  │    - Status breakdown                                       │    │
│  │  • Returns computed stats                                   │    │
│  └────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ SQL Queries
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      PostgreSQL Database                             │
│                         (Supabase)                                   │
│                                                                       │
│  Tables:                                                              │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  stablecoins                                                │    │
│  │  • stablecoin_id (PK)                                       │    │
│  │  • client_id                                                │    │
│  │  • client_name                                              │    │
│  │  • symbol                                                   │    │
│  │  • erc20_address                                            │    │
│  │  • status (registered/deployed)                             │    │
│  │  • created_at, deployed_at                                  │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  operations                                                 │    │
│  │  • operation_id (PK)                                        │    │
│  │  • stablecoin_id (FK)                                       │    │
│  │  • client_id                                                │    │
│  │  • operation_type (deposit/withdraw)                        │    │
│  │  • amount                                                   │    │
│  │  • status (payment_pending, minted, etc.)                   │    │
│  │  • tx_hash, burn_tx_hash                                    │    │
│  │  • created_at, updated_at                                   │    │
│  │  • payment_confirmed_at, minted_at                          │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  api_keys                                                   │    │
│  │  • client_id                                                │    │
│  │  • api_key_hash (SHA-256)                                   │    │
│  │  • is_active                                                │    │
│  │  • last_used_at                                             │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  event_store (audit trail)                                  │    │
│  │  • event_id                                                 │    │
│  │  • aggregate_id                                             │    │
│  │  • event_type                                               │    │
│  │  • payload (JSONB)                                          │    │
│  │  • created_at                                               │    │
│  └────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Data Flow Example

### 1. User Opens Dashboard

```
User → Dashboard Page → useDashboardData() Hook
                             ↓
                        Loading State
                             ↓
                    GET /api/dashboard
```

### 2. API Route Fetches Data

```
API Route → Supabase Functions (parallel):
              ├─ list-client-stablecoins?limit=100
              ├─ list-client-operations?limit=200
              └─ get-stablecoin-stats?stablecoin_id=X (for each coin)
                     ↓
                PostgreSQL
                     ↓
            Returns JSON data
```

### 3. Dashboard Renders

```
Dashboard receives:
{
  stablecoins: [{ id, symbol, status, ... }],
  operations: [{ id, type, amount, status, ... }],
  statsByStablecoin: { "coin-id": { stats: {...} } },
  fetchedAt: "2025-11-19T..."
}
      ↓
Components process and display:
  - PlatformActivity calculates totals
  - TransactionsChart groups by date
  - StatusBreakdown counts statuses
  - OperationsTable shows full list
  - ClientAnalytics aggregates per client
  - StablecoinsPanel displays details
```

### 4. Auto-Refresh (Every 60s)

```
Timer expires → useDashboardData() refetches → Repeats flow
```

---

## Component Tree

```
DashboardPage
├── Sidebar (navigation)
├── Header (title + actions)
└── Main Content
    ├── Overview Tab
    │   ├── OverviewSection (header + timestamp)
    │   ├── PlatformActivity
    │   │   ├── MetricCard (4x)
    │   │   └── TransactionsChart
    │   ├── StatusBreakdown (pie chart)
    │   └── OperationsTable (full table)
    │
    └── Stablecoins Tab
        ├── StablecoinKpis (3 KPI cards)
        ├── ClientAnalytics (NEW!)
        │   ├── Global Metrics (3 cards)
        │   └── Per-Client Cards
        └── StablecoinsPanel
            ├── Stablecoins List (left)
            └── Selected Details (right)
                └── Recent Operations
```

---

## Authentication Flow

```
Browser Request
    ↓
    Contains: x-api-key header
    ↓
Supabase Function receives request
    ↓
    extractApiKey(request)
    ↓
    validateApiKey(apiKey)
        ↓
        Hashes key with SHA-256
        ↓
        Queries api_keys table
        ↓
        Returns { valid, clientId, clientName }
    ↓
If valid → Process request with client_id filter
If invalid → Return 401 Unauthorized
```

---

## State Management

```
useDashboardData() Hook
    ↓
    ├─ data: DashboardApiResponse | null
    ├─ loading: boolean
    ├─ error: string | null
    ├─ refresh: () => Promise<void>
    └─ lastUpdated: string | null
         ↓
         Passed to all components via props
         ↓
         Components use useMemo() for derived data
         ↓
         Charts/tables re-render on data change
```

---

## Technology Stack

### Frontend
- **Next.js 14** (App Router)
- **React 18** (Client components)
- **TypeScript** (Full type safety)
- **Recharts** (Charts)
- **Tailwind CSS** (Styling)
- **Lucide React** (Icons)

### Backend
- **Supabase Edge Functions** (Deno)
- **PostgreSQL** (Database)
- **Event Sourcing** (Audit trail)

### Communication
- **REST API** (JSON over HTTPS)
- **API Key Authentication**
- **CORS Enabled**

---

## Performance Optimizations

1. **Parallel API Calls** - 3 endpoints fetched simultaneously
2. **Client-side Caching** - 60s refresh interval
3. **Memoization** - `useMemo()` for expensive calculations
4. **Lazy Loading** - "Load more" pagination in tables
5. **Optimistic Updates** - Immediate UI feedback

---

## Security Measures

1. **API Key Authentication** - SHA-256 hashed keys
2. **HTTPS Only** - All communications encrypted
3. **CORS Configuration** - Restricted origins
4. **Input Validation** - Server-side checks
5. **No Client Secrets** - API key only on server
6. **Rate Limiting** - Built into Supabase

---

## Monitoring & Logging

### Dashboard Side
- Console logs for debugging
- Error boundaries for crashes
- Loading states for UX

### Backend Side
- Structured logging to `logs` table
- Event sourcing to `event_store` table
- Operation tracking via `operation_id`

### Metrics Available
- Request counts
- Success rates
- Response times
- Error rates
- Volume metrics

---

## Deployment Architecture

```
┌─────────────────────────────────────────────────────┐
│                     Production                       │
│                                                       │
│  ┌──────────────────────────────────────────────┐  │
│  │         Vercel / Netlify                      │  │
│  │       (Next.js Dashboard)                     │  │
│  │    https://fountain-dashboard.vercel.app     │  │
│  └──────────────────────────────────────────────┘  │
│                       │                              │
│                       │ HTTPS                        │
│                       ▼                              │
│  ┌──────────────────────────────────────────────┐  │
│  │         Supabase Cloud                        │  │
│  │       (Edge Functions + Database)             │  │
│  │  https://bzxdqkttnkxqaecaiekt.supabase.co   │  │
│  └──────────────────────────────────────────────┘  │
│                       │                              │
│                       │                              │
│                       ▼                              │
│  ┌──────────────────────────────────────────────┐  │
│  │         Blockchain Network                    │  │
│  │       (Rayls Devnet / Sepolia)               │  │
│  │   https://devnet-rpc.rayls.com              │  │
│  └──────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

---

## Summary

This architecture provides:

✅ **Scalability** - Serverless functions auto-scale  
✅ **Reliability** - Multiple fallbacks and error handling  
✅ **Security** - API keys, HTTPS, validation  
✅ **Performance** - Caching, parallel requests, memoization  
✅ **Maintainability** - TypeScript, clean structure, documentation  
✅ **Real-time** - Auto-refresh, live data  
✅ **Production-ready** - Error handling, logging, monitoring  

**The dashboard is ready to handle real production traffic! 🚀**

