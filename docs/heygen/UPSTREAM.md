# HeyGen Skills — provenance

The three skills under `.claude/skills/` are vendored from HeyGen's public
skills repository. They are copied verbatim; no local edits.

| | |
|---|---|
| Upstream | https://github.com/heygen-com/skills |
| Version | 3.2.0 |
| Commit | `1bd5e4d33a028dfed3abf504c5e3dd644fb9ea8a` (2026-07-14) |
| License | MIT (see upstream `LICENSE`) |
| Installed | 2026-09-22, following upstream `INSTALL_FOR_AGENTS.md` |

## Layout

Upstream's `git clone` recipe puts everything under a single
`heygen-skills/` directory, which nests `SKILL.md` one level deeper than
Claude Code's discovery path. Upstream's own `gh skill install` route lands
each skill flat, so that is what is vendored here:

```
.claude/skills/heygen-avatar/      identity -> avatar -> voice
.claude/skills/heygen-video/       idea -> script -> video
.claude/skills/heygen-translate/   video -> dubbed + lip-synced video
```

Each skill is self-contained (its own `references/`). They share state through
`AVATAR-<NAME>.md` files at the repo root, written by `heygen-avatar` and read
by `heygen-video`.

`.mcp.json` at the repo root is upstream's own, unmodified: it declares
HeyGen's remote MCP server (`https://mcp.heygen.com/mcp/v1/`). MCP is the
skills' preferred transport — OAuth, no API key, billed against HeyGen plan
credits rather than API credits. First connection prompts for authorization.

`RUNTIME-CONTRACT.md` in this directory is upstream's root `CLAUDE.md`, kept
for reference. It is deliberately *not* installed at the repo root, so it
cannot be mistaken for this project's own `CLAUDE.md`.

Not vendored from upstream: `docs/heygen/SETUP.md`, `docs/heygen/AVATAR-BRIEF.md`
and `scripts/heygen-preflight.sh` are local to this repo.

## Upgrading

```bash
git clone --depth 1 https://github.com/heygen-com/skills.git /tmp/heygen-skills
for d in heygen-avatar heygen-video heygen-translate; do
  rm -rf ".claude/skills/$d"
  cp -R "/tmp/heygen-skills/$d" ".claude/skills/$d"
done
cp /tmp/heygen-skills/CLAUDE.md docs/heygen/RUNTIME-CONTRACT.md
cp /tmp/heygen-skills/.mcp.json .mcp.json
```

Then update the version/commit in the table above. Re-read the changed
`SKILL.md` after a version bump — the transport detection ladder gains new
entries over time.
