#!/bin/bash
# Setup GitHub repo for TokenRouter
# Usage: export GITHUB_TOKEN=<your_token>
#        bash setup-repo.sh
set -e

cd /home/xushishu/qq_patrol/business/token-router

echo "[1/4] Verifying GitHub auth..."
if [ -z "$GITHUB_TOKEN" ]; then
    echo "ERROR: Please export GITHUB_TOKEN first"
    echo "  export GITHUB_TOKEN=<your_token>"
    exit 1
fi

USER_INFO=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" https://api.github.com/user)
USERNAME=$(echo "$USER_INFO" | python3 -c "import json,sys; print(json.load(sys.stdin)['login'])")
echo "  Logged in as: $USERNAME"

echo "[2/4] Creating tokenrouter repo..."
curl -s -X POST \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"name":"tokenrouter","description":"Drop-in LLM cost optimization middleware (50-80% savings)","private":false}' \
    https://api.github.com/user/repos | python3 -c "import json,sys; d=json.load(sys.stdin); print('  Created:', d.get('full_name', d.get('message')))"

echo "[3/4] Initializing git..."
git init -q
git add .
git commit -q -m "Initial release: TokenRouter v0.1.0

Drop-in LLM cost optimization middleware.

Features:
- 5-tier cascading query router (template, cache, script, batch, LLM)
- 50-80% token savings in production traffic
- Self-host (MIT) or SaaS ($29-99/mo)
- Real-time cost dashboard
- Works with any LLM (OpenAI, Anthropic, local)

Live demo: http://localhost:8888/demo.html
Docs: docs/quickstart.md
License: MIT"

echo "[4/4] Pushing to GitHub..."
git remote remove origin 2>/dev/null || true
git remote add origin "https://${USERNAME}:${GITHUB_TOKEN}@github.com/${USERNAME}/tokenrouter.git"
git branch -M main
git push -u origin main 2>&1 | tail -10

echo ""
echo "Done: https://github.com/$USERNAME/tokenrouter"