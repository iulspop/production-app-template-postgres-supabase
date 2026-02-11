# 2. Use React Router SaaS template as base

Date: 2026-02-11

## Status

Accepted

## Context

We needed a starting point for a production-grade SaaS application with authentication, organization/team management, billing, and CI/CD. Building from scratch would take weeks of boilerplate work on solved problems.

We evaluated several starting points:

- **React Router SaaS template** (by @dev-xo) — React Router v7, Supabase auth, Stripe billing, Prisma, i18n, Tailwind v4
- **Epic Stack** (by Kent C. Dodds) — React Router v7, custom auth, SQLite, full-stack conventions
- **Create React Router** — Minimal scaffold, no auth/billing/teams
- **Custom from scratch** — Maximum control, maximum effort

## Decision

We will use the React Router SaaS template as our base and customize it.

Key factors:

- **Good taste in functional programming.** The codebase favors composition over inheritance, pure functions, immutability, and clear separation of concerns. This aligns with our coding principles (functional programming, SDA, KISS, DRY).
- **Supabase integration.** Auth, Postgres, and realtime are pre-wired, matching our infrastructure choice.
- **Production features included.** Stripe billing, organization management, team roles, and i18n are implemented and tested — weeks of work we don't have to do.
- **React Router v7 patterns.** Uses loaders, actions, and the framework conventions correctly rather than fighting them.
- **Tailwind v4 + ShadCN/ui.** Modern styling stack with semantic design tokens.

## Consequences

- **Inherited patterns.** We adopt the template's conventions (feature-slice architecture, facade functions, schema validation approach). These are good patterns, but the team must learn them.
- **Upstream divergence.** As we customize, merging upstream updates becomes harder. We keep the original as a read-only reference in `react-router-saas-template/`.
- **Supabase coupling.** The template deeply integrates Supabase auth and client. Switching auth providers later would be significant work.
- **Template debt.** Some template code may not match our exact standards and will be refined over time.
