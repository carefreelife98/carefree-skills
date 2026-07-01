# carefree-skills

A personal collection of portable [Agent Skills](https://agentskills.io) — reusable capabilities that work across AI coding agents (Claude Code, Codex CLI, Gemini CLI, Cursor, and any other agentskills.io-compatible client).

## Highlights

- Follows the open [agentskills.io](https://agentskills.io/specification) format — not locked to one vendor or tool
- Skills ship with their own polyglot fact-gathering references and helper scripts, not just prose instructions
- Built test-driven: each skill is validated with a baseline (RED) run without it, a verified (GREEN) run with it, and a pressure-tested (REFACTOR) pass — see `docs/superpowers/specs/`

## Skills in this repo

| Skill | Description |
|---|---|
| [`crafting-repo-readmes`](skills/crafting-repo-readmes) | Given a git URL or local path, systematically analyzes a repository and drafts a README — always stopping for approval before writing anything. |

## Structure

Each skill lives in its own directory under `skills/`, following the [Agent Skills specification](https://agentskills.io/specification):

```
skills/
  <skill-name>/
    SKILL.md          # required: YAML frontmatter + instructions
    scripts/          # optional: executable code
    references/       # optional: extra docs loaded on demand
    assets/           # optional: templates, static resources
```

## Using a skill

### Install and update with `gh skill` (recommended)

This repo is published as a [`gh skill`](https://github.com/cli/cli) source (GitHub CLI ≥ 2.90.0, `agent-skills` topic). It handles per-client placement and update tracking for you:

```sh
gh skill install carefreelife98/carefree-skills <skill-name>              # install
gh skill install carefreelife98/carefree-skills <skill-name> --agent claude-code --scope user  # for a specific client
gh skill update <skill-name>                                              # check/apply updates
gh skill install carefreelife98/carefree-skills <skill-name> --pin v0.1.0 # pin a version
```

`--agent` accepts `claude-code`, `codex`, `gemini-cli`, `cursor`, and many more — run `gh skill install --help` for the full list. Without `--agent`, `gh skill install` prompts interactively.

### Manual install (no `gh` CLI)

Symlink (or copy) a skill directory into whichever client you're using. Verified paths, personal/global vs project-scoped:

| Client | Personal/global | Project |
|---|---|---|
| Claude Code | `~/.claude/skills/<name>/SKILL.md` | `.claude/skills/<name>/SKILL.md` |
| Codex CLI | `~/.agents/skills/<name>/SKILL.md` | `.agents/skills/<name>/SKILL.md` |
| Gemini CLI | `~/.gemini/skills/` or `~/.agents/skills/` | `.gemini/skills/` or `.agents/skills/` |
| Cursor | `~/.cursor/skills/` or `~/.agents/skills/` | `.cursor/skills/` or `.agents/skills/` |

`.agents/skills/` (and its `~/.agents/skills/` global form) is a shared convention across Codex CLI, Gemini CLI, and Cursor — one symlink there covers three clients at once:

```sh
ln -s "$(pwd)/skills/<skill-name>" ~/.agents/skills/<skill-name>
```

Claude Code uses its own convention instead:

```sh
ln -s "$(pwd)/skills/<skill-name>" ~/.claude/skills/<skill-name>
```

A manual symlink stays live with every local file edit (handy for developing a skill in this repo), but `gh skill update` won't track it — it only tracks skills it installed itself. These paths can change as clients evolve — check the linked official docs if a skill doesn't load.

## Adding a skill

1. Create `skills/<skill-name>/SKILL.md`. The directory name must match the `name` field (lowercase letters, numbers, and hyphens only).
2. Fill in the required frontmatter:

   ```yaml
   ---
   name: skill-name
   description: What it does and when to use it (third person, starts with "Use when...").
   ---
   ```

3. Validate with [skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref):

   ```bash
   skills-ref validate ./skills/<skill-name>
   ```

## License

MIT, see [LICENSE](LICENSE).
