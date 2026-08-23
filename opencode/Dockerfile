FROM node:22-slim

# Tools a coding-agent box needs: git (clone/commit), gh (GitHub CLI), glab (GitLab CLI),
# openssh-client (git over SSH), curl/ca-certs/gnupg (installers & TLS).
RUN apt-get update && apt-get install -y --no-install-recommends \
        git openssh-client ca-certificates curl gnupg \
    && rm -rf /var/lib/apt/lists/*

# GitHub CLI — so the agent can `gh pr create`, `gh issue`, etc.
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod 644 /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends gh \
    && rm -rf /var/lib/apt/lists/*

# GitLab CLI (glab) — so the agent can interact with GitLab repos, PRs, issues, etc.
RUN GLAB_VERSION=$(curl -sL "https://gitlab.com/api/v4/projects/gitlab-org%2Fcli/releases" | grep -o '"tag_name":"v[^"]*"' | head -n 1 | cut -d'"' -f4 | sed 's/^v//') \
    && ARCH=$(dpkg --print-architecture) \
    && curl -sSL "https://gitlab.com/gitlab-org/cli/-/releases/v${GLAB_VERSION}/downloads/glab_${GLAB_VERSION}_linux_${ARCH}.deb" -o /tmp/glab.deb \
    && dpkg -i /tmp/glab.deb \
    && rm /tmp/glab.deb

# OpenCode engine + OpenChamber web UI + Cloudflare Wrangler CLI
RUN npm install -g opencode-ai@latest @openchamber/web@latest wrangler@latest

WORKDIR /workspace
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# `openchamber` web UI tries to launch a browser via xdg-open on start; on a headless
# container that throws a noisy (harmless) error. Shim it to a no-op.
RUN printf '#!/bin/sh\nexit 0\n' > /usr/local/bin/xdg-open \
    && chmod +x /usr/local/bin/xdg-open

# The web UI listens here; Railway maps the public domain to $PORT.
ENV PORT=8080
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
# Main process = the OpenChamber web UI on the public Railway domain.
CMD ["bash", "-lc", "exec openchamber serve --host 0.0.0.0 --port ${PORT:-8080} --foreground"]
