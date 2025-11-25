#!/bin/bash

# Automated Test Fix Pipeline - Quick Setup Script
# This script sets up the complete CI/CD pipeline for your repository

set -e

REPO_URL="https://github.com/vinayaksoraganvi-bot/github-claudeCode-self-healing-tests"
REPO_NAME="github-claudeCode-self-healing-tests"

echo "🚀 Setting up Automated Test Fix Pipeline"
echo "========================================"
echo ""

# Check if we're in a git repository
if [ ! -d .git ]; then
    echo "❌ Error: Not in a git repository!"
    echo "Please run this script from your repository root."
    exit 1
fi

# Create .github/workflows directory if it doesn't exist
echo "📁 Creating workflow directory..."
mkdir -p .github/workflows

# Copy workflow files
echo "📝 Setting up workflow files..."

# 1. Automated Test Fix Workflow
cat > .github/workflows/automated-test-fix.yml << 'EOF'
name: Automated Test Fix with Claude Code

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

permissions:
  contents: write
  issues: write
  pull-requests: write
  id-token: write
  actions: read

jobs:
  test:
    name: Run Tests
    runs-on: ubuntu-latest
    outputs:
      tests_failed: ${{ steps.test.outcome == 'failure' }}
      issue_number: ${{ steps.create_issue.outputs.issue_number }}

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
          cache: 'pip'

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install pytest pytest-json-report pytest-html
          if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
          if [ -f requirements-dev.txt ]; then pip install -r requirements-dev.txt; fi

      - name: Run tests
        id: test
        continue-on-error: true
        run: |
          pytest -v \
            --json-report \
            --json-report-file=test-report.json \
            --html=test-report.html \
            --self-contained-html

      - name: Upload test reports
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: test-reports
          path: |
            test-report.json
            test-report.html

      - name: Analyze failures
        if: steps.test.outcome == 'failure'
        id: analyze
        run: |
          python << 'PYTHON_EOF'
          import json
          import os

          with open('test-report.json', 'r') as f:
              report = json.load(f)

          failures = [t for t in report.get('tests', []) if t['outcome'] == 'failed']

          summary = f"# 🔴 Test Failures Detected\n\n"
          summary += f"**Commit:** {os.environ['GITHUB_SHA'][:7]}\n"
          summary += f"**Branch:** {os.environ['GITHUB_REF_NAME']}\n"
          summary += f"**Failed Tests:** {len(failures)}\n\n"
          summary += "## Failed Tests\n\n"

          for i, failure in enumerate(failures, 1):
              summary += f"### {i}. `{failure['nodeid']}`\n"
              error = failure.get('call', {}).get('longrepr', 'Unknown error')
              summary += f"```\n{error[:500]}\n```\n\n"

          with open('failure-summary.md', 'w') as f:
              f.write(summary)

          with open(os.environ['GITHUB_OUTPUT'], 'a') as f:
              f.write(f"failure_count={len(failures)}\n")
          PYTHON_EOF

      - name: Create issue for failures
        if: steps.test.outcome == 'failure'
        id: create_issue
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const summary = fs.readFileSync('failure-summary.md', 'utf8');

            const issue = await github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: `🔴 Test Failures - ${context.sha.substring(0, 7)}`,
              body: `${summary}\n\n@claude please analyze these test failures and create a PR to fix them.\n\n---\n**Workflow Run:** ${context.serverUrl}/${context.repo.owner}/${context.repo.repo}/actions/runs/${context.runId}`,
              labels: ['bug', 'automated', 'test-failure']
            });

            console.log(`Created issue #${issue.data.number}`);
            return issue.data.number;

  auto_merge:
    name: Auto-merge Claude's Fix PR
    needs: test
    if: needs.test.outputs.tests_failed == 'true'
    runs-on: ubuntu-latest

    steps:
      - name: Wait for Claude to create PR
        id: wait_pr
        uses: actions/github-script@v7
        with:
          script: |
            const issueNumber = ${{ needs.test.outputs.issue_number }};
            const maxWaitMinutes = 30;
            const pollIntervalSeconds = 30;
            const maxIterations = (maxWaitMinutes * 60) / pollIntervalSeconds;

            console.log(`Waiting for PR linked to issue #${issueNumber}...`);

            for (let i = 0; i < maxIterations; i++) {
              const { data: prs } = await github.rest.pulls.list({
                owner: context.repo.owner,
                repo: context.repo.repo,
                state: 'open',
                sort: 'created',
                direction: 'desc',
                per_page: 10
              });

              const claudePR = prs.find(pr =>
                pr.user.login.includes('claude') &&
                pr.body && pr.body.includes(`#${issueNumber}`)
              );

              if (claudePR) {
                console.log(`Found PR #${claudePR.number}`);
                return claudePR.number;
              }

              if (i < maxIterations - 1) {
                console.log(`Attempt ${i + 1}/${maxIterations}: No PR yet, waiting ${pollIntervalSeconds}s...`);
                await new Promise(resolve => setTimeout(resolve, pollIntervalSeconds * 1000));
              }
            }

            throw new Error('Timeout waiting for Claude to create PR');

      - name: Wait for PR checks to pass
        uses: actions/github-script@v7
        with:
          script: |
            const prNumber = ${{ steps.wait_pr.outputs.result }};
            const maxWaitMinutes = 15;
            const pollIntervalSeconds = 20;
            const maxIterations = (maxWaitMinutes * 60) / pollIntervalSeconds;

            for (let i = 0; i < maxIterations; i++) {
              const { data: pr } = await github.rest.pulls.get({
                owner: context.repo.owner,
                repo: context.repo.repo,
                pull_number: prNumber
              });

              const { data: checks } = await github.rest.checks.listForRef({
                owner: context.repo.owner,
                repo: context.repo.repo,
                ref: pr.head.sha
              });

              const allChecks = checks.check_runs;
              const relevantChecks = allChecks.filter(check =>
                check.name !== 'Auto-merge Claude\'s Fix PR'
              );

              if (relevantChecks.length > 0) {
                const allComplete = relevantChecks.every(check =>
                  check.status === 'completed'
                );
                const allSuccess = relevantChecks.every(check =>
                  check.conclusion === 'success'
                );

                if (allComplete && allSuccess) {
                  console.log('✅ All checks passed!');
                  return true;
                } else if (allComplete && !allSuccess) {
                  throw new Error('Some checks failed');
                }
              }

              await new Promise(resolve => setTimeout(resolve, pollIntervalSeconds * 1000));
            }

            return false;

      - name: Auto-merge PR
        uses: actions/github-script@v7
        with:
          script: |
            const prNumber = ${{ steps.wait_pr.outputs.result }};
            const issueNumber = ${{ needs.test.outputs.issue_number }};

            try {
              await github.rest.pulls.merge({
                owner: context.repo.owner,
                repo: context.repo.repo,
                pull_number: prNumber,
                merge_method: 'squash',
                commit_title: `🤖 Auto-fix: Resolve test failures (#${issueNumber})`,
                commit_message: 'Automatically fixed by Claude Code and merged via CI/CD pipeline'
              });

              await github.rest.issues.update({
                owner: context.repo.owner,
                repo: context.repo.repo,
                issue_number: issueNumber,
                state: 'closed',
                state_reason: 'completed'
              });

              await github.rest.issues.createComment({
                owner: context.repo.owner,
                repo: context.repo.repo,
                issue_number: issueNumber,
                body: `✅ **Automatically Fixed & Merged**\n\nFixed in PR #${prNumber} and automatically merged.\n\nAll tests are now passing! 🎉`
              });

            } catch (error) {
              console.error(`Failed to merge: ${error.message}`);

              await github.rest.issues.createComment({
                owner: context.repo.owner,
                repo: context.repo.repo,
                issue_number: issueNumber,
                body: `⚠️ PR #${prNumber} was created but auto-merge failed: ${error.message}\n\nPlease review and merge manually.`
              });

              throw error;
            }
