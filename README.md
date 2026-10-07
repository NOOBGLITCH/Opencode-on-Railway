# OpenCode on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/opencode-devbox)

A high-performance, lightweight, cloud-native AI developer workstation on **Railway** featuring the official **[OpenCode AI](https://opencode.ai)** web server (`opencode serve`) and terminal TUI with **pre-installed DevOps tooling** (Wrangler, GitLab CLI, GitHub CLI, Git SSH) and **zero-data-loss volume persistence**.

---

## 🌟 Key Features

- 🌐 **OpenCode Web UI**: Native browser web UI served directly via `opencode serve` with custom password protection (`OPENCODE_SERVER_PASSWORD`).
- 💻 **OpenCode Terminal TUI & CLI**: Connect anytime via `railway ssh` and run `opencode` or `opencode run "..."`.
- ⚡ **Lightweight & Fast**: Lean single-process setup with Bun, zRAM, and low memory footprint.
- ☁️ **Full Tooling Suite Included**:
  - **Cloudflare Wrangler CLI** (`wrangler`): Deploy Workers, KV, D1, R2, Vectorize, and Pages.
  - **GitLab CLI** (`glab`): Manage GitLab repositories, MRs, pipelines, and issues.
  - **GitHub CLI** (`gh`): Manage GitHub repositories, PRs, and issues.
  - **Git & SSH**: Pre-generated ed25519 SSH keys (`~/.ssh/id_ed25519`) with auto-trusted host keys.
- 💾 **Absolute Zero Data Loss (`/workspace` Volume)**:
  - OpenCode configs (`opencode.json` / `opencode.jsonc`), sessions, & auth (`/workspace/opencode` ➔ `~/.opencode`, `~/.local/share/opencode`)
  - Custom Agent Skills (`/workspace/skills` ➔ `~/.skills`, `~/skills`)
  - MCP Server Configurations (`/workspace/mcp` ➔ `~/.mcp`)
  - Cloudflare Wrangler Auth & Cache (`/workspace/wrangler` ➔ `~/.wrangler`, `~/.config/wrangler`)
  - Repositories (`/workspace/repos`) & SSH Keys (`/workspace/.ssh`)

---

## 🚀 Quick Start

1. **Deploy to Railway**: Click the deploy button above or run `railway up` using the Railway CLI.
2. **Configure Provider Keys (Optional)**: Set LLM provider keys in your Railway Variables:
   - `OPENROUTER_API_KEY`, `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `GEMINI_API_KEY`, `DEEPSEEK_API_KEY`
   - `OPENCODE_SERVER_PASSWORD` (Web UI password, auto-generated in deploy logs if unset; backwards compatible with `PASEO_PASSWORD` and `OPENCHAMBER_UI_PASSWORD`)
   - `GITHUB_TOKEN`, `GITLAB_TOKEN`, `CLOUDFLARE_API_TOKEN`
3. **Access Web UI**: Open your service's public domain URL in a browser and log in with your `OPENCODE_SERVER_PASSWORD`.
4. **Access Terminal TUI via SSH**:
   ```bash
   railway link          # Link project & service
   railway ssh           # SSH into live container
   opencode              # Launch OpenCode TUI
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
| **OpenCode AI Web Server** | Official web UI & HTTP API | `opencode serve` |
| **OpenCode AI CLI** | Terminal TUI & autonomous CLI agent | `opencode` / `opencode run` |
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
