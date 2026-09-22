# HeyGen — finishing the install

The skills are installed and committed (`.claude/skills/`). What is left needs
network access to HeyGen, which this repo's cloud environment currently denies.

Pick **Route A** (unblock the cloud environment — everything keeps working from
claude.ai/code) or **Route B** (run it on your own machine). Both end at the
same place: §3 below.

Verify at any point with:

```bash
bash scripts/heygen-preflight.sh
```

It is read-only and spends no credits. Exit 0 = ready.

---

## The blocker

Claude Code on the web runs each session in a **cloud environment** whose
*network access level* controls outbound connections. This repo's environment
is named **PDPG** (`env_01KjwP2VnVHYNefz8ig8QMZo`) and is on the default
**Trusted** level: package registries, GitHub, cloud SDKs — and nothing else.

HeyGen is not on that list, so every HeyGen host is refused at the egress
proxy with a 403 on CONNECT:

```
api.heygen.com  static.heygen.ai  mcp.heygen.com
developers.heygen.com  app.heygen.com  resource.heygen.ai
```

This is the policy working as designed, not a bug, and not something to route
around. The four levels are:

| Level | Outbound connections |
|---|---|
| None | nothing through the session's network |
| **Trusted** (current) | allowlisted domains: package registries, GitHub, cloud SDKs |
| Full | any domain |
| Custom | your own allowlist, optionally plus the defaults |

