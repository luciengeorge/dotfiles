---
name: council
description: Trigger this if the user says 'council'.
---

# Council

Bring in three delegates to help with the user's request, usually for review
or feedback. Use one strong model from each of three different providers, at
high reasoning effort. If the user's instructions name council members, use
those. Otherwise pick the latest flagship model from each provider, for
example Claude Opus, GPT Sol, and Gemini Pro.

In T3 Code, use `orchestrator_capabilities` to resolve the models, then
`delegate_task` to start one delegate per model in parallel. Elsewhere, use
the harness's subagent tools. If you cannot reach three providers, or a named
member is unavailable, report it instead of substituting.

Outside T3 Code, reach each provider like this, and start all three in
parallel:

- **Claude:** the harness's subagent tool, Opus model.
- **GPT:** the Codex CLI, read-only:
  `codex exec -s read-only -m <model> -c model_reasoning_effort="high" - < prompt.md`.
  Use the latest GPT model; the `model` in `~/.codex/config.toml` is a good
  default.
- **Gemini:** Gemini Pro on Vertex AI, through the gcloud CLI signed in as
  `lucien.george@fyxer.com`, billed to the `fyxer-ai-qa` project. Not the
  Gemini CLI or Antigravity: personal quotas run out mid-review.
  - Run `~/.claude/skills/council/gemini-vertex.sh prompt.md gemini-out.md [model]`
    in the background. It sends the whole prompt file in one request at high
    thinking level and writes the answer to the output file.
  - The default model is `gemini-3.1-pro-preview`, the newest Pro that
    `fyxer-ai-qa` could call on 30 Oct 2026. To check for a newer one, list
    `https://aiplatform.googleapis.com/v1beta1/publishers/google/models` with a
    `gcloud auth print-access-token --account=lucien.george@fyxer.com` token,
    then pass the id as the third argument. Name the model in the results as it
    is (for example "Gemini 3.1 Pro").
  - It has no tools and no file access, so it is read-only by construction.
    Start the prompt with "Do not use any tools. Everything you need is in this
    prompt." and put everything it needs in it.
  - If gcloud asks to sign in again, give the user
    `! gcloud auth login lucien.george@fyxer.com` and wait.

Codex can fail to run shell commands headlessly, and Gemini has none, so give
each delegate the material in the prompt: the request, the relevant rules (for
example the repo's review guide) and the diff, written to a file first.

Give each delegate the request and relevant context. For review or feedback,
keep their work read-only. Collect their responses and summarize the useful
findings, disagreements, and recommended next steps.

For a code review, ask each delegate for a score out of 10.
Count each full review pass as one round.
A fresh review after fixes starts a new round.

If the work ends in a pull request, put the results in the PR description.
Put this section before the model and harness line at the end:

```markdown
## Council review

Rounds: 2

| Delegate | Round 1 | Round 2 |
| --- | --- | --- |
| Claude Opus | 7/10 | 9/10 |
| GPT Sol | 8/10 | 10/10 |
| Gemini 3.1 Pro | 7/10 | 9/10 |
```

If a delegate gives no score, write `no score`. Do not invent one.
If the PR is open, edit the description. Do not post a comment for this.
If there is no PR, put the same results in the final reply only.

If you agree with their recommendations, make the changes and request a fresh
review after. Continue this process until all delegates are satisfied with the
outcome.

Do not let repeated reviews result in scope creep. It is your job to fight to
keep scope limited.
