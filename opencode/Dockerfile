FROM node:22-slim

# Target architecture: x86_64 (amd64)
LABEL maintainer="NOOBGLITCH"
LABEL architecture="x86_64"
LABEL description="Optimized OpenCode + OpenChamber Devbox for Railway with Bun and zRAM"

ENV DEBIAN_FRONTEND=noninteractive

# 1. System dependencies + GitHub CLI + zram-tools in a single consolidated layer
RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        openssh-client \
        ca-certificates \
        curl \
        gnupg \
        zram-tools \
        util-linux \
        procps \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod 644 /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends gh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/* /tmp/*

# 2. GitLab CLI, Cloudflared, and ngrok for x86_64 (amd64) in a single cached layer
RUN GLAB_VERSION=$(curl -sL "https://gitlab.com/api/v4/projects/gitlab-org%2Fcli/releases" | grep -o '"tag_name":"v[^"]*"' | head -n 1 | cut -d'"' -f4 | sed 's/^v//') \
    && ARCH=$(dpkg --print-architecture) \
    && curl -sSL "https://gitlab.com/gitlab-org/cli/-/releases/v${GLAB_VERSION}/downloads/glab_${GLAB_VERSION}_linux_amd64.deb" -o /tmp/glab.deb \
    && dpkg -i /tmp/glab.deb \
    && curl -sSL "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb" -o /tmp/cloudflared.deb \
    && dpkg -i /tmp/cloudflared.deb \
    && curl -sSL "https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz" -o /tmp/ngrok.tgz \
    && tar -xzf /tmp/ngrok.tgz -C /usr/local/bin \
    && rm -f /tmp/glab.deb /tmp/cloudflared.deb /tmp/ngrok.tgz

# 3. Bun binary + OpenCode engine + OpenChamber web UI + Wrangler CLI + Caveman
COPY --from=oven/bun:latest /usr/local/bin/bun /usr/local/bin/bun
RUN ln -sf /usr/local/bin/bun /usr/local/bin/bunx \
    && bun add -g opencode-ai@latest @openchamber/web@latest wrangler@latest @caveman-ai/cli@latest \
    && mkdir -p /usr/local/lib/node_modules/@openchamber \
    && ln -sfn /root/.bun/install/global/node_modules/@openchamber/web /usr/local/lib/node_modules/@openchamber/web \
    && rm -rf /root/.bun/install/cache /root/.npm /tmp/* /var/tmp/*

# 4. OpenCode upgrade wrapper (defaults --method bun for in-UI 1-click upgrades)
RUN printf '#!/bin/sh\nif [ "$1" = "upgrade" ]; then\n  for arg in "$@"; do\n    case "$arg" in --method*|-m*) exec /root/.bun/bin/opencode "$@" ;;\n    esac\n  done\n  exec /root/.bun/bin/opencode "$@" --method bun\nfi\nexec /root/.bun/bin/opencode "$@"\n' > /usr/local/bin/opencode \
    && chmod +x /usr/local/bin/opencode \
    && ln -sf /root/.bun/bin/openchamber /usr/local/bin/openchamber \
    && ln -sf /root/.bun/bin/wrangler    /usr/local/bin/wrangler \
    && ln -sf /root/.bun/bin/caveman     /usr/local/bin/caveman \
    && ln -sf /root/.bun/bin/cave        /usr/local/bin/cave

WORKDIR /workspace
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# 5. Systemd shims and xdg-open headless shims
RUN chmod +x /usr/local/bin/entrypoint.sh \
    && printf '#!/bin/sh\nexit 0\n' > /usr/local/bin/xdg-open \
    && chmod +x /usr/local/bin/xdg-open \
    && printf '#!/bin/sh\neval "last_arg=\\${$#}"\nif [ -n "$last_arg" ]; then\n  nohup /bin/sh -c "$last_arg" > /tmp/openchamber-update.log 2>&1 &\nfi\nexit 0\n' > /usr/local/bin/systemd-run \
    && printf '#!/bin/sh\n(sleep 1 && (pkill -f "openchamber serve" || kill 1)) &\nexit 0\n' > /usr/local/bin/systemctl \
    && chmod +x /usr/local/bin/systemd-run /usr/local/bin/systemctl

# 6. Environment configuration for Railway runtime optimization
ENV PATH="/root/.bun/bin:/usr/local/bin:${PATH}"
ENV NODE_ENV=production
ENV NODE_OPTIONS="--max-old-space-size=384"
ENV BUN_GARBAGE_COLLECTOR_LEVEL=1
ENV PORT=8080
ENV INVOCATION_ID=openchamber-container-service
ENV OPENCHAMBER_SYSTEMD_UNIT=openchamber.service

# Railway healthcheck & graceful stop signal (prevents SQLite DB corruption on deploy/sleep)
STOPSIGNAL SIGTERM
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
    CMD curl -f http://127.0.0.1:${PORT:-8080}/health || exit 1

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash", "-lc", "exec openchamber serve --host 0.0.0.0 --port ${PORT:-8080} --foreground"]
