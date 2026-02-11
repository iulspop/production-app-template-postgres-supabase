# 4. Fly.io architecture for resilience

Date: 2026-02-11

## Status

Accepted

## Context

We chose Fly.io for application hosting (ADR-0003). Now we need to decide the deployment architecture — how many machines, which regions, scaling behavior, and health check strategy — to achieve production reliability for a write-heavy application targeting North American users.

The application is stateless (Supabase Postgres is the sole data store), so machines can be replicated freely.

Key constraints:

- **Write-heavy workload.** Database is single-region (Supabase in us-west-2). Write latency is bounded by proximity to the database.
- **North America scope.** Users in US and Canada. No immediate need for global edge distribution.
- **Cost-conscious.** This is an early-stage product. Spend on reliability, not on over-provisioning.
- **Latency dominates.** Cross-region DB queries (e.g. Toronto → Oregon) add 60-80ms per query. Pages with multiple sequential queries become noticeably slow (800-1400ms). Co-locating servers with the database is more important than geographic redundancy.

## Decision

- 2 machines, always on, in a single region co-located with the database:
  - `sjc` (San Jose) — co-located with Supabase Postgres in us-west-2 for lowest DB latency
- `min_machines_running = 1` — both always warm, no cold starts
- Canary deploys — deploy to one machine first, verify health checks pass, then roll forward to the rest. Automatically stops if the canary fails.
- Health checks every 10s on `/healthcheck`, 30s grace period
- HyperDX for observability (logs, traces, metrics, session replays)
- Better Stack for external uptime monitoring (3-min checks, status page, alerting)
- Fly anycast routing automatically sends users to the nearest healthy region

## Consequences

- **~$8-16/mo compute cost** for 2 always-on machines in one region. Acceptable for production reliability.
- **Zero-downtime deploys** with canary strategy across machines.
- **Machine failover.** If one machine goes down, Fly routes traffic to the surviving machine automatically.
- **Low DB latency.** Both machines in `sjc` have ~1-5ms latency to Supabase in us-west-2.
- **No cold starts.** Always-on machines eliminate latency variance for users.
- **Scaling path.** Add a second region later when user base justifies it — requires Supabase read replica in that region to avoid cross-region DB latency.
- **Scaling is manual.** Adding machines is a config change. Fly's auto-start can handle bursts, but sustained growth requires deliberate scaling decisions.
