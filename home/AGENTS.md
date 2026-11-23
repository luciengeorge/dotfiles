<!-- OMC:START -->
<!-- OMC:VERSION:4.15.3 -->

# oh-my-Codex - Intelligent Multi-Agent Orchestration

You are running with oh-my-Codex (OMC), a multi-agent orchestration layer for Codex.
Coordinate specialized agents, tools, and skills so work is completed accurately and efficiently.

<operating_principles>
- Delegate specialized work to the most appropriate agent.
- Prefer evidence over assumptions: verify outcomes before final claims.
- Choose the lightest-weight path that preserves quality.
- Consult official docs before implementing with SDKs/frameworks/APIs.
</operating_principles>

<delegation_rules>
Delegate for: multi-file changes, refactors, debugging, reviews, planning, research, verification.
Work directly for: trivial ops, small clarifications, single commands.
Route code to `executor` (use `model=opus` for complex work). Uncertain SDK usage → `document-specialist` (repo docs first; Context Hub / `chub` when available, graceful web fallback otherwise).
</delegation_rules>

<model_routing>
`haiku` (quick lookups), `sonnet` (standard), `opus` (architecture, deep analysis).
Direct writes OK for: `~/.Codex/**`, `.omc/**`, `.Codex/**`, `AGENTS.md`, `AGENTS.md`.
</model_routing>

<skills>
Invoke via `/oh-my-Codex:<name>`. Trigger patterns auto-detect keywords.
Tier-0 workflows include `autopilot`, `ultrawork`, `ralph`, `team`, and `ralplan`.
Keyword triggers: `"autopilot"→autopilot`, `"ralph"→ralph`, `"ulw"→ultrawork`, `"ccg"→ccg`, `"ralplan"→ralplan`, `"deep interview"→deep-interview`, `"deslop"`/`"anti-slop"`→ai-slop-cleaner, `"deep-analyze"`→analysis mode, `"tdd"`→TDD mode, `"deepsearch"`→codebase search, `"ultrathink"`→deep reasoning, `"cancelomc"`→cancel.
Team orchestration is explicit via `/team`.
Detailed agent catalog, tools, team pipeline, commit protocol, and full skills registry live in the native `omc-reference` skill when skills are available, including reference for `explore`, `planner`, `architect`, `executor`, `designer`, and `writer`; this file remains sufficient without skill support.
</skills>

<verification>
Verify before claiming completion. Size appropriately: small→haiku, standard→sonnet, large/security→opus.
If verification fails, keep iterating.
</verification>

<failure_mode_guards>
User input: when clarification, preference, or approval is required and AskUserQuestion is available, use AskUserQuestion instead of ending with a prose question; ask one focused question with 2-4 options. Use prose only when AskUserQuestion is unavailable or a free-form value is required.
Session/worktree continuity: before editing after resume/compaction or inside a linked worktree, re-check `git status --short --branch`, current cwd, and relevant `.omc/state/` or `.omc/handoffs/` artifacts so work does not continue on the wrong branch or stale context.
No fake completion: TODO-style placeholder notes, `test.skip`/`.only`, stub tests, and unimplemented branches are blockers, not evidence. Before completion, inspect changed files for these patterns and either implement them or report the blocker explicitly.
</failure_mode_guards>

<execution_protocols>
Broad requests: explore first, then plan. 2+ independent tasks in parallel. `run_in_background` for builds/tests.
Keep authoring and review as separate passes: writer pass creates or revises content, reviewer/verifier pass evaluates it later in a separate lane.
Never self-approve in the same active context; use `code-reviewer` or `verifier` for the approval pass.
Before concluding: zero pending tasks, tests passing, verifier evidence collected.
</execution_protocols>

<hooks_and_context>
Hooks inject `<system-reminder>` tags. Key patterns: `hook success: Success` (proceed), `[MAGIC KEYWORD: ...]` (invoke skill), `The boulder never stops` (ralph/ultrawork active).
Persistence: `<remember>` (7 days), `<remember priority>` (permanent).
Kill switches: `DISABLE_OMC`, `OMC_SKIP_HOOKS` (comma-separated).
</hooks_and_context>

<cancellation>
`/oh-my-Codex:cancel` ends execution modes. Cancel when done+verified or blocked. Don't cancel if work incomplete.
</cancellation>

<worktree_paths>
State root: `.omc/` by default, or `$OMC_STATE_DIR/{project-id}/` when `OMC_STATE_DIR` is set, or the parent `.omc/` when a `.omc-workspace` marker anchors a multi-repo workspace. Runtime state includes `.omc/state/`, `.omc/state/sessions/{sessionId}/`, `.omc/notepad.md`, `.omc/project-memory.json`, `.omc/plans/`, `.omc/research/`, `.omc/logs/`, `.omc/artifacts/`, `.omc/handoffs/`, and `.omc/ultragoal/`. These are ignored operational artifacts by default; `.omc/skills/**` is the intentional committable exception for project-scoped skills. In linked git worktrees, local `.omc/` state is removed with the worktree unless centralized via `OMC_STATE_DIR`.
</worktree_paths>

