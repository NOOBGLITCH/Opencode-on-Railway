# Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│  YOUR MACHINE                                                     │
│   browser ──────────────┐            railway ssh ─────────┐       │
└─────────────────────────┼─────────────────────────────────┼──────┘
        Railway public domain (HTTPS)      Railway authenticated SSH
                          ▼                                  ▼
┌──────────────────────────────────────────────────────────────────┐
│  RAILWAY CONTAINER  (one service)                                │
│                                                                  │
│   CMD ▶ paseo daemon start --home /workspace/paseo               │
│            └─ password auth (PASEO_PASSWORD) ─ web UI on $PORT   │
│            └─ on-demand manager for OpenCode and other agents    │
│                                                                  │
│   railway ssh ▶ login shell ▶ /etc/profile.d/00-paseo-env.sh     │
│                     └─ $ opencode ▶ TUI / CLI                     │
│                     └─ $ paseo    ▶ CLI management                │
│                                                                  │
│   tooling: paseo · opencode-ai · wrangler · glab · gh · git      │
│                                                                  │
│   symlinks ──▶  /workspace volume (persists across deploys)      │
│     ~/.paseo                   → /workspace/paseo                │
│     ~/.local/share/opencode    → /workspace/opencode/data        │
│     ~/.config/opencode         → /workspace/opencode/config      │
│     ~/.opencode                → /workspace/opencode             │
│     ~/.skills & ~/skills       → /workspace/skills               │
│     ~/.mcp                     → /workspace/mcp                  │
│     ~/.wrangler                → /workspace/wrangler             │
│     ~/.ssh                     → /workspace/.ssh                 │
│     repos                       /workspace/repos                 │
└──────────────────────────────────────────────────────────────────┘
```

## Components

- **Dockerfile** — `node:22-slim` + `git`, `openssh-client`, `gh`, `glab`, `opencode-ai`, `@getpaseo/cli`, and `wrangler`. `ENTRYPOINT` runs `entrypoint.sh`; `CMD` runs `paseo daemon run --home /workspace/paseo` (the main process on `$PORT`, default 8080).
- **entrypoint.sh** — runs on every boot:
  1. Constructs `/workspace` volume directory structure and symlinks Paseo (`~/.paseo`), OpenCode (`opencode.json`), skills, MCP servers, Wrangler, and SSH keys onto `/workspace`.
  2. Generates an ed25519 SSH key (`~/.ssh/id_ed25519`) on first boot and trusts `github.com` & `gitlab.com`.
  3. Authenticates `gh` from `GITHUB_TOKEN` and `glab` from `GITLAB_TOKEN`/`GLAB_TOKEN` if provided.
  4. Resolves `PASEO_PASSWORD` (persisted at `/workspace/.paseo-password` if unset; backwards compatible with `OPENCHAMBER_UI_PASSWORD`).
  5. Pre-seeds Paseo config to disable heavy local speech downloads, preserving memory and disk on cloud containers.
  6. Writes `/etc/profile.d/00-paseo-env.sh` so SSH login shells export provider keys, cloud tokens, and land in `/workspace/repos`.
- **railway.json** — Dockerfile builder + ON_FAILURE restart policy.
- **Public domain** — Railway maps HTTPS requests on port `$PORT` to Paseo daemon & web UI.
- **Volume** — Mounted at `/workspace`; the single source of persistent state.

## Design Choices

- **Two surfaces, one service.** `paseo daemon` is the main process behind the public domain; `railway ssh` reaches the same container for the `opencode` TUI and `paseo` CLI. Both share `/workspace`, auth, and repos.
- **Lean memory profile.** OpenCode is launched on-demand by Paseo or via SSH CLI rather than running as a permanent idle background process, cutting idle RAM usage by ~50%.
- **Volume-first persistence.** All mutable state is symlinked onto `/workspace`, ensuring redeploys keep your auth, sessions, MCP servers, skills, Wrangler tokens, and repos intact.
