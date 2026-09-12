# GitHub Actions Runner Image

A lightweight Linux self-hosted GitHub Actions runner image based on [`myoung34/github-runner`](https://github.com/myoung34/docker-github-actions-runner), currently using its `ubuntu-noble` base.

It keeps the upstream runner entrypoint and adds/fixes common tooling required by the repositories that use this image:

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
ghcr.io/pdherdy/github-actions-runner-image:latest
```

A second immutable tag is published for every build using the Git commit SHA.

## Usage

The image can run on any compatible Linux/amd64 Docker host, including Docker Engine, Docker Desktop and TrueNAS SCALE Custom Apps.

Example:

```yaml
services:
  runner:
    image: ghcr.io/pdherdy/github-actions-runner-image:latest
```

Keep runner identity and work data on separate persistent mounts. For example:

```yaml
volumes:
  - ./runner-data:/runner/data
  - ./work:/_work
```

Set the runner work directory to `/_work` when using the example mount above.

Each concurrently running runner instance should have its own `/runner/data` and `/_work` storage. Do not share runner identity data between instances.

Do not store GitHub registration tokens, PATs or repository secrets in this image.

## TrueNAS SCALE example

A TrueNAS SCALE deployment can use host paths instead of local Docker volumes:

```yaml
services:
  runner:
    image: ghcr.io/pdherdy/github-actions-runner-image:latest
    volumes:
      - /mnt/app_pool/github_runners/example/runner-data:/runner/data
      - /mnt/app_pool/github_runners/example/work:/_work
      - /var/run/docker.sock:/var/run/docker.sock
```

## Publishing

`.github/workflows/publish.yml` builds `linux/amd64` and publishes to GitHub Container Registry using the repository-scoped `GITHUB_TOKEN`. No long-lived package PAT is required for CI publishing.

The Dockerfile validates the expected baseline toolchain during the image build, so a missing `python`, `npm`, `pwsh`, Git or Docker CLI causes publication to fail.
