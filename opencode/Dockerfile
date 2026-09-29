FROM node:22-slim

# Target architecture: x86_64 (amd64)
LABEL maintainer="NOOBGLITCH"
LABEL architecture="x86_64"
LABEL description="Optimized OpenCode + OpenChamber Devbox with Bun, zRAM and CLI tools"

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

# 3. Bun binary + OpenCode engine + OpenChamber web UI + Wrangler CLI
COPY --from=oven/bun:latest /usr/local/bin/bun /usr/local/bin/bun
RUN ln -sf /usr/local/bin/bun /usr/local/bin/bunx \
    && bun add -g opencode-ai@latest @openchamber/web@latest wrangler@latest \
    && ln -sf /root/.bun/bin/* /usr/local/bin/ \
    && mkdir -p /usr/local/lib/node_modules/@openchamber \
    && ln -sfn /root/.bun/install/global/node_modules/@openchamber/web /usr/local/lib/node_modules/@openchamber/web \
    && rm -rf /root/.bun/install/cache /root/.npm /tmp/*

WORKDIR /workspace
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# 4. Systemd shims and xdg-open headless shims
RUN chmod +x /usr/local/bin/entrypoint.sh \
    && printf '#!/bin/sh\nexit 0\n' > /usr/local/bin/xdg-open \
    && chmod +x /usr/local/bin/xdg-open \
    && printf '#!/bin/sh\neval "last_arg=\\${$#}"\nif [ -n "$last_arg" ]; then\n  nohup /bin/sh -c "$last_arg" > /tmp/openchamber-update.log 2>&1 &\nfi\nexit 0\n' > /usr/local/bin/systemd-run \
    && printf '#!/bin/sh\n(sleep 1 && (pkill -f "openchamber serve" || kill 1)) &\nexit 0\n' > /usr/local/bin/systemctl \
    && chmod +x /usr/local/bin/systemd-run /usr/local/bin/systemctl

# 5. Environment configuration for x86_64 runtime optimization
ENV PATH="/root/.bun/bin:/usr/local/bin:${PATH}"
ENV NODE_ENV=production
ENV NODE_OPTIONS="--max-old-space-size=512"
ENV PORT=8080
ENV INVOCATION_ID=openchamber-container-service
ENV OPENCHAMBER_SYSTEMD_UNIT=openchamber.service

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash", "-lc", "exec openchamber serve --host 0.0.0.0 --port ${PORT:-8080} --foreground"]
