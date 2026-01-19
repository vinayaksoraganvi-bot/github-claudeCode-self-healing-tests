# Automated Test Fix Pipeline with Claude Code

<div align="center">

🤖 **Fully Automated CI/CD Pipeline** 🚀

*Tests fail? No problem! Claude Code automatically fixes them, creates a PR, and merges it.*

[![GitHub Actions](https://img.shields.io/badge/GitHub-Actions-2088FF?logo=github-actions&logoColor=white)](https://github.com/features/actions)
[![Claude Code](https://img.shields.io/badge/Claude-Code-FF6B6B?logo=anthropic&logoColor=white)](https://claude.ai/code)
[![Python](https://img.shields.io/badge/Python-3.11-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![Pytest](https://img.shields.io/badge/Pytest-7.4+-0A9EDC?logo=pytest&logoColor=white)](https://pytest.org/)

</div>

## 🎯 What This Does

This repository demonstrates a **fully automated test-fix-merge pipeline** using GitHub Actions and Claude Code:

```
Push Code → Tests Fail → Issue Created → Claude Fixes → PR Created → Auto-Merged ✅
```

### The Complete Flow

1. **Developer pushes code** with bugs
2. **GitHub Actions runs tests** automatically
3. **Tests fail** → Creates detailed GitHub issue with @claude mention
4. **Claude Code analyzes** the failures
5. **Claude fixes the code** and runs tests
6. **Claude creates a PR** with fixes
7. **Auto-merge detects PR** and checks out the branch
8. **Tests run directly** on the PR code to verify the fix
9. **PR gets merged** automatically if tests pass
10. **Issue is closed** with success message
11. **Tests run again** on main branch - all green! ✅

## 🚀 Quick Start

### Option 1: One-Command Setup (Recommended)

```bash
# Clone your repository
git clone https://github.com/vinayaksoraganvi-bot/github-claudeCode-self-healing-tests.git
cd github-claudeCode-self-healing-tests

# Run the setup script
chmod +x setup.sh
./setup.sh

# Follow the printed instructions
```

### Option 2: Use Claude Code CLI

```bash
# Install Claude Code
curl -fsSL https://claude.ai/install.sh | bash

# Navigate to your repository
cd github-claudeCode-self-healing-tests

# Let Claude set it up
claude
# Then run: /install-github-app
```

### Option 3: Manual Setup

See the [Configuration](#-configuration) and [How It Works](#-how-it-works) sections below for detailed manual setup instructions.

## 📁 Repository Structure

```
github-claudeCode-self-healing-tests/
├── .github/
│   └── workflows/
│       ├── automated-test-fix.yml      # Main automation workflow
│       └── claude-code-assistant.yml   # Claude Code integration
├── test_automation_demo.py             # Demo test with intentional bugs
├── requirements-dev.txt                # Testing dependencies
├── setup.sh                            # Quick setup script
├── START_HERE.md                       # Quick start guide
├── CHECKLIST.md                        # Setup verification checklist
├── SETUP_PAT.md                        # PAT setup instructions
└── README.md                           # This file
```

## 🔧 Configuration

### Required Secrets

Go to **Settings** → **Secrets and variables** → **Actions** → **New repository secret**:

| Secret Name | Description | Get it from | Required |
|------------|-------------|-------------|----------|
| `ANTHROPIC_API_KEY` | Your Anthropic API key | https://console.anthropic.com/ | ✅ Yes |
| `PAT_TOKEN` | Personal Access Token for workflow permissions | See [SETUP_PAT.md](SETUP_PAT.md) | ✅ Recommended |

**Note:** `PAT_TOKEN` is highly recommended for full automation. Without it, the auto-merge workflow may fail due to permission issues. See [SETUP_PAT.md](SETUP_PAT.md) for setup instructions.

### Required Permissions

Go to **Settings** → **Actions** → **General**:

- ✅ **Workflow permissions**: "Read and write permissions"
- ✅ **Allow GitHub Actions to create and approve pull requests**

## 📊 How It Works

### 1. Test Workflow (`automated-test-fix.yml`)

```yaml
Triggers: On push/PR to main or develop
Steps:
  1. Checkout code
  2. Install Python and dependencies
  3. Run pytest with JSON reporting
  4. If tests fail:
     - Analyze failures
     - Create GitHub issue with @claude mention
     - Start auto-merge monitoring workflow
```

### 2. Claude Code Assistant (`claude-code-assistant.yml`)

```yaml
Triggers: When @claude is mentioned in issues/PRs
Steps:
  1. Checkout code
  2. Setup Python environment
  3. Install dependencies
  4. Run Claude Code Action:
     - Read issue and test reports
     - Analyze root cause
     - Fix the code
     - Run tests to verify
     - Create PR with detailed description
```

### 3. Auto-Merge Workflow

```yaml
Part of automated-test-fix.yml
Steps:
  1. Wait for Claude to create PR (max 30 min)
  2. Checkout the PR branch
  3. Run tests directly on the PR code
  4. Auto-merge the PR if tests pass
  5. Close the issue with success message
  6. Comment on issue if tests fail
```

**Key Feature:** The workflow runs tests directly on the PR branch instead of waiting for external CI checks. This solves the chicken-and-egg problem where PRs created by bots don't trigger separate workflow runs.

## 🎬 Demo

🎥 [Demo video on YouTube](https://youtu.be/G-rCN5YOqb8)

Want to see it in action? Just push this test file:

```python
# test_automation_demo.py
def add(a, b):
    return a - b  # Bug: should be a + b

def test_addition():
    assert add(2, 3) == 5
```

Then watch the magic:
1. Tests fail → Issue #1 created
2. Claude analyzes → Finds the bug (subtraction instead of addition)
3. Claude fixes → Changes `a - b` to `a + b`
4. Claude creates PR #1 → "Fix add function in test_automation_demo.py"
5. Tests pass → PR auto-merged
6. Issue closed → "✅ Automatically Fixed & Merged"

## 🛠️ Customization

### Adjust Wait Times

In `automated-test-fix.yml`:

```yaml
maxWaitMinutes: 30        # Time to wait for Claude's PR
pollIntervalSeconds: 30   # Check interval
```

### Customize Claude's Behavior

In `claude-code-assistant.yml`:

```yaml
prompt: |
  Your custom instructions here...
  - Follow specific code style
  - Add specific comments
  - Run specific tests
```

### Disable Auto-Merge

```yaml
auto_merge:
  if: false  # Change to false to disable
```

### Protected Branches

Create `.github/auto-fix-config.yml`:

```yaml
protected_branches:
  - main
  - master
  - production

protected_files:
  - "*.sql"
  - "migrations/*"
  - ".env*"
```

## 📈 Monitoring

### View Workflow Runs
- Go to **Actions** tab
- Click on individual runs
- Check logs and artifacts

### Track Success Rate
- Monitor closed issues with "automated" label
- Review auto-merged PRs
- Check workflow run history

### Cost Monitoring
- Track API usage at https://console.anthropic.com/
- Set up billing alerts
- Monitor monthly costs

## 🔒 Security

### Best Practices

1. **Never commit API keys** - Use GitHub Secrets only
2. **Review auto-generated code** - Especially for production
3. **Set up CODEOWNERS** - For critical files
4. **Enable branch protection** - Require reviews for main
5. **Monitor API usage** - Set up billing alerts

### Recommended Settings

For **production** branches:
```yaml
# Branch protection rules
- Require pull request reviews
- Require status checks
- Don't allow auto-merge (review PRs manually)
```

For **development** branches:
```yaml
# More relaxed
- Allow auto-merge
- Require status checks only
```

## 🐛 Troubleshooting

### Tests Not Running
- ✅ Check GitHub Actions are enabled
- ✅ Verify workflow files are in `.github/workflows/`
- ✅ Check YAML syntax

### Claude Not Responding
- ✅ Verify `ANTHROPIC_API_KEY` secret is set
- ✅ Check API key has credits
- ✅ Look at Claude Code Action logs

### Auto-Merge Not Working
- ✅ Check branch protection settings
- ✅ Verify permissions are correct
- ✅ Ensure workflow has write access

### PRs Not Created
- ✅ Check Claude Code Action ran successfully
- ✅ Review error messages in logs
- ✅ Verify @claude mention is present

## 📚 Documentation

- [Quick Start Guide](START_HERE.md) - Getting started
- [Setup Checklist](CHECKLIST.md) - Step-by-step verification
- [PAT Setup](SETUP_PAT.md) - Personal Access Token configuration
- [Workflow Diagrams](WORKFLOW_DIAGRAM.md) - Visual flow documentation
- [Claude Code Docs](https://docs.claude.com/) - Official documentation
- [GitHub Actions Docs](https://docs.github.com/actions) - Workflow syntax
- [Anthropic API Docs](https://docs.anthropic.com/) - API reference

## 🎯 Real-World Use Cases

### 1. Continuous Integration
- Automatically fix broken tests in feature branches
- Maintain green build status
- Speed up development cycles

### 2. Code Quality
- Fix linting errors automatically
- Apply code style fixes
- Update deprecated API calls

### 3. Security Patches
- Apply security fixes from Dependabot
- Update vulnerable dependencies
- Fix common security issues

### 4. Documentation
- Keep docs in sync with code changes
- Fix documentation errors
- Update API documentation

## 🚧 Limitations

- Claude cannot fix all types of bugs (complex logic errors)
- Requires clear test failure messages
- API usage costs money (monitor your usage)
- Auto-merge should be used carefully in production
- Not suitable for security-critical fixes without review

## 🙏 Credits

- [Anthropic](https://www.anthropic.com/) - For Claude Code
- [GitHub Actions](https://github.com/features/actions) - For CI/CD platform

## 📧 Support

- 📖 [Documentation](README.md)
- 📋 [Setup Checklist](CHECKLIST.md)
- 💬 [GitHub Issues](https://github.com/vinayaksoraganvi-bot/github-claudeCode-self-healing-tests/issues)
- 🌐 [Anthropic Support](https://support.anthropic.com/)

---
