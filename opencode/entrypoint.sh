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
# ── zRAM compressed swap setup (x86_64) ──────────────────────
# Safe activation: runs if container has /dev/zram0 or CAP_SYS_ADMIN.
# Silently skips on standard unprivileged container runtimes.
if [ -e /dev/zram0 ] || [ -e /sys/class/zram-control ]; then
    if command -v zramctl >/dev/null 2>&1; then
        (
            echo "[boot] checking zRAM compressed swap..."
            modprobe zram num_devices=1 2>/dev/null || true
            zramctl --find --size 1G --algorithm zstd 2>/dev/null || \
            zramctl --find --size 1G 2>/dev/null || true
            if [ -b /dev/zram0 ]; then
                mkswap /dev/zram0 >/dev/null 2>&1 && \
                swapon -p 100 /dev/zram0 >/dev/null 2>&1 && \
                echo "[boot] zRAM 1GB compressed swap activated"
            fi
        ) 2>/dev/null || true
    fi
fi

# ── Volume layout ───────────────────────────────────────────
mkdir -p /workspace/paseo \
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

# Paseo, OpenCode, Wrangler, MCP, and skills store auth, state, configs, and custom rules.
# Point all relevant ~/.config, ~/.local/share, ~/.paseo, ~/.wrangler, ~/.opencode, ~/.mcp, and ~/.skills at the persistent volume.
mkdir -p /root/.local/share /root/.config
for link in /root/.paseo \
            /root/.local/share/opencode /root/.config/opencode \
            /root/.opencode /root/.mcp /root/.skills /root/skills \
            /root/.wrangler /root/.config/.wrangler /root/.config/wrangler; do
    [ -L "$link" ] || rm -rf "$link"
done
ln -sfn /workspace/paseo              /root/.paseo
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

# Pre-seed Paseo config to disable heavy local speech model downloads on cloud containers
if [ ! -f /workspace/paseo/config.json ]; then
    cat <<'EOF' > /workspace/paseo/config.json
{
  "speech": {
    "providers": {
      "dictationStt": { "enabled": false },
      "voiceTurnDetection": { "enabled": false },
      "voiceStt": { "enabled": false },
      "voiceTts": { "enabled": false }
    }
  }
}
EOF
fi

# Ensure opencode engine stays in container rootfs rather than eating /workspace volume
mkdir -p /workspace/opencode/bin
ln -sfn /usr/local/bin/opencode /workspace/opencode/bin/opencode
ln -sfn /usr/local/bin/opencode /workspace/opencode/bin/opencode2

# ── Git / SSH bootstrap ─────────────────────────────────────
# Generate an ed25519 key on first boot (persists via the volume).
if [ ! -f /workspace/.ssh/id_ed25519 ]; then
    echo "[boot] generating ed25519 git key (first boot)..."
    ssh-keygen -t ed25519 -C "paseo-devbox@$(hostname)" \
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

# ── Paseo web UI password & runtime environment ──────────────
PWFILE=/workspace/.paseo-password
OLD_PWFILE=/workspace/.openchamber-web-password

# Backward-compatibility: support PASEO_PASSWORD or legacy OPENCHAMBER_UI_PASSWORD
USER_PW="${PASEO_PASSWORD:-${OPENCHAMBER_UI_PASSWORD:-}}"

if [ -n "$USER_PW" ]; then
    echo "$USER_PW" > "$PWFILE"
    chmod 600 "$PWFILE"
    export PASEO_PASSWORD="$USER_PW"
elif [ -f "$PWFILE" ]; then
    export PASEO_PASSWORD="$(cat "$PWFILE")"
elif [ -f "$OLD_PWFILE" ]; then
    export PASEO_PASSWORD="$(cat "$OLD_PWFILE")"
    echo "$PASEO_PASSWORD" > "$PWFILE"
    chmod 600 "$PWFILE"
else
    head -c 18 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | cut -c1-24 > "$PWFILE"
    chmod 600 "$PWFILE"
    export PASEO_PASSWORD="$(cat "$PWFILE")"
fi

export PASEO_HOME="/workspace/paseo"
export PASEO_LISTEN="0.0.0.0:${PORT:-8080}"
export PASEO_HOSTNAMES="true"
export PASEO_WEB_UI_ENABLED="true"

echo "[boot] Paseo web auth → password: ${PASEO_PASSWORD}"

# ── Provider keys + auth into SSH login shells ──────────────
rm -f /etc/profile.d/00-openchamber-env.sh 2>/dev/null || true
echo "[boot] writing /etc/profile.d/00-paseo-env.sh for SSH shells..."
{
    echo "# Auto-generated by entrypoint.sh on each boot."
    for var in ANTHROPIC_API_KEY OPENAI_API_KEY OPENROUTER_API_KEY GEMINI_API_KEY DEEPSEEK_API_KEY \
               TOGETHER_API_KEY MISTRAL_API_KEY GROQ_API_KEY XAI_API_KEY FIREWORKS_API_KEY PERPLEXITY_API_KEY \
               CLOUDFLARE_API_TOKEN CLOUDFLARE_ACCOUNT_ID \
               GITHUB_TOKEN GITLAB_TOKEN GLAB_TOKEN \
               PASEO_PASSWORD PASEO_HOME PASEO_LISTEN PASEO_HOSTNAMES PASEO_WEB_UI_ENABLED PORT; do
        val="${!var:-}"
        [ -n "$val" ] && printf 'export %s=%q\n' "$var" "$val"
    done
    # Land in your repos directory on login.
    echo 'cd /workspace/repos 2>/dev/null || true'
} > /etc/profile.d/00-paseo-env.sh
chmod 644 /etc/profile.d/00-paseo-env.sh

echo "[boot] Paseo server starting on port ${PORT:-8080}..."
exec "$@"
