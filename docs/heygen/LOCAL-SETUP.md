# HeyGen — finishing the install on your own machine

The skills are already installed and committed (`.claude/skills/`). What is
left is the part that needs network access to HeyGen: a transport, auth, and
your avatar.

**Why this is not already done.** The Claude Code on the web container that
installed these skills has a network policy that refuses every HeyGen host at
the proxy gateway:

```
static.heygen.ai:443      403   CLI installer
api.heygen.com:443        403   all API calls
mcp.heygen.com:443        403   MCP server
developers.heygen.com:443 403   the skills' docs lookups
```

No transport can reach HeyGen from there, so Steps 4-6 of upstream's
`INSTALL_FOR_AGENTS.md` have to run locally. Run everything below from your
clone of this repo.

---

## 1. Pick a transport

Two real options. **They bill differently — pick deliberately.**

| | MCP | CLI |
|---|---|---|
| Auth | OAuth, no key to handle | `HEYGEN_API_KEY` or `heygen auth login` |
| Billing | your HeyGen **plan** credits | **API** credits (pay-as-you-go) |
| Setup | connect the server once | install a binary |

The skills detect the transport themselves, in this order:

1. OpenClaw plugin exposing `heygen/video_agent_v3` *(not applicable — you are on Claude Code)*
2. **CLI**, if `HEYGEN_API_KEY` is set **and** `heygen --version` exits 0
3. **MCP**, if no API key is set **and** `mcp__heygen__*` tools are visible
4. CLI fallback, if MCP is unavailable and `heygen --version` exits 0

**The trap:** setting `HEYGEN_API_KEY` short-circuits MCP detection entirely.
If you want MCP plan-credit billing, do **not** set the key anywhere the agent
can see it. To switch back to MCP later, `unset HEYGEN_API_KEY` and remove it
from your shell profile.

### Option A — MCP (no API key)

Add the HeyGen remote MCP server to Claude Code and complete the OAuth flow:

```bash
claude mcp add --transport http heygen https://mcp.heygen.com/mcp/v1/
```

Then in an interactive Claude Code session, run `/mcp` and authorize. OAuth
cannot be completed in a non-interactive or web session — it has to be a real
terminal.

Verify: `mcp__heygen__*` tools appear in the session. Skip to step 3.

### Option B — CLI (API key)

Get a key at <https://app.heygen.com/api> (Settings → API → New Key). **It is
shown once — copy it before closing the modal.**

Install the CLI. This pipes a remote script into your shell, so read it first
if you would rather not run it blind:

```bash
curl -fsSL https://static.heygen.ai/cli/install.sh -o /tmp/heygen-install.sh
less /tmp/heygen-install.sh        # review
bash /tmp/heygen-install.sh
```

Authenticate. `heygen auth login` persists the key to `~/.heygen/credentials`
and keeps it out of your environment and out of this repo — prefer it over
exporting the variable:

```bash
heygen auth login
heygen --version                   # must exit 0
```

If you do need the env var instead (CI, scripted runs), put it in `~/.zshrc`
or `~/.bashrc` — not in a single shell, and **never in this repo**. `.env` and
`.heygen/` are gitignored here; `.env.example` shows the variable name.

> Agents run in a separate process from your terminal. After editing your shell
> profile, restart the agent host — re-sourcing the profile is not enough.

---

## 2. Check credits

The HeyGen API is pay-as-you-go; there is no free tier. Avatar V runs roughly
**6 credits per minute** of generated video. Confirm you have credits at
<https://app.heygen.com/billing> before generating anything.

Current rates: <https://help.heygen.com/en/articles/10060327-heygen-api-pricing-explained>

---

## 3. Create the avatar

This is what the install is actually for — giving the agent a face. In an
interactive Claude Code session from this repo:

```
Use heygen-avatar to create your avatar.
```

What to expect:

- The default subject is **the agent**, not you. Say "create *my* avatar" or
  "digital twin of me" only if you want your own face.
- There is no `SOUL.md` / `IDENTITY.md` in this repo, so the skill will ask
  about appearance, voice, and presenter persona conversationally — one or two
  traits at a time, not as one big form.
- Creation is **prompt-based by default**. A photo is opt-in and only relevant
  for a real-person digital twin.
- There is a **confirmation gate before generation**. Aborting there writes no
  file and spends no credits — that is intended, not a failure. Re-invoke the
  skill to resume.

On success you get `AVATAR-<NAME>.md` at the repo root plus an `AVATAR-AGENT.md`
symlink (or `AVATAR-USER.md` for a user avatar). Commit both — they hold the
`avatar_id` / `voice_id` that `heygen-video` reads on every later call. They
contain no secrets.

---

## 4. Smoke test (optional, ~half a credit)

```
Use heygen-video to generate a 5-second test clip with the avatar from
AVATAR-<NAME>.md saying "HeyGen install working, ready to ship." Save the
file locally and tell me the path.
```

Expect a 1-3 MB `.mp4`, 5 seconds, avatar speaking the line. Generated media
is gitignored.

### If it fails

| Symptom | Cause |
|---|---|
| "HEYGEN_API_KEY is not set" though you exported it | The export only applied to that one shell. Put it in your shell profile and restart the agent host. |
| Auth error | No credits — check <https://app.heygen.com/billing>. |
| Skill says no transport available | `heygen --version` does not exit 0, or the agent's `PATH` differs from your interactive shell. Add the CLI's install dir (often `~/.local/bin`) to a `PATH` the agent inherits. |
| CLI used when you wanted MCP | `HEYGEN_API_KEY` is set. `unset` it and remove it from your profile. |
| `waiting_for_input` from the Video Agent | The skill called the Video Agent in chat mode. It must pass `mode: "generate"`. Re-read `heygen-video/SKILL.md`. |

---

## 5. Defaults

On the Claude Code + CLI path there is nothing to configure: `heygen config set`
only accepts the keys `analytics` and `output`. The `AVATAR-<NAME>.md` file is
the source of truth, and the agent reads it per call. Same for MCP. (The
`openclaw config set` defaults in upstream's Step 7, and the default-provider
setting in Step 8, are OpenClaw-only and do not apply here.)

---

## Then

```
"Make a 30-second video of yourself introducing what we're working on this week"
"Generate a 60-second product walkthrough using my avatar"
"Translate this video into Spanish, Japanese, and German"
```

Avatar resolution, prompt engineering, aspect ratio, voice selection, and Frame
Check are handled by the skills.
