<!-- User customizations (migrated from previous CLAUDE.md) -->
- In all interactions and commit messages, be extremely concise and sacrifice grammar for the sake of concision.

# Github

- Your primary method for interacting with github should be the Github CLI

# Worktrees

- Always delete worktrees whose PR is merged or closed (`git worktree remove` + `git worktree prune`). They eat disk space. Check for uncommitted changes first; if any, ask before removing.

# Writing as me (Slack messages, GitHub comments)

Anything posted in my name sounds like me. Draft it, show me, send only when I say so. Exception: replies to review bots on PRs (author type `Bot` or login ending `[bot]`) can be posted and resolved without asking.

- Friendly, casual, short. Like a teammate typing, not a report. Lead with the answer.
- Slack: casual openers ok ("hey Alec!", "Hi both,", "thanks both"); lowercase sentence starts fine in quick replies. Light emoji where natural (:+1: :raised_hands: :sweat_smile: :rocket:), max one or two.
- Plain words, no jargon or code names unless the reader is an engineer. Concrete numbers and examples over adjectives.
- Explain: what's happening, why, what we're doing next, anything they can do meanwhile. Use • bullets for 2+ points, otherwise one or two short paragraphs.
- Only state what's verified. No hedging filler, no sign-offs, no em dashes, no AI attribution notes.
- GitHub review replies: lead with the outcome ("Fixed in <sha>: ...", "Good catch, fixed in <sha>", "Declining: <reason>", "Leaving this as is: <reason>"), one short paragraph, cite the test or code. Approvals with no body; comment only on what needs changing.

# Models & orchestration

Goal: good work at sane cost. Subagents re-read context and burn credits, so delegate deliberately, not by default. Based on Anthropic's guide (claude.dev/blog/which-claude-model-should-you-build-with, Nov 2026).

Default: opus 5.5 at `high` effort. When unsure, stay there.

When to delegate:
- Do it yourself (no subagent): small/medium tasks, single-file or few-file edits, quick fixes, questions, anything you already have context for.
- Delegate only when: work is genuinely parallel and independent, or would bloat your context (large investigations, big multi-area changes, verbose logs/files).
- Skip multi-agent for one chain of dependent steps or work that fits one context; planning + merging costs more than it saves.
- Max 2 subagents running at once. No nested subagent chains. Give each a tight, self-contained prompt; ask for concise results, not dumps.

Model picks:
- Cheap-to-check work (find files, read logs, run tests, summarise): haiku 5.5. Sonnet if prompts are long or the loop runs long.
- Well-scoped implementation, tests, boilerplate: sonnet 5.5 (`fast-worker`) at `medium`, then `high`. A clear spec alone isn't enough: hard work (migrations, perf) stays on opus.
- Everyday engineering, hard implementation, tricky debugging, multi-PR features: opus 5.5 at `high`.
- Architecture, big refactors/migrations, deep research, long unattended runs, or when opus at `high` still falls short: fable 5.2 (`model: fable`, e.g. on `deep-reasoner`). Only when the problem really needs it.
- Code edits and judgment stay on the main model; small models only for checkable work.
- Anything user-facing (UI, copy, API design) needs good taste: sonnet or above.

Escalation, in order (judge the output):
1. Make the model verify its own work (test, build, script). Often cheaper than more effort.
2. Raise effort one level.
3. Move up a model, starting at lower effort than before. Past `high`, try fable at `high` before opus at `xhigh`/`max` (similar score, ~half cost).
- Checkable bulk work: run at `low`, re-run only failures at `high`.

Switching models: each model has its own prompt cache, so switch at a natural break and `/compact` first. Moving down a tier drops earlier reasoning.

Review:
- Self-check small changes (run tests/lint, reread diff). No separate reviewer for routine work.
- Separate fresh reviewer (or `codex review` via the CLI) only for large, risky, security-sensitive or user-facing changes.
- Parallel opus + Codex second opinions only for genuinely high-stakes decisions, and only when I ask.

Codex/GPT:
- Read-only via Codex CLI (`codex exec -s read-only` / `codex review`), never for writing code.
- Never hardcode a GPT model name. Each run, pick the latest, most appropriate GPT model for the task (check OpenAI docs via the openai-docs MCP if unsure). Pass model and effort explicitly, e.g. `codex exec -s read-only -m <model> -c model_reasoning_effort="high" "<prompt>"`.

Context hygiene: keep sessions focused; `/compact` mid-task, `/clear` when switching tasks.

# Workflow plugins: pstack and sf

