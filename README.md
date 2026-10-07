# Paseo & OpenCode on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/opencode-devbox)

A high-performance, lightweight, cloud-native AI developer workstation on **Railway** featuring **[Paseo](https://paseo.sh)** (the open-source coding agent control plane & web UI) and **[OpenCode AI](https://opencode.ai)** with **pre-installed DevOps tooling** (Wrangler, GitLab CLI, GitHub CLI, Git SSH) and **zero-data-loss volume persistence**.

---

## 🌟 Key Features

- 🌐 **Paseo Web UI & Daemon**: Ultra-lean agent control plane accessible on your public Railway domain with password protection (`PASEO_PASSWORD`).
- 💻 **OpenCode Terminal TUI & CLI**: Connect anytime via `railway ssh` and run `opencode` or `opencode run "..."` or drive agents via `paseo`.
- ⚡ **50% Less Memory**: Replaces heavy multi-process setups with a single, efficient daemon, saving ~200MB RAM on Railway.
- ☁️ **Full Tooling Suite Included**:
  - **Cloudflare Wrangler CLI** (`wrangler`): Deploy Workers, KV, D1, R2, Vectorize, and Pages.
  - **GitLab CLI** (`glab`): Manage GitLab repositories, MRs, pipelines, and issues.
  - **GitHub CLI** (`gh`): Manage GitHub repositories, PRs, and issues.
  - **Git & SSH**: Pre-generated ed25519 SSH keys (`~/.ssh/id_ed25519`) with auto-trusted host keys.
- 💾 **Absolute Zero Data Loss (`/workspace` Volume)**:
  - Paseo configs, agent registries, & state (`/workspace/paseo` ➔ `~/.paseo`)
  - OpenCode configs (`opencode.json` / `opencode.jsonc`), sessions, & auth
  - Custom Agent Skills (`/workspace/skills` ➔ `~/.skills`, `~/skills`)
  - MCP Server Configurations (`/workspace/mcp` ➔ `~/.mcp`)
  - Cloudflare Wrangler Auth & Cache (`/workspace/wrangler` ➔ `~/.wrangler`, `~/.config/wrangler`)
  - Repositories (`/workspace/repos`) & SSH Keys (`/workspace/.ssh`)

---

## 🚀 Quick Start

1. **Deploy to Railway**: Click the deploy button above or run `railway up` using the Railway CLI.
2. **Configure Provider Keys (Optional)**: Set LLM provider keys in your Railway Variables:
   - `OPENROUTER_API_KEY`, `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `GEMINI_API_KEY`, `DEEPSEEK_API_KEY`
   - `PASEO_PASSWORD` (Web UI password, auto-generated in deploy logs if unset; backwards compatible with `OPENCHAMBER_UI_PASSWORD`)
   - `GITHUB_TOKEN`, `GITLAB_TOKEN`, `CLOUDFLARE_API_TOKEN`
3. **Access Web UI**: Open your service's public domain URL in a browser and log in with your `PASEO_PASSWORD`.
4. **Access Terminal TUI via SSH**:
   ```bash
   railway link          # Link project & service
   railway ssh           # SSH into live container
   opencode              # Launch OpenCode TUI
   # or manage agents with Paseo:
   paseo ls
   ```
5. **Clone Repos & Work**:
   ```bash
   cd /workspace/repos
   git clone git@github.com:your-username/your-repo.git
   ```

---

## 🛠 Included Tooling

| Tool | Purpose | CLI Command |
|------|---------|-------------|
| **Paseo Daemon & Web UI** | Multi-agent control plane & browser UI | `paseo` |
| **OpenCode AI** | Open-source AI coding agent engine | `opencode` / `opencode run` |
| **Cloudflare Wrangler** | Serverless Workers, KV, D1, R2 | `wrangler` |
| **GitLab CLI** | GitLab MRs, issues, & pipelines | `glab` |
| **GitHub CLI** | GitHub PRs, issues, & gists | `gh` |
| **Git & OpenSSH** | Version control & ed25519 SSH keys | `git` / `ssh` |

---

## 📁 Persistent Volume Layout (`/workspace`)

| Directory | Symlinked Path | Contents |
|-----------|----------------|----------|
| `/workspace/paseo` | `~/.paseo` | Paseo daemon configs, projects, worktrees, & agent state |
| `/workspace/opencode/config` | `~/.config/opencode` | `opencode.json` / `opencode.jsonc` configs |
| `/workspace/opencode/data` | `~/.local/share/opencode` | OpenCode state & auth |
| `/workspace/skills` | `~/.skills`, `~/skills` | Custom agent skills |
| `/workspace/mcp` | `~/.mcp` | MCP server configurations |
| `/workspace/wrangler` | `~/.wrangler`, `~/.config/wrangler` | Wrangler auth, OAuth, & deployment cache |
| `/workspace/repos` | `/workspace/repos` | Cloned git repositories |
| `/workspace/.ssh` | `~/.ssh` | SSH keys & `known_hosts` |

---

## 📜 Documentation & Guides

- [`docs/USAGE.md`](docs/USAGE.md) — Detailed user guide and CLI walkthrough.
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — Architecture, container wiring, and volume layout.
- [`docs/PUBLISH.md`](docs/PUBLISH.md) — Template publishing guide.
