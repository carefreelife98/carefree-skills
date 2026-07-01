# crafting-repo-readmes — Design

## Context

`carefree-skills` is a personal collection of portable [Agent Skills](https://agentskills.io). The first real skill to add: given a git URL (or local path), systematically analyze the repository and produce a polished, best-practice `README.md` draft for the user to review before it's applied. The user wants this backed by real research into (a) how repositories are systematically analyzed and (b) what makes a genuinely good GitHub README, not guesswork.

## Goals

- Work on any language/stack/framework — the skill infers the stack rather than assuming one.
- Support both public and private GitHub repos, plus a fallback path for non-GitHub git hosts.
- Never silently paper over failures (auth errors, missing tools) — surface them and stop.
- Draft first, apply second: the user reviews the README before it's written to the target repo. No auto-commit/push.
- Keep `SKILL.md` itself small (progressive disclosure per the agentskills.io spec); push heavy checklists/templates into `references/`.

## Non-goals

- Not building a full static-analysis engine (AST parsing, dependency graph rendering, etc.). The skill leans on Claude's own reasoning over a curated set of shell facts, not a bespoke analyzer.
- Not handling repo hosts requiring bespoke auth flows beyond `gh` (GitHub) and the user's existing git credential setup (SSH keys, credential helpers) for everything else.
- Not auto-committing or pushing the generated README — that's a separate, explicitly-confirmed action per the harness's existing git safety rules.

## Directory layout

```
skills/crafting-repo-readmes/
  SKILL.md                       # workflow orchestration only
  references/
    repo-analysis.md             # polyglot fact-gathering checklist + architecture signal table
    readme-best-practices.md     # README structure spec + badges/TOC/mermaid guidance + template
  scripts/
    gather-facts.sh              # automates the repetitive fact-gathering commands
```

This mirrors the "reference skill with reusable tool" pattern (see `superpowers:writing-skills`), and matches how comparable skills (e.g. codebase-onboarding-style skills) split orchestration from checklists.

## Workflow

1. **Resolve input.**
   - GitHub URL → `gh repo clone <owner>/<repo> -- --depth 1` into a scratch dir. `gh` is already authenticated with `repo` scope, so this works for public *and* private repos without extra setup.
   - Non-GitHub git URL → `git clone --depth 1 <url>` fallback. Private-repo access here depends on the user's existing SSH keys/credential helper — the skill does not configure auth itself.
   - Local path → analyze in place, no clone.
   - Clone/auth failure → report the actual error (permission denied / not found / not authenticated) and stop. Suggest `gh auth login` or checking SSH access. No silent fallback, no guessing.

2. **Gather facts.** Run `scripts/gather-facts.sh` against the checked-out tree: package manifests (any language), top-level directory structure, largest source files, test file counts, CI config presence, license file, referenced env vars, entry-point candidates.

3. **Enrich from GitHub (if applicable).** `gh repo view --json description,stargazerCount,licenseInfo,repositoryTopics,latestRelease` (+ contributors) to pull metadata that isn't visible from the file tree alone.

4. **Classify.** Use the architecture/stack signal table in `references/repo-analysis.md` to determine project type (library, CLI, web app, monorepo, service, IaC, etc.) and primary stack. This drives which README sections are relevant (e.g. a library needs an API section; a CLI needs command examples; an IaC repo needs a differently-shaped usage section).

5. **Consult existing README (if present).** Read it only for tone and any non-obvious details (e.g. project history, naming rationale) it might contain that the code alone won't reveal. The *structure* of the new README always comes from the analysis in steps 2-4, not from copying the old one — old READMEs are frequently stale or thin, which is the whole reason this skill exists.

6. **Draft.** Build the README using the template and section-order guidance in `references/readme-best-practices.md` (based on the standard-readme spec, cross-checked against banesullivan/README and awesome-readme examples): title/badges → short description → highlights → overview (+ mermaid architecture diagram when the project has multiple components) → install → usage (copy-paste commands) → configuration/env vars (if any were found) → testing → contributing → license → credits. TOC included when the draft exceeds ~100 lines. English by default.

7. **Present for approval.** Show the draft in the conversation. Wait for the user to approve or request changes.

8. **Apply.** On approval, write `README.md` into the target repo. Do not commit or push — that requires its own explicit confirmation, already covered by the harness's standing git-safety behavior.

## Testing plan (TDD for skills, per `superpowers:writing-skills`)

This is a **technique + reference** skill (not primarily a discipline/compliance skill), so testing focuses on application-scenario correctness rather than heavy adversarial pressure-testing — though one pressure scenario ("just give me something quick, skip the deep analysis") is worth running since the temptation to shortcut the fact-gathering step is real.

- **RED:** Dispatch a subagent with a real public repo URL (candidate: `https://github.com/sindresorhus/execa`, a mid-sized Node.js library with a real test suite and package layout) and the instruction "analyze this repo and write a great README", *without* the skill loaded. Record verbatim what it skips (e.g., does it actually clone and read source, or guess from the name? Does it check for an existing README and just lightly edit it? Does it include installation/usage that's actually verified against the code? Does it ask for approval before "applying," or does it just dump a README and assume it's final?).
- **GREEN:** Re-run the same scenario with the skill loaded. Verify: real fact-gathering happened (not guessed), the architecture classification matches the actual repo, the draft follows the template, and the agent stops to ask for approval before writing any file.
- **REFACTOR:** Run the time-pressure variant ("skip the deep dive, I just need something fast") and see if the skill's fact-gathering step survives. Close any loophole found by adding explicit counters to `SKILL.md`.

Subagents in both RED and GREEN runs are instructed to only produce the draft text (not write files), so testing never touches a real repo's actual README.

## Open follow-ups (explicitly deferred, not silently skipped)

- Non-English README output: deferred until someone actually needs it. When it comes up, add a step asking the user which language, rather than guessing from repo content.
- Screenshot/GIF capture: out of scope — the skill will leave a placeholder note when visuals would clearly help (e.g. a UI project) rather than attempting to generate or capture images itself.
