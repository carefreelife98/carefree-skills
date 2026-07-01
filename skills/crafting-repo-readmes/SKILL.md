---
name: crafting-repo-readmes
description: Use when asked to write, rewrite, or improve a README.md for a git repository given a URL or local path, or to systematically analyze and document a codebase for external readers. Also applies when a repo's README is stale, thin, auto-generated boilerplate, or missing entirely.
metadata:
  author: carefreelife98
---

# Crafting Repo READMEs

## Overview

Given a git URL or local path, gather real facts about the repository before writing a single line of README, draft it, then stop and get approval before writing anything to disk. Skipping either the analysis or the approval gate is the failure mode this skill exists to prevent — a fluent-sounding README built from assumptions, or a correct README applied without review, are both failures.

## When to use

- User gives a git URL or local repo path and asks for a README (new, rewritten, or "improved")
- User asks to "document this codebase" or "make this repo presentable" for external readers
- An existing README is stale, thin, or clearly doesn't match what the code actually does

## Workflow

1. **Resolve input.** Accept either a git URL or an existing local path.
   - Local path → analyze in place, no clone. If it's a git checkout, run `git status --short` and `git fetch --dry-run` (read-only) and note anything relevant (uncommitted changes, behind `origin`) in your own context — never auto-pull, never discard local state.
   - GitHub URL → `gh repo clone <owner>/<repo> -- --depth 1 <scratch-dir>`. Prefer this over plain `git clone` for GitHub URLs specifically: it uses your existing `gh` auth and works for **public and private repos alike**, whereas a plain HTTPS `git clone` fails on private repos without a credential helper already configured.
   - Non-GitHub git URL → `git clone --depth 1 <url> <scratch-dir>` (private-repo access here depends on the user's own SSH keys/credential helper).
   - Clone/auth failure → report the actual error (permission denied / not found / not authenticated) and stop. Suggest `gh auth login` or checking SSH access. Do not retry with a workaround, do not guess a different URL, do not fall back to writing a README from the name alone.
   - Do not search the filesystem for a pre-existing local clone matching a URL — if the user has one, they'll give you the path directly.

2. **Gather facts before drafting anything.** Work through `references/repo-analysis.md`: manifests, directory structure, entry points, tests, CI, license, env vars, largest files. This step runs even when the repo already has an extensive README — the draft's structure comes from what's actually in the code, not from what's already written about it.

3. **Enrich from GitHub metadata when applicable.** `gh repo view --json description,stargazerCount,licenseInfo,repositoryTopics,latestRelease,homepageUrl` etc. — surfaces things the file tree alone won't show (stars, topics, latest release).

4. **Classify the project.** Use the signal table in `references/repo-analysis.md` to determine project type (library / CLI / service / web app / monorepo / IaC / other) and primary stack. This determines which README sections actually apply — a library needs an API section, a CLI needs a command reference, a web app needs a demo/screenshot slot.

5. **Treat any existing README as a source, not a template.** Read it for tone, project history, or naming conventions the code alone won't reveal (for example: some projects use lowercase `readme.md` by convention — preserve that if so). Build the new structure from steps 2-4, not by lightly editing the old one section-by-section.

6. **Draft** using the structure and template in `references/readme-best-practices.md`. English by default unless told otherwise.

7. **STOP. Show the full draft in the conversation. Do not write it to any file yet.** Wait for the user to approve or request changes.

8. **On approval**, write the README to the target path with Write/Edit. Do not commit or push without a separate, explicit confirmation — that's a distinct action from drafting a file.

## Red flags — stop and go back to step 7

- About to call Write/Edit on a README and haven't shown the content in the conversation first
- "The existing README already covers this, I'll just polish it in place" — it's a source, not a starting structure
- "I can tell what this is from the name/description" — verify against the actual manifest and source instead of assuming
- "I'll write the file and show them after, saves a round trip" — writing before approval is the single most common way this skill fails; the analysis being correct doesn't make skipping the approval step safe

## Quick reference

| Step | Tool/command |
|---|---|
| Clone (GitHub) | `gh repo clone <owner>/<repo> -- --depth 1 <dir>` |
| Clone (other host) | `git clone --depth 1 <url> <dir>` |
| Local checkout status | `git status --short`, `git fetch --dry-run` |
| Fact-gathering | `references/repo-analysis.md`, `scripts/gather-facts.sh <dir>` |
| GitHub metadata | `gh repo view --json ...` |
| README structure | `references/readme-best-practices.md` |

## Common mistakes

- Writing install/usage commands that "look right" instead of copying them from the actual manifest scripts or verified source
- Reproducing dynamic content from an existing README (sponsor logos, point-in-time star counts) instead of using badges that stay accurate automatically
- Fabricating links to files that don't exist (CONTRIBUTING.md, CODE_OF_CONDUCT.md) — check first, only link what's real
- Including a mermaid architecture diagram for a single-file script — reserve it for genuinely multi-component projects
