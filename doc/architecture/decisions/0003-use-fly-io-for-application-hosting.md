# 3. Use Fly.io for application hosting

Date: 2026-02-11

## Status

Accepted

## Context

We need a hosting platform for a React Router v7 SSR application that uses Supabase (Postgres, auth, realtime), Prisma 7, and Stripe. The app is write-heavy, targets North America (1-2 regions), and may add real-time collaborative editing features in the future.

We evaluated eight options:

- **Fly.io** — Docker containers on Firecracker VMs with auto-suspend/resume
- **Cloudflare Workers** — V8 isolates at the edge
- **Supabase Edge Functions** — Deno-based serverless handlers
- **Vercel** — Serverless functions with framework adapters
- **AWS (ECS/Fargate, Lambda, App Runner)** — Various container and serverless options
- **Railway** — Managed Docker container hosting with Git-based deploys
- **Google Cloud Run** — Serverless containers on GCP, auto-scales to zero
- **Kamal + Hetzner** — 37signals' deployment tool on bare VPS machines

Rejected options and why:

- **Cloudflare Workers.** Prisma 7 is broken on Workers (WASM issue, must pin to 6.x). Bundle size limits (3-10 MB) are tight with Prisma + Stripe. Edge advantage is negated because every SSR request round-trips to the single-region database anyway.
- **Supabase Edge Functions.** Not a viable SSR host. Deno-based, no React Router v7 adapter, 2-second CPU limit. Designed for individual API handlers, not application servers.
- **Vercel.** Good React Router v7 support and free tier, but no WebSocket server for future collaborative editing. Would require a separate service (PartyKit, Fly) for real-time features, splitting infrastructure.
- **AWS.** Full capability but 10x the configuration complexity (VPC, ALB, ECS task definitions, IAM roles, ECR, CloudWatch) for the same result. Solves problems we don't have yet.
- **Railway.** Similar simplicity to Fly but fewer regions (2 in US), no auto-suspend/resume, less mature networking and anycast routing.
- **Google Cloud Run.** Serverless containers with auto-scale to zero. Full Docker support. But no WebSocket support, and GCP adds IAM/billing complexity. Would block future real-time features.
- **Kamal + Hetzner.** Cheapest option (~$5/mo per server). Docker deploys to bare VPS with zero vendor lock-in. But you manage the servers yourself — OS updates, monitoring, networking, TLS certificates, load balancing. More ops burden than we want for an early-stage product.

## Decision

We will use Fly.io to host the application.

Key factors:

- **Containers on real machines, not serverless magic.** Fly's model is Docker containers running on Firecracker micro-VMs. You can SSH in, see processes, read logs, and reason about what's happening. No opaque serverless abstraction layers that are difficult to debug when things go wrong. The mental model is simple: your code runs on a machine, in a container, in a region you chose.
- **Full Node.js compatibility.** No runtime shims, no bundle size limits, no Prisma version pinning. The existing Dockerfile works as-is.
- **Co-location with Supabase Postgres.** Fly machines in the same region as Supabase give 1-5ms database latency. Edge platforms (Cloudflare Workers) negate their advantage because every SSR request still round-trips to the single-region database (20-80ms+).
- **Auto-suspend with near-instant resume.** Machines suspend to disk when idle and resume in ~200-500ms, keeping costs near zero for low-traffic periods without slow cold starts.
- **WebSocket support.** Fly runs stateful processes, enabling a future Yjs/WebSocket sync server for collaborative editing without adding another vendor.
- **Minimal setup.** `fly launch` + `fly deploy` vs. VPC/ALB/IAM/ECR configuration on AWS, or adapter/bundle/compatibility work on Cloudflare.

## Consequences

- **No free tier.** Demo/staging sites cost ~$1-2/mo (vs. free on Cloudflare/Vercel). Acceptable tradeoff for simplicity.
- **Single-region by default.** Scaling to multiple NA regions requires running additional machines. Straightforward with Fly but not automatic like edge platforms.
- **Vendor coupling on deployment.** The app itself is a standard Docker container, so migrating to AWS ECS or Railway is straightforward if needed.
- **No built-in CDN.** Static assets are served by the app. Can add Cloudflare as a CDN in front if needed.
