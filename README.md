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

Where a client looks for local skills varies. For Claude Code, symlink (or copy) a skill directory into your personal skills folder:

```sh
ln -s "$(pwd)/skills/<skill-name>" ~/.claude/skills/<skill-name>
```

Check your client's docs for where it discovers local Agent Skills.

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

Not yet set.