Four paths bypass the session allowlist whatever the level: GitHub (separate
proxy), **MCP connectors enabled at claude.ai** (traffic goes through
Anthropic's servers), hosts attached to the environment's **API credentials**,
and the Anthropic API itself.

---

## Route A — unblock the cloud environment

### A1. Allow the HeyGen domains

At <https://claude.ai/code>, select the cloud icon showing **PDPG** in the row
above the message box → the settings icon on the right → **Network access** →
**Custom**. There is no settings page or direct URL for this; it is only in
that selector.

In **Allowed domains**, one per line:

```
heygen.com
*.heygen.com
heygen.ai
*.heygen.ai
```

Leave **"Also include default list of common package managers"** checked, or
you will lose GitHub and npm access.

> A leading `*.` matches subdomains only, so the bare apex is listed too.
> Changes apply to sessions started *afterwards* — this one keeps the network
> it booted with.

### A2. Supply the key

Two options, and the tradeoff is real:

**Environment variable** — in the same dialog, under Environment variables:

```
HEYGEN_API_KEY=hg_...
```

Simple, works with the CLI. But anyone who uses the environment can read it,
including the agent.

**API credential** (Pro/Max, org admin role) — in the dialog of an environment
that *already exists*, under API credentials → Add credential. Allowed
websites `api.heygen.com`; change the header Name to `X-Api-Key` and clear the
`Bearer` prefix. Anthropic's proxy attaches the key after the request leaves
the VM, so it never reaches the agent or the session's environment.

> **Caveat, untested:** API credentials work for direct HTTP, but the skills
> deliberately never curl `api.heygen.com` — they route through the CLI, which
> checks its *own* auth (`HEYGEN_API_KEY` or `~/.heygen/credentials`) before
> making a request. The CLI may refuse to start with no key it can see, even
> though the proxy would have authenticated the call. If the credential route
> stalls at "not authenticated", fall back to the environment variable.
> Verify the header name against <https://developers.heygen.com> once it is
> reachable.

### A3. Install the CLI

Start a **new** session (the current one keeps the old network), then:

```bash
curl -fsSL https://static.heygen.ai/cli/install.sh -o /tmp/heygen-install.sh
less /tmp/heygen-install.sh          # review before running
bash /tmp/heygen-install.sh
heygen --version                     # must exit 0
bash scripts/heygen-preflight.sh     # expect READY
```

Go to §3.

---

## Route B — your own machine

No policy to change; your shell has normal network access. Clone this repo and
pick a transport.

### B1. MCP (no API key, bills HeyGen *plan* credits)

`.mcp.json` at the repo root already declares the server, so Claude Code will
offer to connect it. Otherwise:

```bash
claude mcp add --transport http heygen https://mcp.heygen.com/mcp/v1/
```

Then `/mcp` in an interactive session and authorize. **OAuth needs a real
terminal** — it cannot complete in a web or non-interactive session, which is
why this did not happen automatically here.

Verify: `mcp__heygen__*` tools appear. Go to §3.

### B2. CLI (API key, bills *API* credits)

Key from <https://app.heygen.com/api> (Settings → API → New Key) — **shown
once, copy it before closing the modal.**

```bash
curl -fsSL https://static.heygen.ai/cli/install.sh -o /tmp/heygen-install.sh
less /tmp/heygen-install.sh
bash /tmp/heygen-install.sh
heygen auth login                    # persists to ~/.heygen/credentials
bash scripts/heygen-preflight.sh
```

Prefer `heygen auth login` over exporting the variable: it keeps the key out
of your environment and out of this repo. `.env` and `.heygen/` are gitignored
here regardless.

> Agents run in a separate process from your terminal. If you do put the key in
> `~/.zshrc`, restart the agent host — re-sourcing the profile is not enough.

---

## Transport detection, and the one trap

The skills choose a transport themselves:

1. OpenClaw plugin exposing `heygen/video_agent_v3` — *not applicable here*
2. **CLI**, if `HEYGEN_API_KEY` is set **and** `heygen --version` exits 0
3. **MCP**, if no API key is set **and** `mcp__heygen__*` tools are visible
4. CLI fallback, if MCP is unavailable and the CLI works

**Setting `HEYGEN_API_KEY` short-circuits MCP detection at step 2.** If you
want MCP plan-credit billing, do not set the key anywhere the agent can see
it — including the environment variables of the cloud environment. To switch
back: `unset HEYGEN_API_KEY`, remove it from your shell profile and from the
environment config.

Billing differs by transport: **MCP spends HeyGen plan credits, the CLI spends
pay-as-you-go API credits.** Pick deliberately.

---

## 3. Create the avatar

The point of the install — giving the agent a face. Check credits first:
Avatar V runs roughly **6 credits per minute** of generated video and there is
no free tier (<https://app.heygen.com/billing>).

In an interactive Claude Code session from this repo:

```
Use heygen-avatar to create your avatar.
```

What to expect:

- **The default subject is the agent, not you.** Say "create *my* avatar" or
  "digital twin of me" only if you want your own face.
- No `SOUL.md` / `IDENTITY.md` here, so the skill asks about appearance, voice
  and presenter persona conversationally — one or two traits at a time, not one
  big form. `docs/heygen/AVATAR-BRIEF.md` has a starting point if you want one.
- Creation is **prompt-based by default**; a photo is opt-in and only for a
  real-person digital twin.
- There is a **confirmation gate before generation**. Backing out there writes
  no file and spends no credits — intended, not a failure. Re-invoke to resume.

Output: `AVATAR-<NAME>.md` at the repo root plus an `AVATAR-AGENT.md` symlink
(or `AVATAR-USER.md`). **Commit both** — they carry the `avatar_id` /
`voice_id` that `heygen-video` reads on every later call, and they hold no
secrets.

## 4. Smoke test (optional, ~half a credit)

```
Use heygen-video to generate a 5-second test clip with the avatar from
AVATAR-<NAME>.md saying "HeyGen install working, ready to ship." Save the
file locally and tell me the path.
```

Expect a 1–3 MB `.mp4`, 5 seconds. Generated media is gitignored.

### If it fails

| Symptom | Cause |
|---|---|
| Hosts still 403 after Route A | The change applies to *new* sessions. Start a fresh one. |
| "HEYGEN_API_KEY is not set" though you exported it | The export applied to one shell. Put it in the shell profile (or the environment config) and restart the agent host. |
| Auth error | No credits — <https://app.heygen.com/billing>. |
| No transport available | `heygen --version` does not exit 0, or the agent's `PATH` lacks the CLI's install dir (often `~/.local/bin`). |
| CLI used when you wanted MCP | `HEYGEN_API_KEY` is set somewhere. Unset it. |
| `waiting_for_input` from the Video Agent | The skill called the Video Agent in chat mode; it must pass `mode: "generate"`. Re-read `heygen-video/SKILL.md`. |

## 5. Defaults

Nothing to configure on either route: `heygen config set` accepts only
`analytics` and `output`, and MCP has no per-skill defaults. The
`AVATAR-<NAME>.md` file is the source of truth and the agent reads it per call.
(Upstream's Step 7 `openclaw config set` defaults and Step 8 default-provider
setting are OpenClaw-only.)
