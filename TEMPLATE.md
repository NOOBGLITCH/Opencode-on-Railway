# Deploy and Host OpenChamber & OpenCode on Railway

<p align="center">
  <img src="https://raw.githubusercontent.com/NOOBGLITCH/Opencode-on-Railway/main/assets/hero.png" alt="OpenChamber & OpenCode — open-source AI coding agent workspace" width="720">
</p>

[OpenChamber](https://openchamber.dev) and [OpenCode](https://opencode.ai) provide a complete, self-hosted **AI coding agent workstation** — reading your repo, writing and editing code, executing commands, running serverless deployments, and opening pull requests. This template provisions a Railway service with **two front doors**: a **browser web UI (OpenChamber)** on a public domain, and the **`opencode` terminal TUI** over `railway ssh` — both sharing one persistent `/workspace` volume with pre-installed DevOps tools (Wrangler, GitLab CLI, GitHub CLI, Git SSH).

## About Hosting OpenChamber & OpenCode

One container runs **`openchamber`** on a public, password-protected Railway domain; `railway ssh` into the same container gives you the **`opencode` TUI**. A `/workspace` volume keeps your repos, OpenCode settings (`opencode.json`), skills, MCP servers, Wrangler auth, and credentials across redeploys. Pre-installed tools include Cloudflare Wrangler (`wrangler`), GitLab CLI (`glab`), GitHub CLI (`gh`), and Git with auto-generated ed25519 SSH keys.

## Why Deploy on Railway?

- **Two front doors, one service** — a shareable browser **web UI** (*OpenChamber*) *and* terminal **TUI** (*OpenCode*) over SSH, both driving the same workspace and sessions.
- **Pre-installed DevOps Tooling** — Cloudflare Wrangler, GitLab CLI (`glab`), GitHub CLI (`gh`), and Git SSH are ready out of the box.
- **Your laptop can sleep** — the agent lives in the cloud; reopen the web link or `railway ssh` back in and pick up where you left off.
- **Secure by default** — the public web UI is password-protected (`OPENCHAMBER_UI_PASSWORD`); SSH is Railway-authenticated.
- **Zero-Data-Loss Volume Persistence** — repos, OpenCode configs (`opencode.json`), skills, MCP server configs, and Wrangler OAuth state sit on `/workspace`, surviving redeploys.
- **Provider-agnostic** — bring Anthropic, OpenAI, OpenRouter, Gemini, or DeepSeek API keys; switch models without rebuilding.

## Common Use Cases

- **A cloud coding-agent workstation** reachable from a browser link *or* the terminal.
- **Serverless & Edge Development** — build and deploy Cloudflare Workers and Pages with pre-installed `wrangler`.
- **GitLab & GitHub Automation** — manage issues, MRs, and PRs with `glab` and `gh`.
- **Long-running refactors or migrations** that keep going regardless of your local machine.

## Dependencies for OpenChamber & OpenCode on Railway

- A provider **API key** (`OPENROUTER_API_KEY`, `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `GEMINI_API_KEY`, or `DEEPSEEK_API_KEY`).
- The **Railway CLI** for terminal/TUI access (`railway ssh`); the web UI needs only a browser.

### Deployment Dependencies

- [OpenChamber](https://github.com/openchamber/openchamber) — Open-source agentic web UI workspace (`@openchamber/web` on npm).
- [OpenCode](https://github.com/anomalyco/opencode) — Open-source AI coding agent engine (`opencode-ai` on npm).
- [Cloudflare Wrangler](https://developers.cloudflare.com/workers/wrangler/) — CLI for Workers & Pages (`wrangler` on npm).
- [GitLab CLI](https://gitlab.com/gitlab-org/cli) — Official GitLab CLI (`glab`).
- [GitHub CLI](https://cli.github.com/) — Official GitHub CLI (`gh`).

---

# Railway Template Creation & Publishing Guide

Here is the complete guide on how to create and publish a Railway Template using both the Railway CLI and the Virtual GUI Dashboard.

---

## 🛠 Method 1: Using the Railway CLI

### Step 1: Create a Draft Template

Run `railway templates create` from your project directory:

```bash
railway templates create --json
```

**Output**:

```json
{
  "id": "f3fcd487-d385-416d-841f-56210834653c",
  "code": "V7lUun",
  "editorUrl": "https://railway.com/workspace/templates/f3fcd487-d385-416d-841f-56210834653c",
  "status": "UNPUBLISHED"
}
```

---

### Step 2: Write the Template Markdown File (`TEMPLATE.md`)

Create a `TEMPLATE.md` file in your repository. Railway's validator strictly requires a `## Dependencies for <Title>` heading:

```markdown
# Deploy and Host Your-App-Name on Railway

<p align="center">
  <img src="https://raw.githubusercontent.com/your-user/your-repo/main/assets/hero.png" width="720">
</p>

Overview of what your app does, features, and why users should deploy it.

## About Hosting Your-App-Name

Details about container process, persistent storage, and architecture.

## Dependencies for Your-App-Name on Railway

- Required environment variables (e.g., `API_KEY`, `DATABASE_URL`).

### Deployment Dependencies

- Tooling, frameworks, or database services included.
```

---

### Step 3: Publish via CLI Command

```bash
railway templates publish <DRAFT_ID> \
  --category AI/ML \
  --description "Short description under 75 characters" \
  --readme-file TEMPLATE.md \
  --image https://raw.githubusercontent.com/your-user/your-repo/main/assets/card.png \
  --json
```

**Valid Categories**: `AI/ML`, `Analytics`, `Authentication`, `Automation`, `Bots`, `CMS`, `Observability`, `Starters`, `Storage`, `Queues`, `Other`.

---

## 🖥 Method 2: Using the Virtual GUI Dashboard

### Step 1: Open the Railway Templates Studio

1. Open your browser and navigate to `https://railway.com/workspace/templates`.
2. Click **+ New Template** (or open your draft `editorUrl`).

---

### Step 2: Configure the Interactive Canvas & Inspector

1. **Select Source Project**: Pick the project and environment to snapshot.
2. **Service Node Settings**:
   - Click the Service node on the canvas.
   - Set **Service Name**, **Icon**, and **Root Directory** (e.g. `opencode`).
3. **Volume Node Settings**:
   - Ensure the persistent Volume node is connected to the service with mount path `/workspace`.
4. **Environment Variables Tab**:
   - Review captured variables (`OPENROUTER_API_KEY`, `OPENCHAMBER_UI_PASSWORD`).
   - Toggle variables as **Required** or **Optional** (values are never stored, only names).
5. **Markdown Overview Editor**:
   - Paste your `TEMPLATE.md` content into the **Overview / Readme** text box.
6. **Card & Metadata**:
   - Set **Category** (e.g. `AI/ML`).
   - Paste **Card Image URL** (e.g., `https://raw.githubusercontent.com/.../card.png`).

---

### Step 3: Publish in the Virtual GUI

Click **Publish Template** at the top right of the GUI. Your template will immediately go live with a shareable URL: `https://railway.com/deploy/<your-code>`.
