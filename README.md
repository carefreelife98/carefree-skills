# carefree-skills

A collection of portable [Agent Skills](https://agentskills.io) — reusable capabilities for AI coding agents (Claude Code, Codex CLI, Gemini CLI, Cursor, and other [agentskills.io](https://agentskills.io)-compatible clients).

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
