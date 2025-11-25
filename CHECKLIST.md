# Setup Checklist for Automated Test Fix Pipeline

Use this checklist to ensure everything is configured correctly before going live.

## Pre-Setup Checklist

- [ ] Admin access to GitHub repository
- [ ] Anthropic API key (or Claude Pro subscription)
- [ ] Python project with pytest tests
- [ ] Git installed and configured locally

## Installation Checklist

### 1. Repository Setup

- [ ] Cloned repository locally
- [ ] Checked out main/develop branch
- [ ] Repository is clean (no uncommitted changes)

### 2. Workflow Files

- [ ] Created `.github/workflows/` directory
- [ ] Added `automated-test-fix.yml` workflow
- [ ] Added `claude-code-assistant.yml` workflow
- [ ] Verified YAML syntax (no errors)
- [ ] Committed workflow files to repository

### 3. GitHub Secrets

- [ ] Navigated to Settings → Secrets and variables → Actions
- [ ] Created `ANTHROPIC_API_KEY` secret
- [ ] Verified API key starts with `sk-ant-`
- [ ] Tested API key works (made a test API call)
- [ ] Created `PAT_TOKEN` secret (highly recommended)
- [ ] Verified PAT has required permissions (see SETUP_PAT.md)

### 4. GitHub Actions Permissions

Go to: Settings → Actions → General

- [ ] Selected "Read and write permissions"
- [ ] Enabled "Allow GitHub Actions to create and approve pull requests"
- [ ] Saved changes

### 5. Branch Protection Rules (Optional)

Go to: Settings → Branches → Add rule

For **main** branch:
- [ ] Created branch protection rule
- [ ] Enabled "Require a pull request before merging"
- [ ] Enabled "Require status checks to pass before merging"
- [ ] Added required check: "Run Tests"
- [ ] Decided on approvals (disable for auto-merge OR use PAT)
- [ ] Saved rule

For **develop** branch (if using):
- [ ] Created similar rule with preferred settings

### 6. Test Dependencies

- [ ] Created `requirements-dev.txt` with:
  - [ ] pytest>=7.4.0
  - [ ] pytest-json-report>=1.5.0
  - [ ] pytest-html>=3.2.0
- [ ] Installed dependencies locally: `pip install -r requirements-dev.txt`
- [ ] Verified pytest works: `pytest --version`

### 7. Demo Test File

- [ ] Created `test_automation_demo.py` with intentional bugs
- [ ] Verified tests fail locally: `pytest test_automation_demo.py`
- [ ] Committed test file

## Verification Checklist

### 8. First Run Test

- [ ] Pushed changes to GitHub
- [ ] Navigated to Actions tab
- [ ] Workflow "Automated Test Fix with Claude Code" started
- [ ] Tests ran and failed (as expected)
- [ ] Issue was created automatically
- [ ] Issue contains @claude mention
- [ ] Issue has "test-failure" label

### 9. Claude Code Response

Wait for Claude Code to respond (~3-5 minutes):

- [ ] Claude Code Action workflow started
- [ ] Claude analyzed the issue
- [ ] Claude created a fix branch
- [ ] Claude created a pull request
- [ ] PR has clear title and description
- [ ] PR references the original issue

### 10. Auto-Merge Verification

Wait for auto-merge (~2-3 minutes):

- [ ] Auto-merge workflow detected the PR
- [ ] Workflow checked out the PR branch
- [ ] Tests ran directly on the PR code
- [ ] All tests passed
- [ ] PR was merged automatically
- [ ] Original issue was closed
- [ ] Success comment added to issue

### 11. Final Verification

- [ ] Tests are now passing on main branch
- [ ] No open issues remain
- [ ] Git history shows the auto-merge commit
- [ ] No workflow errors in Actions tab

## Post-Setup Checklist

### 12. Customization (Optional)

- [ ] Adjusted auto-merge wait times
- [ ] Customized Claude's instructions
- [ ] Added protected files configuration
- [ ] Set up Slack/email notifications
- [ ] Configured branch-specific behavior

### 13. Documentation

- [ ] Read README.md
- [ ] Read START_HERE.md
- [ ] Read SETUP_PAT.md
- [ ] Reviewed WORKFLOW_DIAGRAM.md
- [ ] Bookmarked important links

### 14. Monitoring Setup

- [ ] Set up Anthropic Console billing alerts
- [ ] Bookmarked GitHub Actions page
- [ ] Configured notification preferences
- [ ] Set up cost tracking (if needed)

### 15. Team Communication

- [ ] Informed team about new automation
- [ ] Shared documentation
- [ ] Explained how to use @claude mentions
- [ ] Set expectations for auto-merge behavior

## Troubleshooting Checklist

If something isn't working, check:

