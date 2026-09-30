TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}"
[[ -n "$TOKEN" ]] || { echo "Error: set GH_TOKEN or GITHUB_TOKEN" >&2; exit 1; }
workshop run --env GITHUB_TOKEN=$TOKEN -- copilot