EOF

echo "✅ Created automated-test-fix.yml"

# 2. Claude Code Assistant Workflow
cat > .github/workflows/claude-code-assistant.yml << 'EOF'
name: Claude Code Assistant

on:
  issue_comment:
    types: [created]
  issues:
    types: [opened, assigned]
  pull_request_review_comment:
    types: [created]
  pull_request_review:
    types: [submitted]

permissions:
  contents: write
  issues: write
  pull-requests: write
  id-token: write
  actions: read

jobs:
  claude:
    if: |
      (github.event_name == 'issue_comment' && contains(github.event.comment.body, '@claude')) ||
      (github.event_name == 'pull_request_review_comment' && contains(github.event.comment.body, '@claude')) ||
      (github.event_name == 'pull_request_review' && contains(github.event.review.body, '@claude')) ||
      (github.event_name == 'issues' && (contains(github.event.issue.body, '@claude') || contains(github.event.issue.labels.*.name, 'test-failure')))

    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Set up Python environment
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
          cache: 'pip'

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
          if [ -f requirements-dev.txt ]; then pip install -r requirements-dev.txt; fi
          pip install pytest pytest-json-report

      - name: Run Claude Code
        uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          claude_args: |
            {
              "model": "claude-sonnet-4-20250514",
              "maxTokens": 8000
            }
          prompt: |
            Please analyze the test failures in this issue, identify the root cause,
            and create a PR with fixes. Follow these guidelines:

            1. Run the tests first to understand the failures
            2. Analyze the error messages and stack traces
            3. Fix the implementation code (not the tests unless they're wrong)
            4. Ensure all tests pass after your changes
            5. Keep changes minimal and focused
            6. Add comments explaining complex fixes
            7. Follow the existing code style

            After fixing, create a PR with:
            - Clear title describing the fix
            - Detailed description of what was wrong and how you fixed it
            - Reference to this issue
EOF

echo "✅ Created claude-code-assistant.yml"

# Create a demo test file
echo ""
echo "📝 Creating demo test file..."
cat > test_automation_demo.py << 'EOF'
"""
Demo test file to verify the automated test fix pipeline.
This file intentionally contains bugs to trigger the automation.
"""

def add_numbers(a, b):
    """Add two numbers together."""
    # Intentional bug: subtracts instead of adds
    return a - b  # This should be: return a + b


def multiply_numbers(a, b):
    """Multiply two numbers."""
    return a * b


def test_add_positive_numbers():
    """Test adding positive numbers - WILL FAIL."""
    result = add_numbers(2, 3)
    assert result == 5, f"Expected 5 but got {result}"


def test_add_negative_numbers():
    """Test adding negative numbers - WILL FAIL."""
    result = add_numbers(-2, -3)
    assert result == -5, f"Expected -5 but got {result}"


def test_add_zero():
    """Test adding zero - WILL FAIL."""
    result = add_numbers(5, 0)
    assert result == 5, f"Expected 5 but got {result}"


def test_multiply_numbers():
    """Test multiplying numbers - WILL PASS."""
    result = multiply_numbers(4, 5)
    assert result == 20, f"Expected 20 but got {result}"
EOF

echo "✅ Created test_automation_demo.py with intentional bugs"

# Create requirements-dev.txt if it doesn't exist
if [ ! -f requirements-dev.txt ]; then
    echo ""
    echo "📝 Creating requirements-dev.txt..."
    cat > requirements-dev.txt << 'EOF'
pytest>=7.4.0
pytest-json-report>=1.5.0
pytest-html>=3.2.0
pytest-cov>=4.1.0
EOF
    echo "✅ Created requirements-dev.txt"
fi

echo ""
echo "========================================"
echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo ""
echo "1. Set up your Anthropic API key:"
echo "   • Go to: https://github.com/$REPO_URL/settings/secrets/actions"
echo "   • Click: 'New repository secret'"
echo "   • Name: ANTHROPIC_API_KEY"
echo "   • Value: Your API key from https://console.anthropic.com/"
echo ""
echo "2. Configure GitHub Actions permissions:"
echo "   • Go to: https://github.com/$REPO_URL/settings/actions"
echo "   • Under 'Workflow permissions', select:"
echo "     ✅ Read and write permissions"
echo "     ✅ Allow GitHub Actions to create and approve pull requests"
echo ""
echo "3. Commit and push these changes:"
echo "   git add ."
echo "   git commit -m 'Add automated test fix pipeline'"
echo "   git push origin main"
echo ""
echo "4. Watch the magic happen! 🎉"
echo "   • Go to: https://github.com/$REPO_URL/actions"
echo "   • Tests will fail → Issue created → Claude fixes → PR merged"
echo ""
echo "📚 For detailed documentation, see SETUP_GUIDE.md"
echo ""
