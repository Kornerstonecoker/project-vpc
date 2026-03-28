# ADR 001 — Remote state storage in Azure Storage

## Status

Accepted

## Date

2026-03-23

## Context

Terraform state must be stored somewhere accessible to both
local development and CI/CD pipelines, with locking to prevent
concurrent applies corrupting state.

## Options considered

1. Local state — simple but not shareable, no locking
2. Azure Storage Account — native Azure, blob lease locking
3. HCP Terraform — managed service, adds cost and dependency

## Decision

Azure Storage Account with Entra ID authentication.

## Reasoning

Keeps state within the same Azure tenant as the infrastructure.
Blob lease provides automatic locking. Entra ID auth means no
storage keys to manage or rotate. Versioning and soft delete
provide recovery from accidental corruption or deletion.

## Security controls applied

- Public blob access disabled at account level
- Shared access keys disabled — Entra ID only
- TLS 1.2 minimum
- Blob versioning enabled — 30 day retention
- Private endpoint — accessible from CI/CD agent only

## Consequences

- State is not portable outside Azure without migration
- Requires RBAC assignment for every identity that runs Terraform
- Recovery from corruption uses blob version restore
