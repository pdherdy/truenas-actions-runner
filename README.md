# TrueNAS GitHub Actions Runner

A lightweight GitHub Actions self-hosted runner image for TrueNAS SCALE, based on `myoung34/github-runner:ubuntu-noble`.

It keeps the upstream runner entrypoint and adds/fixes the common tooling required by the repositories hosted on this TrueNAS server:

- Python 3 / `python` alias
- pip and venv
- Node.js 24 + npm
- PowerShell 7 (`pwsh`, inherited from upstream)
- Git (inherited from upstream)
- Docker CLI (inherited from upstream)
- build/archive/JSON utilities
- Linux runtime dependencies for Playwright Chromium 1.55

The Chromium browser binary is intentionally **not** baked into the image. Workflows can keep their own Playwright/browser version pinned while avoiding repeated OS dependency installation.

## Image

```text
ghcr.io/pdherdy/truenas-actions-runner:latest
```

A second immutable tag is published for every build using the Git commit SHA.

## TrueNAS usage

Use this image in the existing Custom App service:

```yaml
services:
  runner:
    image: ghcr.io/pdherdy/truenas-actions-runner:latest
```

Keep the existing persistent mounts. In particular, `/runner/data` preserves the registered GitHub runner identity across container/image replacement.

Example:

```yaml
volumes:
  - /mnt/app_pool/github_runners/epub/runner-data:/runner/data
  - /mnt/app_pool/github_runners/epub/work:/_work
```

Do not store GitHub registration tokens, PATs or repository secrets in this image.

## Publishing

`.github/workflows/publish.yml` builds `linux/amd64` and publishes to GitHub Container Registry using the repository-scoped `GITHUB_TOKEN`. No long-lived package PAT is required for CI publishing.

The Dockerfile validates the expected baseline toolchain during the image build, so a missing `python`, `npm`, `pwsh`, Git or Docker CLI causes publication to fail.