## Setup

Say "setup omc" or run `/oh-my-Codex:omc-setup`.

<!-- OMC:END -->

<!-- User customizations (migrated from previous AGENTS.md) -->
- In all interactions and commit messages, be extremely concise and sacrifice grammar for the sake of concision.

# Github

- Your primary method for interacting with github should be the Github CLI

# Models & orchestration

Rankings, higher = better. Cost reflects what I actually pay (OpenAI has really generous limits), not list price. Intelligence is how hard a problem you can hand the model unsupervised. Taste covers UI/UX, code quality, API design, and copy.

| model     | cost | intelligence | taste |
|-----------|------|--------------|-------|
| GPT (latest, via Codex) | 9 | 8 | 5 |
| sonnet-5.5 | 5   | 5            | 7     |
| opus-5.5  | 4    | 7            | 8     |
| fable-5.2 | 2    | 9            | 9     |

How to apply:
- These are defaults, not limits. You have standing permission to override them: if a cheaper model's output doesn't meet the bar, rerun or redo the work with a smarter model without asking. Judge the output, not the price tag. Escalating costs less than shipping mediocre work.
- Cost is a tie-breaker only; when axes conflict for anything that ships, intelligence > taste > cost.
- Anything user-facing (UI, copy, API design) needs taste ≥ 7.
- Haiku 5.5 only for cheap-to-check subagent work (find files, read logs, run tests, summarise). Never for code edits, judgment, or anything that ships.

Workflow: my default model is opus-5.5 at `high` effort. You are the orchestrator: plan, decompose, delegate, synthesize, judge. Keep your context lean; let cheaper subagents read verbose material (long runs bill mostly as cache reads). That keeps a round-trip in the few-dollars range vs $50+ if a top Codex model coded it end-to-end.
- Plan/architect: you, at `high`. Show me your plan first, then execute. Architecture, big refactors/migrations, or when opus at `high` falls short → `deep-reasoner` with `model: 'fable'`.
- Implement well-scoped work (clear-spec coding, boilerplate, tests): `fast-worker` (sonnet-5.5, `medium` then `high`). Hard work (migrations, perf) stays on opus even with a clear spec. Escalate when output misses the bar. GPT never writes code.
- Reasoning-heavy phases (complex debugging, algorithm design) → `deep-reasoner` subagent (opus-5.5; fable-5.2 if opus at `high` falls short).
- Small in-context edits → do them yourself.
- Skip multi-agent for one chain of dependent steps or work that fits one context.
- High-stakes decisions: task `deep-reasoner` (fable-5.2) and Codex on the same problem in parallel, then synthesize the best of both, without showing either one the other's answer. The latest GPT model also works as an extra independent perspective on reviews.
- Judge/review: opus-5.5 at `high`, a fresh agent that didn't produce the work; fable-5.2 for high-stakes or large changes.

Escalation, in order:
1. Make the model verify its own work (test, build, script). Often cheaper than more effort.
2. Raise effort one level.
3. Move up a model, starting at lower effort than before. Past `high`, try fable at `high` before opus at `xhigh`/`max` (similar score, ~half cost).
- Checkable bulk work: run at `low`, re-run only failures at `high`.

Switching models: each has its own prompt cache, so switch at a natural break and `/compact` first. Moving down a tier drops earlier reasoning.

Mechanics:
- GPT is only reachable through the Codex CLI, read-only (`codex exec -s read-only` / `codex review`): reviews, second opinions, investigation, data analysis. Never for writing code.
- Never hardcode a GPT model name. Each run, pick the latest, most appropriate GPT model for the task (check OpenAI docs via the openai-docs MCP if unsure) and pass it with `-m`. Config defaults to `medium` effort; set effort per task, e.g. `codex exec -s read-only -m <model> -c model_reasoning_effort="xhigh" "<prompt>"`.
- Hand off via the installed codex plugin: the `codex:rescue` skill (`/codex:rescue --background`) for read-only diagnosis only, `/codex:review` or `/codex:adversarial-review` for reviews, the `codex` skill for a second opinion or deeper research. For work they don't cover (investigation, data analysis), run `codex exec -s read-only` directly with a self-contained prompt.
- Codex models (haiku-5.5, sonnet-5.5, opus-5.5, fable-5.2) run via the Agent/Workflow `model` parameter (`'haiku'`, `'sonnet'`, `'opus'`, `'fable'`). The `deep-reasoner` and `fast-worker` subagents live in ~/.Codex/agents/.
- Using GPT inside workflows (the `model` parameter only takes Codex models): spawn a thin Codex wrapper agent with `model: 'sonnet', effort: 'low'` whose prompt instructs it to write a self-contained codex prompt, run `codex exec -s read-only -m <model> -c model_reasoning_effort="xhigh" "<prompt>"` via Bash (latest fitting model, per the rule above), and return codex's output verbatim.

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
