# tdd-backlog plugin

The disciplined TDD feature loop as a Claude Code plugin: per-task backlog files, a `checks.sh`
gate, local-proof-first verification, critic passes — and **parallel execution of independent
TASKs via subagent waves** as a core feature (one orchestrator, N executors, one barrier gate).

## Install

```
/plugin marketplace add nadimtuhin/agent-tdd-backlog-plugin
/plugin install tdd-backlog@nadim-local
```

Then remove the old standalone skill to avoid duplicate matches:

```
rm -rf ~/.claude/skills/tdd-backlog
```

### Local-path alternative

If you have this repo checked out locally instead:

```
/plugin marketplace add ~/savvy/agent-tdd-backlog-plugin
/plugin install tdd-backlog@nadim-local
```

## Usage

- `/tdd-backlog init` — scaffold `backlog/` (backlog.md, checks.sh wired to the repo's real
  commands, TASK template) and prove the gate green on the untouched tree.
- `/tdd-backlog TASK-NN "title"` — spec + run one task through the loop.
- `/tdd-backlog wave` — schedule every unblocked, file-disjoint TASK into a wave of concurrent
  executor subagents; barrier = full gate + one critic pass + scoped commits.

## Wave rules (the short version)

1. Each TASK declares a `<files>` ownership manifest; any overlap = no shared wave.
2. `backlog.md` / `checks.sh` / shared configs are orchestrator-only.
3. Executors run targeted tests only; the FULL suite runs once, at the barrier, by the orchestrator.
4. Cross-task contracts are locked in the specs before the wave starts.
5. One failed executor never blocks green siblings — requeue it next wave with its failure pasted in.

Stack-specific variants (a project-specific variant, `electron-tdd-backlog`, `nextjs-tdd-backlog`) remain
separate skills that specialize this loop with real repo commands; they inherit the wave protocol.
