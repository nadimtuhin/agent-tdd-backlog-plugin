# Contributing

## Skills

Skills live in `skills/`. Each skill is a `SKILL.md` with YAML frontmatter + markdown body.

To add or fix a skill:
1. Fork + clone
2. Edit or create `skills/<name>/SKILL.md`
3. Validate `plugin.json` is still valid: `python3 -m json.tool plugin.json`
4. Open a PR — describe what the skill does and why it's needed

## plugin.json

Declares all skills and metadata. Must remain valid JSON. CI checks this automatically.

## PR checklist

- [ ] `plugin.json` valid JSON (`python3 -m json.tool plugin.json`)
- [ ] Skill frontmatter has `name`, `description`, `triggers`
- [ ] No secrets or personal paths in skill content
- [ ] PR description explains the change

## Issues

Bug reports and feature requests welcome via GitHub Issues. Use the provided templates.
