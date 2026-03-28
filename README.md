# Project VPC — Azure Hub-Spoke Network

## Overview

A production-grade hub-spoke VNet topology on Azure,
built and managed entirely with Terraform.

## Architecture

- Hub VNet with Azure Firewall, VPN Gateway, Private DNS
- Three spoke VNets: Dev, Staging, Prod
- NSGs per subnet, UDRs routing all egress via hub firewall
- Remote state in Azure Storage with Entra ID auth
- CI/CD via GitHub Actions with OIDC federation

## Project lifecycle

Every change follows: Provision → Break → Detect → Respond

## Prerequisites

- Azure CLI
- Terraform >= 1.5.0
- GitHub Actions (CI/CD)

## Structure

\`\`\`
modules/ Reusable Terraform modules
environments/ Per-environment variable files
backend/ One-time state storage bootstrap
docs/ Architecture decisions and diagrams
\`\`\`

## Deployment

All changes deploy via pull request — no direct applies
from local machine after initial bootstrap.
