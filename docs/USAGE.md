# Usage — Web UI & Railway SSH Guide

This developer box offers two entry points: **OpenChamber Web UI** on your public domain, and the **OpenCode TUI** via `railway ssh`. Everything lives on the `/workspace` persistent volume.

---

## 1. Setup & Environment Variables

Set provider and tooling keys in the Railway **Variables** tab:

- **LLM Providers**: `OPENROUTER_API_KEY`, `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `GEMINI_API_KEY`, `DEEPSEEK_API_KEY`
- **Web UI Protection**: `OPENCHAMBER_UI_PASSWORD` (auto-generated in deploy logs if unset)
- **DevOps & Cloud Tokens**: `GITHUB_TOKEN`, `GITLAB_TOKEN` (or `GLAB_TOKEN`), `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`
- **Git Identity**: `GIT_USER_NAME`, `GIT_USER_EMAIL`

---

## 2. Accessing the OpenChamber Web UI

1. Open your service's public domain (e.g. `https://your-project.up.railway.app`) in your browser.
2. Enter your password (`OPENCHAMBER_UI_PASSWORD` or the auto-generated password printed in Railway deploy logs).

---

## 3. Connecting via Terminal (`railway ssh`)

```bash
# Install Railway CLI locally (if needed)
npm i -g @railway/cli      # or: brew install railway
railway login

# Link and SSH into the live container
railway link
railway ssh
```

Once inside, launch the OpenCode TUI:
```bash
opencode
```

---

## 4. Pre-Installed CLI Tools

### Cloudflare Wrangler (`wrangler`)
```bash
wrangler whoami
wrangler deploy
```
*(OAuth state and tokens persist in `/workspace/wrangler`).*

### GitLab CLI (`glab`)
```bash
glab mr list
glab issue create
```

### GitHub CLI (`gh`)
```bash
gh pr list
gh issue create
```

---

## 5. Working with Git Repositories

Clone repos into `/workspace/repos` so they persist across redeploys:

```bash
cd /workspace/repos
git clone git@github.com:your-username/your-repo.git
```

Add your box's generated SSH key to GitHub/GitLab:
```bash
cat ~/.ssh/id_ed25519.pub
```

---

## 6. Housekeeping

```bash
# Update OpenCode or OpenChamber
opencode upgrade
df -h /workspace        # Check volume usage
```
