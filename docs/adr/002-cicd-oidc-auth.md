# ADR 002 — GitHub Actions authentication via OIDC

## Status

Accepted

## Date

2026-03-23

## Context

The CI/CD pipeline needs to authenticate to Azure to run
terraform plan and apply. Options considered:

1. Service principal client secret stored in GitHub secrets
2. OIDC federated identity — no stored credentials

## Decision

OIDC federation (option 2).

## Reasoning

A client secret is a long-lived credential that can be leaked
via logs, exported secrets, or repo exposure. OIDC tokens are
short-lived (5 minutes), scoped to a specific repo and branch,
and cannot be used outside of the GitHub Actions context that
issued them. There is no secret to rotate or leak.

## Consequences

- Pipeline cannot authenticate from anywhere except GitHub Actions
- Credentials cannot be accidentally committed
- Audit trail in Azure shows GitHub Actions as the identity
- Slightly more complex initial setup, simpler ongoing maintenance
