#!/bin/bash
set -e

# ════════════════════════════════════════════════════════════
# OpenCode devbox — boot script
#
# Goal: when you `railway ssh` into this service and type `opencode`,
# you drop straight into the OpenCode TUI, with your auth, sessions, and
# repos preserved across redeploys. Everything persistent lives on the
# /workspace volume; symlinks make OpenCode and git find it in the usual
# home-directory paths.
# ════════════════════════════════════════════════════════════

# ── Volume layout ───────────────────────────────────────────
mkdir -p /workspace/openchamber/data \
         /workspace/openchamber/config \
         /workspace/opencode/data \
         /workspace/opencode/config \
         /workspace/opencode/skills \
         /workspace/opencode/mcp \
         /workspace/skills \
         /workspace/mcp \
         /workspace/wrangler \
         /workspace/repos \
         /workspace/.ssh \
         /workspace/logs
chmod 700 /workspace/.ssh

# OpenChamber, OpenCode, Wrangler, MCP, and skills store auth, state, configs, and custom rules.
# Point all relevant ~/.config, ~/.local/share, ~/.wrangler, ~/.opencode, ~/.mcp, and ~/.skills at the persistent volume.
mkdir -p /root/.local/share /root/.config
for link in /root/.local/share/openchamber /root/.config/openchamber \
            /root/.local/share/opencode /root/.config/opencode \
            /root/.opencode /root/.mcp /root/.skills /root/skills \
            /root/.wrangler /root/.config/.wrangler /root/.config/wrangler; do
    [ -L "$link" ] || rm -rf "$link"
done
ln -sfn /workspace/openchamber/data   /root/.local/share/openchamber
ln -sfn /workspace/openchamber/config /root/.config/openchamber
ln -sfn /workspace/opencode/data      /root/.local/share/opencode
ln -sfn /workspace/opencode/config    /root/.config/opencode
ln -sfn /workspace/opencode           /root/.opencode
ln -sfn /workspace/wrangler           /root/.wrangler
ln -sfn /workspace/wrangler           /root/.config/.wrangler
ln -sfn /workspace/wrangler           /root/.config/wrangler
ln -sfn /workspace/mcp                /root/.mcp
ln -sfn /workspace/skills             /root/.skills
ln -sfn /workspace/skills             /root/skills
ln -sfn /workspace/.ssh               /root/.ssh

# ── Git / SSH bootstrap ─────────────────────────────────────
# Generate an ed25519 key on first boot (persists via the volume).
if [ ! -f /workspace/.ssh/id_ed25519 ]; then
    echo "[boot] generating ed25519 git key (first boot)..."
    ssh-keygen -t ed25519 -C "openchamber-devbox@$(hostname)" \
        -f /workspace/.ssh/id_ed25519 -N "" -q
fi
chmod 600 /workspace/.ssh/id_ed25519 2>/dev/null || true
chmod 644 /workspace/.ssh/id_ed25519.pub 2>/dev/null || true

if ! grep -q "^github.com" /workspace/.ssh/known_hosts 2>/dev/null; then
    echo "[boot] trusting github.com and gitlab.com host keys..."
    ssh-keyscan -t rsa,ecdsa,ed25519 github.com gitlab.com 2>/dev/null \
        >> /workspace/.ssh/known_hosts || true
    chmod 644 /workspace/.ssh/known_hosts
fi

git config --global init.defaultBranch main 2>/dev/null || true
[ -n "$GIT_USER_EMAIL" ] && git config --global user.email "$GIT_USER_EMAIL" 2>/dev/null || true
[ -n "$GIT_USER_NAME" ]  && git config --global user.name  "$GIT_USER_NAME"  2>/dev/null || true

# gh auth — re-run each boot if GITHUB_TOKEN is provided.
if [ -n "$GITHUB_TOKEN" ] && command -v gh >/dev/null 2>&1; then
    if ! gh auth status >/dev/null 2>&1; then
        echo "[boot] authenticating gh CLI from GITHUB_TOKEN..."
        echo "$GITHUB_TOKEN" | gh auth login --with-token 2>/dev/null \
            || echo "[boot] gh auth login failed (token may be invalid)"
    fi
fi

# glab auth — re-run each boot if GITLAB_TOKEN or GLAB_TOKEN is provided.
GLAB_AUTH_TOKEN="${GITLAB_TOKEN:-${GLAB_TOKEN:-}}"
if [ -n "$GLAB_AUTH_TOKEN" ] && command -v glab >/dev/null 2>&1; then
    if ! glab auth status >/dev/null 2>&1; then
        echo "[boot] authenticating glab CLI..."
        echo "$GLAB_AUTH_TOKEN" | glab auth login --stdin 2>/dev/null \
            || echo "[boot] glab auth login failed (token may be invalid)"
    fi
fi

# ── OpenChamber web UI password & host ───────────────────────
export OPENCHAMBER_HOST="0.0.0.0"
export INVOCATION_ID="${INVOCATION_ID:-openchamber-container-service}"
export OPENCHAMBER_SYSTEMD_UNIT="${OPENCHAMBER_SYSTEMD_UNIT:-openchamber.service}"
export OPENCHAMBER_UI_PASSWORD="${OPENCHAMBER_UI_PASSWORD:-${OPENCODE_SERVER_PASSWORD:-}}"
if [ -z "$OPENCHAMBER_UI_PASSWORD" ]; then
    PWFILE=/workspace/.openchamber-web-password
    if [ ! -f "$PWFILE" ]; then
        head -c 18 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | cut -c1-24 > "$PWFILE"
        chmod 600 "$PWFILE"
    fi
    export OPENCHAMBER_UI_PASSWORD="$(cat "$PWFILE")"
fi
# Unset OPENCODE_SERVER_PASSWORD so managed local opencode daemon on 127.0.0.1 does not require basic-auth from OpenChamber
unset OPENCODE_SERVER_PASSWORD OPENCODE_SERVER_USERNAME
echo "[boot] openchamber web auth → password: ${OPENCHAMBER_UI_PASSWORD}"

# ── Provider keys + web auth into SSH login shells ──────────
echo "[boot] writing /etc/profile.d/00-openchamber-env.sh for SSH shells..."
{
    echo "# Auto-generated by entrypoint.sh on each boot."
    for var in ANTHROPIC_API_KEY OPENAI_API_KEY OPENROUTER_API_KEY GEMINI_API_KEY DEEPSEEK_API_KEY \
               TOGETHER_API_KEY MISTRAL_API_KEY GROQ_API_KEY XAI_API_KEY FIREWORKS_API_KEY PERPLEXITY_API_KEY \
               CLOUDFLARE_API_TOKEN CLOUDFLARE_ACCOUNT_ID \
               GITHUB_TOKEN GITLAB_TOKEN GLAB_TOKEN OPENCHAMBER_UI_PASSWORD OPENCHAMBER_SYSTEMD_UNIT INVOCATION_ID; do
        val="${!var:-}"
        [ -n "$val" ] && printf 'export %s=%q\n' "$var" "$val"
    done
    # Land in your repos directory on login.
    echo 'cd /workspace/repos 2>/dev/null || true'
} > /etc/profile.d/00-openchamber-env.sh
chmod 644 /etc/profile.d/00-openchamber-env.sh

echo "[boot] OpenChamber server starting on port ${PORT:-8080}..."
exec "$@"
