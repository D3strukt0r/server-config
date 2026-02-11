# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Infrastructure-as-Code repository managing Docker Compose services and cloud resources across multiple environments. No traditional build system — this is configuration-as-code using Docker Compose, OpenTofu (Terraform), and Bash scripts.

## Common Commands

### OpenTofu (Infrastructure)

```bash
tofu init                          # Initialize providers
tofu plan                          # Preview infrastructure changes
tofu apply                         # Apply infrastructure changes

# When adding providers, lock for all platforms:
tofu providers lock -platform=linux_arm64 -platform=linux_amd64 -platform=darwin_amd64 -platform=windows_amd64
```

### Docker Compose (Services)

```bash
# Per-service (run from within the service directory):
docker compose up -d               # Start service
docker compose down                # Stop service
docker compose logs -f             # View logs

# System-wide:
service docker-services start      # Start all services (uses init script)
service docker-services stop       # Stop all services
```

### Maintenance

```bash
./bin/docker-prune.sh              # Clean up Docker resources
./bin/backup-daily.sh              # Restic daily backup
```

## Architecture

### Environment Layout

- `digitalocean/prod/` — Production services on DigitalOcean (Traefik, Fluentd, web apps, monitoring)
- `digitalocean/dev/` — Development services on DigitalOcean
- `home/prod/` — Home network services (Gitea, Verdaccio, Packeton, GlitchTip)
- `home/dev/` — Home dev services
- `experimental/` — Non-production testing ground (Bitwarden, Pi-hole, Matrix, etc.)

### Service Pattern

Each service follows a consistent directory structure:

```
service-name/
├── compose.yml              # Main service definition (extends common/snippets.yml)
├── compose.override.yml     # Environment-specific overrides
├── .env.dist                # Environment variable template (copy to .env)
└── README.md                # Setup instructions
```

### Key Infrastructure Components

- **Traefik** (`digitalocean/prod/traefik/`) — Reverse proxy, TLS via Let's Encrypt, entrypoint for all web services
- **Fluentd** (`digitalocean/prod/fluentd/`) — Centralized logging; started first, stopped last
- **Watchtower** — Automated container updates
- **Prometheus + Grafana** — Metrics and monitoring

### Shared Compose Configs

`common/` contains reusable base configs:
- `snippets.yml` — Base service template (init: true, restart: unless-stopped, resource limits, health checks)
- Database templates: `mariadb.compose.yml`, `postgres.compose.yml`, `mongo.compose.yml`
- Supporting services: `redis.compose.yml`, `minio.compose.yml`, `phpmyadmin.compose.yml`, etc.

Services extend `common-service` from `snippets.yml` to inherit defaults (CPU limit 0.5, memory limit 50M, 60s health check interval).

### Terraform/OpenTofu Structure

- `main.tf` — DigitalOcean infrastructure (droplet, volumes, VPC, firewalls, monitoring alerts, uptime checks)
- `domain-*.tf` — DNS records per domain, managed via Cloudflare and Namecheap providers
- `terraform.tfvars.dist` — Template for required variables (copy to `terraform.tfvars`)
- Three providers: DigitalOcean, Cloudflare, Namecheap

## Conventions

### Shell Scripts

- Use `[[ ]]` instead of `[ ]`
- Use `$(command)` instead of backticks
- Use `apt-get` or `aptitude`, never `apt`
- Prefer single quotes when possible
- Indent with 4 spaces (per `.editorconfig`)
- ShellCheck is configured with `external-sources=true`

### Docker Compose

- All services use Fluentd logging driver
- Web-facing services join the `traefik_proxy` network
- Environment variables use `${VAR:?msg}` for required and `${VAR:-default}` for optional
- Resource limits set via `CPU_LIMIT` and `MEMORY_LIMIT` env vars

### General

- Indent: 2 spaces (YAML, JSON, HCL), 4 spaces (shell, HTML, Dockerfile)
- Line endings: LF (`.gitattributes` enforced)
- Max line length: 120 characters
- Secrets go in `.env` files (git-ignored); `.env.dist` files are committed as templates
