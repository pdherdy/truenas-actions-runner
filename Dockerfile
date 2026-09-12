FROM myoung34/github-runner:ubuntu-noble

USER root

ENV DEBIAN_FRONTEND=noninteractive

LABEL org.opencontainers.image.source="https://github.com/pdherdy/github-runner-image" \
      org.opencontainers.image.description="Linux self-hosted GitHub Actions runner image with Python, Node.js, npm and browser-test dependencies" \
      org.opencontainers.image.licenses="MIT"

# The upstream runner already includes most CI tooling. Add/fix the pieces
# required by our repositories:
# - `python` -> Python 3 on Ubuntu Noble (3.12)
# - Node.js 24 with npm
# - common archive/JSON utilities
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        jq \
        python3 \
        python3-pip \
        python3-venv \
        python-is-python3 \
        unzip \
        zip \
    && curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# Preinstall the Linux runtime libraries required by the Chromium version
# currently used by the EPUB browser matrix. The browser binary itself stays
# workflow-local, so projects can pin/update Playwright independently.
RUN npx --yes playwright@1.55.0 install-deps chromium \
    && npm cache clean --force \
    && rm -rf /var/lib/apt/lists/* /root/.cache

# Fail the image build immediately if the expected baseline toolchain is not
# available. PowerShell, Git and Docker CLI come from the upstream runner.
RUN python --version \
    && python3 --version \
    && pip --version \
    && node --version \
    && npm --version \
    && pwsh --version \
    && git --version \
    && docker --version

WORKDIR /actions-runner
