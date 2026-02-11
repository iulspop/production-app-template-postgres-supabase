# 4. Fly.io architecture for resilience

Date: 2026-02-11

## Status

Accepted

## Context

We chose Fly.io for application hosting (ADR-0003). Now we need to decide the deployment architecture — how many machines, which regions, scaling behavior, and health check strategy — to achieve production reliability for a write-heavy application targeting North American users.

The application is stateless (Supabase Postgres is the sole data store), so machines can be replicated freely.

Key constraints:

- **Write-heavy workload.** Database is single-region (Supabase in us-east-1). Write latency is bounded by proximity to the database.
- **North America scope.** Users in US and Canada. No immediate need for global edge distribution.
- **Cost-conscious.** This is an early-stage product. Spend on reliability, not on over-provisioning.

## Decision

- 2 machines, always on, in two different NA regions:
  - `iad` (Virginia) — co-located with Supabase Postgres for lowest write latency
  - `ord` (Chicago) or `sea` (Seattle) — geographic redundancy and better latency for central/west coast users
- `min_machines_running = 1` per region — both always warm, no cold starts
- Canary deploys — deploy to one machine first, verify health checks pass, then roll forward to the rest. Automatically stops if the canary fails.
- Health checks every 10s on `/healthcheck`, 30s grace period
- HyperDX for observability (logs, traces, metrics, session replays)
- Better Stack for external uptime monitoring (3-min checks, status page, alerting)
- Fly anycast routing automatically sends users to the nearest healthy region

## Consequences

- **~$8-16/mo compute cost** for 2 always-on machines across 2 regions. Acceptable for production reliability.
- **Zero-downtime deploys** with rolling strategy across regions.
- **Region failover.** If one region goes down entirely, Fly routes all traffic to the surviving region automatically.
- **Single-region database.** All writes go to Supabase in us-east-1. The `iad` machine has ~1-5ms DB latency; the second region has ~20-40ms. Acceptable for most write-heavy workloads.
- **No cold starts.** Always-on machines eliminate latency variance for users.
- **Scaling is manual.** Adding machines per region is a config change. Fly's auto-start can handle bursts, but sustained growth requires deliberate scaling decisions.
