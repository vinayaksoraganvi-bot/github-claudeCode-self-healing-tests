# Setting Up Personal Access Token (PAT) for Full Automation

This guide explains how to enable fully automated workflow triggering without manual intervention.

## Why You Need a PAT

GitHub's default `GITHUB_TOKEN` has a security limitation: workflows using it cannot trigger other workflows. This prevents the automated test fix workflow from automatically triggering the Claude Code Assistant workflow.

**With PAT:** Tests fail → Issue created → Auto-fix workflow triggers → PR created → Auto-merged → Issue closed ✅

**Without PAT:** Tests fail → Issue created → ❌ *Manual comment needed* → Auto-fix workflow triggers → PR created → Auto-merged → Issue closed

## Setup Instructions

### Step 1: Create Personal Access Token

1. Go to GitHub Settings: https://github.com/settings/tokens

2. Click **Personal access tokens** → **Fine-grained tokens** → **Generate new token**

3. Configure the token:
   - **Name:** `automated-test-fix-workflow`
   - **Expiration:** 90 days (or your preference)
   - **Repository access:** Only select repositories → `github-claudecode-demo`
   - **Permissions:**
     - Contents: **Read and write**
     - Issues: **Read and write**
     - Pull requests: **Read and write**
     - Workflows: **Read and write**

4. Click **Generate token**

5. **Copy the token** (starts with `github_pat_...`)
   - ⚠️ Save it immediately - you won't see it again!

### Step 2: Add Token as Repository Secret

**Via GitHub Web UI:**

1. Go to repository Settings: https://github.com/vinayaksoraganvi-bot/github-claudecode-demo/settings/secrets/actions

2. Click **New repository secret**

3. Fill in:
   - **Name:** `PAT_TOKEN` (must be exactly this)
   - **Secret:** Paste your token

4. Click **Add secret**

**Via GitHub CLI:**

```bash
gh secret set PAT_TOKEN --body "YOUR_TOKEN_HERE"
```

### Step 3: Verify Setup

1. **Check the secret exists:**
   ```bash
   gh secret list
   ```
   You should see `PAT_TOKEN` in the list.

2. **Test the automation:**
   ```bash
   # Revert the bug to test the automation
   git commit --allow-empty -m "Test automation"
   git push
   ```

3. **Watch the magic happen:**
   - Tests run and fail
   - Issue created automatically
   - Claude Code Assistant triggers automatically (no manual comment needed!)
   - PR created automatically
   - PR merged automatically
   - Issue closed automatically

## How It Works

The workflow file now uses:

```yaml
github-token: ${{ secrets.PAT_TOKEN || secrets.GITHUB_TOKEN }}
```

This means:
- If `PAT_TOKEN` is configured → Uses PAT (full automation)
- If `PAT_TOKEN` is not configured → Uses GITHUB_TOKEN (requires manual comment)

## Security Notes

- **Fine-grained tokens** are more secure than classic tokens
- Limit token to only the necessary repositories
- Set an expiration date (you'll need to renew it)
- Never commit tokens to your repository
- Tokens are encrypted in GitHub Secrets

## Troubleshooting

**Workflow fails with "Resource not accessible":**
- Check that PAT_TOKEN secret is set correctly
- Verify token has required permissions

**Workflow still requires manual comment:**
- Ensure PAT_TOKEN is named exactly `PAT_TOKEN`
- Check token hasn't expired
- Verify token permissions include "Workflows: Read and write"

**Token expired:**
- Generate a new token (follow Step 1 again)
- Update the PAT_TOKEN secret with the new value

## Alternative: Classic Token (Simpler, Less Secure)

If you prefer a classic token:

1. Go to https://github.com/settings/tokens
2. Click **Generate new token (classic)**
3. Select scopes:
   - ✅ `repo` (Full control of private repositories)
   - ✅ `workflow` (Update GitHub Action workflows)
4. Generate and copy token
5. Add as `PAT_TOKEN` secret (same as Step 2 above)

---

**Current Status:** The workflow is configured to use PAT_TOKEN. Once you add the secret, the full automation will work without any manual intervention!