### Tests Not Running
- [ ] Workflow file is in `.github/workflows/`
- [ ] YAML syntax is valid (use YAML validator)
- [ ] Branch name matches trigger condition
- [ ] GitHub Actions are enabled for repository

### Issue Not Created
- [ ] Tests actually failed (not passed)
- [ ] Workflow has `issues: write` permission
- [ ] No syntax errors in issue creation step
- [ ] Check workflow logs for errors

### Claude Not Responding
- [ ] `ANTHROPIC_API_KEY` secret is set correctly
- [ ] API key has available credits
- [ ] @claude mention is present in issue
- [ ] Claude Code Action workflow was triggered
- [ ] Check Claude Code Action logs

### PR Not Created
- [ ] Claude Code Action completed successfully
- [ ] Check for error messages in logs
- [ ] Repository permissions are correct
- [ ] No merge conflicts exist

### Auto-Merge Not Working
- [ ] Branch protection allows merges
- [ ] Workflow has `contents: write` permission
- [ ] All CI checks passed
- [ ] No required reviewers blocking
- [ ] Check auto-merge workflow logs

### Persistent Issues
- [ ] Reviewed all workflow logs
- [ ] Checked GitHub Actions quota
- [ ] Verified API rate limits
- [ ] Contacted Anthropic support if needed
- [ ] Asked in GitHub Issues

## Security Checklist

### 16. Security Review

- [ ] API key stored as secret (not in code)
- [ ] Secrets are not logged in workflows
- [ ] Branch protection rules in place
- [ ] CODEOWNERS file created (for critical files)
- [ ] Auto-merge disabled for production (if required)
- [ ] Code signing configured (if required)
- [ ] Security scanning enabled
- [ ] Dependabot alerts enabled

### 17. Access Control

- [ ] Reviewed who has repository admin access
- [ ] Reviewed who can approve PRs
- [ ] Verified secret access is restricted
- [ ] Checked workflow permissions are minimal
- [ ] Configured required reviews (if needed)

## Maintenance Checklist

### Weekly Tasks
- [ ] Review auto-generated PRs
- [ ] Check API usage and costs
- [ ] Monitor workflow success rate
- [ ] Review any failed automations

### Monthly Tasks
- [ ] Update dependencies in workflows
- [ ] Review and optimize Claude prompts
- [ ] Analyze automation metrics
- [ ] Rotate API keys (if policy requires)
- [ ] Update documentation if needed

### Quarterly Tasks
- [ ] Full security audit
- [ ] Review branch protection rules
- [ ] Update workflows to latest versions
- [ ] Train team on new features
- [ ] Evaluate cost vs. benefit

## Success Metrics

Track these metrics to measure success:

### Automation Success
- [ ] % of tests fixed automatically: _____%
- [ ] % of PRs auto-merged: _____%
- [ ] % of issues closed without human intervention: _____%

### Time Savings
- [ ] Average time from failure to fix: _____ minutes
- [ ] Time saved per week: _____ hours
- [ ] Developer hours saved: _____ hours

### Cost Analysis
- [ ] Monthly API costs: $_____
- [ ] Cost per fix: $_____
- [ ] ROI (time saved vs. cost): _____%

### Quality Metrics
- [ ] False fix rate: _____%
- [ ] Tests still failing after fix: _____%
- [ ] Manual interventions required: _____%

## Sign-Off

I confirm that I have:
- [ ] Completed all required setup steps
- [ ] Tested the automation end-to-end
- [ ] Reviewed security considerations
- [ ] Documented any customizations
- [ ] Informed relevant team members
- [ ] Set up monitoring and alerts

**Setup completed by:** _________________  
**Date:** _________________  
**Repository:** vinayaksoraganvi-bot/github-claudecode-demo  
**Environment:** Production / Staging / Development (circle one)

## Quick Reference Links

- 🚀 [README](README.md)
- 📖 [Quick Start](START_HERE.md)
- 🔑 [PAT Setup](SETUP_PAT.md)
- 📊 [Workflow Diagram](WORKFLOW_DIAGRAM.md)
- 🏃 [Actions](https://github.com/vinayaksoraganvi-bot/github-claudecode-demo/actions)
- 🔐 [Secrets](https://github.com/vinayaksoraganvi-bot/github-claudecode-demo/settings/secrets/actions)
- ⚙️ [Settings](https://github.com/vinayaksoraganvi-bot/github-claudecode-demo/settings)
- 💰 [Anthropic Console](https://console.anthropic.com/)
- 📚 [Claude Code Docs](https://docs.claude.com/)

---

**Pro Tips:**

✅ Start with manual PR approval, then enable auto-merge later  
✅ Test on a development branch first  
✅ Review the first few auto-fixes carefully  
✅ Set up billing alerts to avoid surprises  
✅ Document any custom configurations  

Good luck! 🚀
