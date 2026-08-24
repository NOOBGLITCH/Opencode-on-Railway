# Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│  YOUR MACHINE                                                     │
│   browser ──────────────┐            railway ssh ─────────┐       │
└─────────────────────────┼───────────────────────────────-─┼──────┘
        Railway public domain (HTTPS)      Railway authenticated SSH
                          ▼                                  ▼
┌──────────────────────────────────────────────────────────────────┐
│  RAILWAY CONTAINER  (one service)                                │
│                                                                  │
│   CMD ▶ openchamber serve --host 0.0.0.0 --port $PORT            │
│            └─ password auth (OPENCHAMBER_UI_PASSWORD) ─ web UI   │
│            └─ manages local loopback `opencode serve` daemon     │
│                                                                  │
│   railway ssh ▶ login shell ▶ /etc/profile.d/00-openchamber-env  │
│                     └─ $ opencode  ▶ TUI / `opencode run`         │
│                                                                  │
│   tooling: openchamber · opencode-ai · wrangler · glab · gh · git │
│                                                                  │
│   symlinks ──▶  /workspace volume (persists across deploys)      │
│     ~/.local/share/openchamber → /workspace/openchamber/data   │
│     ~/.config/openchamber      → /workspace/openchamber/config │
│     ~/.local/share/opencode    → /workspace/opencode/data      │
│     ~/.config/opencode         → /workspace/opencode/config    │
│     ~/.opencode                → /workspace/opencode           │
│     ~/.skills & ~/skills       → /workspace/skills             │
│     ~/.mcp                     → /workspace/mcp                │
│     ~/.wrangler                → /workspace/wrangler           │
│     ~/.ssh                     → /workspace/.ssh               │
│     repos                       /workspace/repos               │
└──────────────────────────────────────────────────────────────────┘
```

## Components

- **Dockerfile** — `node:22-slim` + `git`, `openssh-client`, `gh`, `glab`, `opencode-ai`, `@openchamber/web`, and `wrangler`. `ENTRYPOINT` runs `entrypoint.sh`; `CMD` runs `openchamber serve --host 0.0.0.0 --port ${PORT:-8080} --foreground` (the main process on `$PORT`, default 8080).
- **entrypoint.sh** — runs on every boot:
  1. Constructs `/workspace` volume directory structure and symlinks OpenChamber, OpenCode (`opencode.json`), skills, MCP servers, Wrangler, and SSH keys onto `/workspace`.
  2. Generates an ed25519 SSH key (`~/.ssh/id_ed25519`) on first boot and trusts `github.com` & `gitlab.com`.
  3. Authenticates `gh` from `GITHUB_TOKEN` and `glab` from `GITLAB_TOKEN`/`GLAB_TOKEN` if provided.
  4. Resolves `OPENCHAMBER_UI_PASSWORD` (persisted at `/workspace/.openchamber-web-password` if unset) and unsets loopback `OPENCODE_SERVER_PASSWORD` to ensure local OpenChamber ➔ OpenCode loopback communication succeeds without HTTP 401 basic-auth errors.
  5. Writes `/etc/profile.d/00-openchamber-env.sh` so SSH login shells export provider keys, cloud tokens, and land in `/workspace/repos`.
- **railway.json** — Dockerfile builder + ON_FAILURE restart policy.
- **Public domain** — Railway maps HTTPS requests on port `$PORT` to `openchamber serve`.
- **Volume** — Mounted at `/workspace`; the single source of persistent state.

## Design Choices

- **Two surfaces, one service.** `openchamber serve` is the main process behind the public domain; `railway ssh` reaches the same container for the `opencode` TUI. Both share `/workspace`, auth, and repos.
- **Loopback binding fix.** Unsetting `OPENCODE_SERVER_PASSWORD` inside the container environment prevents loopback OpenCode daemon auth blocks, while `OPENCHAMBER_UI_PASSWORD` maintains web protection.
- **Volume-first persistence.** All mutable state is symlinked onto `/workspace`, ensuring redeploys keep your auth, sessions, MCP servers, skills, Wrangler tokens, and repos intact.
