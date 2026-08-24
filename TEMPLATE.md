# Deploy and Host OpenChamber & OpenCode on Railway

<p align="center">
  <img src="https://raw.githubusercontent.com/NOOBGLITCH/opencode-railway/main/assets/hero.png" alt="OpenChamber & OpenCode — open-source AI coding agent workspace" width="720">
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

## Dependencies

- A provider **API key** (`OPENROUTER_API_KEY`, `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `GEMINI_API_KEY`, or `DEEPSEEK_API_KEY`).
- The **Railway CLI** for terminal/TUI access (`railway ssh`); the web UI needs only a browser.

### Deployment Dependencies

- [OpenChamber](https://github.com/openchamber/openchamber) — Open-source agentic web UI workspace (`@openchamber/web` on npm).
- [OpenCode](https://github.com/anomalyco/opencode) — Open-source AI coding agent engine (`opencode-ai` on npm).
- [Cloudflare Wrangler](https://developers.cloudflare.com/workers/wrangler/) — CLI for Workers & Pages (`wrangler` on npm).
- [GitLab CLI](https://gitlab.com/gitlab-org/cli) — Official GitLab CLI (`glab`).
- [GitHub CLI](https://cli.github.com/) — Official GitHub CLI (`gh`).

### Why This Template?

One click gives you OpenChamber & OpenCode with pre-installed DevOps tools, two front doors (browser UI + SSH TUI), and volume-backed zero data loss across every redeploy. Source and docs: <https://github.com/NOOBGLITCH/opencode-railway>.
