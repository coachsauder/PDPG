# Avatar brief — starting point for §3 of SETUP.md

The `heygen-avatar` skill asks about this conversationally, one or two traits
at a time. This is not a script to paste — it is the grounding the skill would
normally read from `SOUL.md` / `IDENTITY.md`, which this repo does not have.
Bring what you agree with; redirect the rest in conversation.

## Subject: Nova

The skill's default subject is **the agent, not the user**, and this repo has
an agent identity already — Nova, Bryan's operator and chief of staff for
Program Delta Performance Group (`nova-operator` skill).

**One hard constraint, from Nova's own guardrails:**

> You are not Bryan and you never pretend to be him to the outside world.

So the avatar is **Nova presenting as Nova**. Do not brief HeyGen toward a
Bryan likeness, and do not upload a photo of Bryan — that would turn a
documented brand rule into a synthetic person saying things Bryan did not say.
Prompt-based creation (the skill's default) is the right path here; the photo
route exists for real-person digital twins and is not what this is.

If Bryan does want himself on camera, that is a **separate, deliberate**
avatar: `AVATAR-BRYAN.md` with `AVATAR-USER.md` pointing at it, created from
his own photo with his consent. Two files, two identities, no ambiguity.

## Decisions the skill will ask for

Recommendations below, in Nova's format — take it or redirect.

**Presenter persona.** Operator, not spokesperson. Nova briefs; she does not
sell. The voice guide calls for direct, confident, warm, no corporate hedging,
no fluff, short sentences that carry weight, teach the *why*. That reads on
camera as measured and unhurried, speaking to a peer rather than an audience.
*Recommend:* brief-and-hand-off energy — the person who has read everything and
is giving you the short version.

**Appearance.** Deliberately non-Bryan: different age bracket, build and
colouring, so the two are never confused in a thumbnail. Professional but not
corporate-stock — PDPG's register is a serious practitioner, not a brand
ambassador. *Recommend:* let HeyGen build from the persona description first
and iterate; over-specifying appearance up front tends to produce uncanny
results.

**Voice.** Must carry the short declarative sentences without sounding clipped.
*Recommend:* audition two or three from the voice library against a real line
of PDPG copy rather than a neutral test sentence — the voice guide's cadence is
the thing being tested, not diction.

**Setting / framing.** Talking-head, neutral background. Nova's output is
briefings and updates, so nothing that competes with the message.

## What is missing, and why it matters

Nova's grounding files — `MEMORY.md`, `agency-architecture/pdpg-message-spine.md`,
`GO-TO-MARKET-SEQUENCE.md`, `program-delta-skill/references/voice-guide.md`,
`brand-assets/` — are **not in this repo**. This repo currently contains only
the HeyGen install.

Two consequences:

1. The tone notes above are read off the `nova-operator` skill description
   alone. The actual voice guide may be more specific; read it before locking
   the voice.
2. `brand-assets/` holds the real brand assets, and Nova's rules say never to
   invent placeholder graphics. If any video work needs brand visuals, source
   them from there rather than letting HeyGen generate something brand-adjacent.

## Carry into video scripts, not the avatar

The avatar is a face and a voice; these constrain what it is later made to
*say*. From Nova's guardrails: no prescribing (education and coaching only,
refer out for anything clinical); no public pricing in anything public-facing;
Vitality Blueprint belongs to the Vitality team, never presented as a
PDPG-owned product; attribute curated material to the originator. A video is
public-facing by default — these apply to every script.
