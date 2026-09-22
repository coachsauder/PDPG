#!/usr/bin/env bash
# Verify a session can actually reach HeyGen and has a working transport.
# Run after changing the cloud environment's network access level, or on a
# local machine before creating an avatar. Read-only: spends no credits.
#
#   bash scripts/heygen-preflight.sh
#
# Exit: 0 = ready, 1 = network blocked, 2 = no transport, 3 = no auth.

set -u
pass=0; fail=0
ok()   { printf '  \033[32mok\033[0m    %s\n' "$1"; pass=$((pass+1)); }
bad()  { printf '  \033[31mFAIL\033[0m  %s\n' "$1"; fail=$((fail+1)); }
note() { printf '  --    %s\n' "$1"; }

echo
echo "HeyGen preflight"
echo "================"

# ---------------------------------------------------------------- network
echo
echo "Network reachability"
net_fail=0
for h in api.heygen.com static.heygen.ai mcp.heygen.com developers.heygen.com; do
  code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 "https://$h" 2>/dev/null)
  # Any HTTP response means the TLS tunnel was established. 000 means the
  # proxy refused CONNECT (egress policy) or the host is unreachable.
  if [ "$code" != "000" ]; then ok "$h (HTTP $code)"; else bad "$h — no tunnel"; net_fail=$((net_fail+1)); fi
done

if [ "$net_fail" -gt 0 ] && [ -n "${HTTPS_PROXY:-}" ]; then
  echo
  note "Recent proxy-side refusals:"
  curl -sS --max-time 15 "$HTTPS_PROXY/__agentproxy/status" 2>/dev/null \
    | grep -o '"host": *"[^"]*"' | sort -u | sed 's/^/        /'
  note "403 on CONNECT = the environment's network access level excludes this host."
  note "Fix: claude.ai/code -> environment selector -> settings -> Network access"
  note "     -> Custom -> add heygen.com, *.heygen.com, heygen.ai, *.heygen.ai"
  note "     -> keep 'Also include default list of common package managers' checked."
fi

# -------------------------------------------------------------- transport
echo
echo "Transport"
have_cli=0; have_key=0
if command -v heygen >/dev/null 2>&1; then
  if heygen --version >/dev/null 2>&1; then
    ok "heygen CLI: $(heygen --version 2>&1 | head -1)"; have_cli=1
  else
    bad "heygen CLI present but --version does not exit 0"
  fi
else
  note "heygen CLI not installed (curl -fsSL https://static.heygen.ai/cli/install.sh | bash)"
fi

if [ -n "${HEYGEN_API_KEY:-}" ]; then
  have_key=1
  ok "HEYGEN_API_KEY is set (${#HEYGEN_API_KEY} chars)"
  note "NOTE: this short-circuits MCP detection. Unset it to use MCP plan credits."
else
  note "HEYGEN_API_KEY not set"
fi

if [ -f "$HOME/.heygen/credentials" ]; then ok "~/.heygen/credentials present"; have_key=1; fi

# ------------------------------------------------------------------- auth
echo
echo "Auth"
if [ "$have_cli" = 1 ] && [ "$have_key" = 1 ]; then
  if heygen avatar list >/dev/null 2>&1; then
    ok "CLI authenticated — API reachable and key accepted"
  else
    bad "CLI cannot authenticate (bad key, no credits, or still network-blocked)"
    note "Run 'heygen avatar list' to see the error envelope."
  fi
else
  note "Skipped — need both a working CLI and a key/credentials file."
  note "MCP is the alternative: its tools appear as mcp__heygen__* and need no key."
fi

# ---------------------------------------------------------------- avatars
echo
echo "Avatar state"
shopt -s nullglob
found=(AVATAR-*.md)
if [ ${#found[@]} -gt 0 ]; then
  for f in "${found[@]}"; do
    if [ -L "$f" ]; then ok "$f -> $(readlink "$f")"; else ok "$f"; fi
  done
else
  note "No AVATAR-*.md yet — run the heygen-avatar skill to create one."
fi

# --------------------------------------------------------------- verdict
echo
echo "----------------------------------------"
if [ "$net_fail" -gt 0 ]; then
  echo "BLOCKED: network. Nothing else can be tested until egress is allowed."
  exit 1
elif [ "$have_cli" = 0 ] && [ "$have_key" = 0 ]; then
  echo "BLOCKED: no transport. Install the CLI or connect HeyGen MCP."
  exit 2
elif [ "$fail" -gt 0 ]; then
  echo "BLOCKED: auth. Network is fine; the key or credits are not."
  exit 3
else
  echo "READY ($pass checks passed). Next: create an avatar with heygen-avatar."
  exit 0
fi