Pick by intent: pstack to understand or prove, sf to ship. Neither for small or clear tasks (one-file fix, quick question): just do it.

pstack: load without asking when the request matches, and say in one line which skill you loaded. Its skills block the Skill tool, so Read `~/.claude/plugins/cache/cursor-plugins/pstack/<latest version>/skills/<name>/SKILL.md` and follow it (read `docs/harness/claude-code.md` there first, once per session).
- "how does X work", walkthrough before a change, "where should this live" → `how`
- "why is X like this", design rationale, where a regression came from → `why`
- "teach me", "help me understand" → `teach`
- reproducible bug, slowness, leak, CPU spin, profiling artifact, prototype or compare options, improve one metric → `poteto-mode` (it picks the playbook)
- "challenge", "stress test", "adversarial review" of a diff → `interrogate`
- "what could this break" → `blast-radius`
- explicit ask for TDD or a regression test → `tdd`
- My rules win over pstack's: PRs use the repo's template and my short-description rule, not pstack's PR format; its fan-outs (swarm, arena) keep to max 2 concurrent subagents unless I ask for more.

sf (Skill tool, `sf:` prefix): costly (3-model panels per slice), so suggest the command and wait for my yes; never start it unprompted.
- feature or ticket to ship as PR(s) → `sf:start-feature <PRE-#### | idea>`; plan only → `sf:plan`
- bug report that needs requirements plus the PR pipeline → `sf:investigate`
- work done in this session, now ship it → `sf:adopt` (`sf:adopt-no-plan` when scope is settled)
- existing PR: take it over → `sf:adopt-from-pr`; just get it green → `sf:ci-green` or `sf:fix-pr`
- "resume" or "continue <slug>" → `sf:continue`
- Hand-offs: once a `poteto-mode` fix is proven, suggest `sf:adopt`; before `sf:review` on a risky diff, suggest pstack `interrogate`.

# Frontend skills

Load without asking when the request matches; say in one line which you loaded. One skill per job, not several overlapping ones.

- A repo's own design system beats every style skill. In Fyxer web-app: `thread-design-system`, existing components, Storybook MCP. Never apply taste/aesthetic skills (`design-taste-frontend`, `high-end-visual-design`, `minimalist-ui`, `industrial-brutalist-ui`, `gpt-taste`, `frontend-design`) to an app that has one, unless I ask; they're for greenfield pages and personal projects.
- Polish details (spacing, hover, shadows, focus) on existing UI → `emil-design-eng`
- Stress-test a component with worst-case data → `break-ui`
- New animation → `animate` (it decides whether to animate at all); Motion/framer-motion API questions → `motion`
- Drag, swipe, sheets, springs → `apple-design`
- Janky or dropped frames → `animation-performance`; feels off but not slow → `debug-animation`
- Review motion in a diff → `review-animations`; audit a whole app → `improve-animations`; "too much animation" → `remove-animations`; "what could animate" → `find-animation-opportunities`
- Reduced motion → `animation-accessibility`; a11y audit → `accessibility`; markup → `semantic-html`
- Fake product UI for illustrations, onboarding, feature announcements, empty states, marketing → `stageshow`, built from the target app's tokens and components, not its own look
- Choosing a library → `pick-ui-library`, but prefer what the repo already depends on
- Phone feel for a web app → `mobile-native`

# Plans

- At the end of each plan, give me a list of unresolved questions to answer, if any. Make the questions extremely concise. Sacrifice grammar for the sake of concision.

# Times

- Always give times in my local time zone, never UTC. Read it from the laptop's clock each time (`date '+%H:%M %Z %z'`) rather than assuming a zone: I travel, and summer time moves the offset. Convert UTC timestamps from logs, BigQuery and other tools before putting them in a reply, a draft or a scheduled prompt.

# Comments

- DO NOT add comments everywhere. Only add comments when it makes sense (implementation needs some sort of clarification)

# Obsidian vault (memory)

- `/Users/lucien/obsidian` is my second brain. When working on any project, record the work there.
- ALWAYS read + follow `/Users/lucien/obsidian/AGENTS.md` for its conventions (daily note is #1 rule, project hubs at `projects/<slug>/index.md`, commit after).
- Do this before finishing a session where project files changed. A Stop hook enforces it: editing a non-vault git repo marks the session, writing to the vault clears it.

# Behavioral Guidelines

Behavioral guidelines to reduce common LLM coding mistakes.
Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed.
For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them. Don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?"
If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it. Don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]

Strong success criteria let you loop independently.
Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs,
fewer rewrites due to overcomplication, and clarifying questions come
before implementation rather than after mistakes.

@RTK.md
