# TASK-NN [AREA] — <short title>

Owner: <you> · Wave: <wave-N or solo> · Deps: <TASK ids>

<context>
Why this exists, what's true today, what's out of scope. One paragraph.
</context>

<decisions>
- The expensive-to-move seam (module/process boundary, data shape, sync vs async) — and why.
- Locked choice + the alternative rejected and why.
- Contract: API/CLI signature, event/channel names, data shape. If another TASK consumes this
  contract, the exact signature is written in BOTH specs before either starts (wave rule).
</decisions>

<files>
<!-- Ownership manifest — every file this TASK may create or edit. The wave scheduler treats any
     overlap with another TASK as a hard conflict (no shared wave). Orchestrator-only files
     (backlog.md, checks.sh, shared configs) may NOT appear here. -->
- path/to/file.ts (edit)
- path/to/new-module.ts (new)
- path/to/module.test.ts (new)
</files>

<preflight>
```bash
# a command that shows the BEFORE state (should fail / return 0 matches)
grep -rn "<marker>" <code-dirs>   # 0 before
```
</preflight>

<tdd>
`<file>.test.*` — <pure cases: valid → x, invalid/garbage → null/throw>. Red (right reason) → green.
Behavior: <how the real thing is driven — e2e/curl/CLI> asserts <visible marker>.
Wave mode: run ONLY this TASK's targeted tests here; the full suite runs once at the wave barrier.
</tdd>

<dod>
- [ ] pure logic unit-tested (red→green), no framework/I/O import in the tested module
- [ ] real thing exercised (e2e / request / CLI run), output pasted below
- [ ] typecheck clean, lint clean
- [ ] ceilings named, not gold-plated
- [ ] touched only files in <files>
</dod>

<ac>
- ac(workspace): `bash backlog/checks.sh` green. Run tests on the runtime the repo pins, not the shell default.
- ac(behavior): <command that drives the real running thing> → asserts <marker flips/appears>.
- ac(gates): `bash backlog/checks.sh` → 0 failures (`CHECKS_FULL=1` when a boundary/packaging/flow was touched).
</ac>

<changelog>
- <files touched, one line each>

RED proof (pasted before going green):
```
<actual failing output, failing for the right reason>
```

Behavior/AC proof (pasted, not described):
```
<actual command output>
```

Ceilings (named): <limits accepted, with the upgrade path>.
</changelog>
