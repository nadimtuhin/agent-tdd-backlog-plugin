---
name: tdd-backlog
description: The disciplined feature loop for any codebase, stack-agnostic — TDD red→green, per-task backlog files with a checks.sh gate, local-proof-first verification (exercise the REAL thing, not just unit tests), critic passes before committing to an approach and before declaring done, and PARALLEL execution of independent tasks via subagent waves. The portable base that stack-specific variants (nextjs-tdd-backlog / electron-tdd-backlog / a project-specific variant) specialize. Use for "start a task", "add a feature the disciplined way", "tdd backlog", "run tasks in parallel", backlog/critic/TDD requests when no stack-specific version fits.
triggers:
  - tdd backlog
  - start a task
  - disciplined loop
  - critic loop
  - backlog task
  - parallel tasks
  - task wave
argument-hint: "[init | TASK-NN \"title\" | wave]"
---

# tdd-backlog

Loop: **plan → (wave-schedule) → red→green → local-proof → critic → commit**, with a paper trail.
Portable across any language/stack. Lazy by default — the ladder (does this need to exist? stdlib?
native feature? one line?) governs *what* you build; the discipline governs *how* you prove it.
If a stack-specific version exists (`nextjs-tdd-backlog`, `electron-tdd-backlog`, or a project-specific variant),
prefer it — it bakes in the real commands and traps.

## 0. One-time init per repo (`init`)

Create the backlog scaffold if absent:

```
backlog/
  backlog.md        # rev logs, decisions, running index
  checks.sh         # repo gate — 0 failures required before "done"
  TASK-*.md         # one per task
```

Copy `templates/checks.sh` and `templates/TASK-template.md`, then **wire `checks.sh` to this repo's real
commands** — detect them, don't guess: read `package.json` scripts / `Makefile` / `justfile` / `pyproject.toml`
/ `Cargo.toml` / CI workflow. Pin the test runtime the repo pins (`.nvmrc`, `.tool-versions`, `.python-version`).
**Prove the gate green on the untouched tree before any code** — a baseline that's already red makes every
later "green" claim a lie. Pre-existing failures: fix them first (as their own TASK) or baseline them
explicitly so the gate fails only on NEW breakage.

## 1. Plan the task(s)

- Broad/unclear request → explore first, then write `TASK-NN.md`. Ambiguous? State the assumption and
  proceed; ask ONE focused question only if the answer changes what you build.
- Fill `<context>` (why), `<decisions>` (locked choices + rejected ones), `<files>` (ownership manifest —
  see Parallel waves), `<dod>` (checkboxes), `<ac>` (workspace + behavior).
- **Name the expensive-to-move decision up front** — the seam that's costly to change later (process/module
  boundary, data shape, API contract, sync vs async). Lock it in `<decisions>`; that's the one worth a critic's time.
- **Lock cross-task interfaces in the spec, not the code.** If TASK-07 will call a function TASK-06 creates,
  write the exact signature into BOTH specs before either starts — that's what lets them run in the same
  wave without one agent guessing the other's API.
- **Critic pass BEFORE code** — sanity-check the approach. Cheap now, expensive after you've built the wrong
  thing. Use a read-only reviewer subagent (`critic` / `code-reviewer` / `Plan`). Portable fallback: write
  the approach down and red-team it against the alternatives you rejected.

## 2. Parallel waves — run independent TASKs concurrently (core)

One orchestrator, N executor subagents, one gate. The orchestrator NEVER implements task code itself —
it specs, schedules, verifies, and integrates. Subagents implement.

**Scheduling.** Build a dependency table (TASK × deps × files-owned). A **wave** = every pending TASK whose
deps are all done AND whose `<files>` manifests are pairwise disjoint. Spawn one executor subagent per TASK
in the wave — **all in a single message** so they run concurrently. One TASK in the wave → degrade to solo;
the loop is identical.

**File ownership is the law.**
- Each TASK's `<files>` manifest lists every file it may create or edit. Two TASKs colliding on ANY file
  cannot share a wave — split the file out, extract the shared change into its own tiny prerequisite TASK,
  or sequence them. "We'll merge it later" is how parallel work dies.
- Orchestrator-only files: `backlog/backlog.md`, `backlog/checks.sh`, shared configs (tsconfig, CI, lint).
  Subagents never touch them; each subagent writes ONLY its own `TASK-NN.md` changelog + its owned files.
- Disjoint source files but shared mutable test state (one dev server port, one DB file, a junit report
  path, module singletons reset in beforeEach) = still a collision **at test time**: subagents run only
  their own targeted tests; the FULL suite runs once, at the barrier, by the orchestrator.

**The executor brief** (per subagent): the spec file path, the repo's environment gotchas (runtime pin,
package manager, timeout caps), the red→green sequence with "run the RED, paste its output into your
TASK-NN.md changelog before going green", targeted-tests-only, no commits, deviations must be named.
Default executor model: the cheap-capable tier (e.g. sonnet); escalate a single hard TASK rather than
the whole wave.

**Barrier at wave end.**
1. Orchestrator re-runs the full gate `bash backlog/checks.sh` itself — never trust N green claims that
   each saw only a slice of the tree.
2. ONE critic pass (read-only subagent) over the combined wave diff — cross-task integration bugs live
   in the seams no single executor saw.
3. Critic findings: fix (small → orchestrator inline; big → bounce back to the owning executor), re-gate.
4. ONE commit pass, scoped paths per TASK, logical chunks (delegate to a fresh subagent; never bulk-stage —
   a concurrent session may share the checkout).
5. Log a `rev.N` per TASK in `backlog.md`, mark the wave done, schedule the next wave.

**Failure isolation.** One executor failing/red does NOT block its wave siblings — take their green work
through the barrier, requeue the failed TASK in the next wave with the failure output pasted into its spec
(`<preflight>` gains a "known-red from wave N" note). If the SAME task fails twice with the same error,
stop scheduling it and surface the fundamental issue to the human.

**When NOT to parallelize.** Heavily coupled type-level changes (one refactor rippling through callers),
a migration both tasks depend on, or a wave of one — sequence instead. Parallelism is for genuinely
disjoint work; forcing it manufactures merge debugging that costs more than the wall-clock it saved.

## 3. TDD red → green

- Failing test FIRST. Pure logic → unit test. Behavior that crosses a boundary → integration/e2e.
- Run the test, watch it fail **for the right reason** (asserts the thing, not a typo/import error), then
  implement the minimum to green. No test that always passes; no `.skip`/`.only`/commented assertions left behind.
- **Push logic to pure functions at the edges** — extract it out of framework callbacks, request handlers,
  and lifecycle hooks so it's testable without spinning up the whole machine. Test the pure core in unit;
  prove the wiring with a real run, not a mock of the framework (mocking the framework proves your mock).
- Reset shared/singleton state between tests (`beforeEach`) so order can't hide a bug. Keep functions small, one thing each.
- Author and review are SEPARATE passes — don't self-approve in the same breath as writing.

## 4. Local-proof-first (the part people skip)

A passing unit test is not proof the feature works. **Exercise the real thing** and observe behavior. Match the proof to the surface:

| Surface | Prove it by |
|---|---|
| Pure logic / a function | Unit test — no framework or I/O imported in the tested module |
| UI component | Component test (render + assert visible output), or drive it in a browser if it hits real data/bridges |
| HTTP endpoint / webhook / RPC | Hit it with a real request (`curl`/client), assert status + body — not just a handler unit test |
| Anything crossing a process / network / render / IPC boundary | Drive the **real** running thing end-to-end; a mocked boundary proves the mock |
| CLI / script | Run it with real args, assert exit code + output |
| Caching / build-mode / packaging / migrations / auth | Reproduce in the mode that actually differs (prod build, real DB, real token) — dev mode lies here |
| A property ("never imports X", "one owner per lock") | A subprocess/instrumented check that can actually go RED on the property — in-process tests are often structurally blind to it |

Start long-running processes backgrounded and wait for ready before hitting them (else the run hangs).
Paste the **actual output** into `<changelog>` — "looks right" is not evidence; pasted output is.

## 5. Critic loop before done

- **Second critic pass** before declaring complete (same options as step 1). Save the deliverable files first
  so the work survives an interrupted pass — durability, not a commit (step 6).
- Run `bash backlog/checks.sh` → **0 failures** (test + typecheck + lint; add the heavier build/e2e tier via
  its documented flag when you touched a boundary, packaging, or a user-visible flow). Run extra verifiers in parallel.
- If the gate has *known* pre-existing failures, the gate must baseline them and fail only on NEW ones —
  a gate that's red on a clean tree trains people to ignore it. Never make "0 failures" a lie on day one.
- Name the ceilings you're accepting (the cache you didn't invalidate, the N+1, the single case you tested)
  in the changelog — don't gold-plate them, don't hide them. Verification fails → iterate, don't mark done on red.

## 6. Log + commit

- Append a `rev.N` entry to `backlog.md`: what shipped, the load-bearing gotcha, pasted proof.
- Commit only when asked (or when the loop's operating agreement says each wave lands). Match the repo's
  branch + message convention (detect it from `git log` — don't impose `feat/…` or a per-issue branch if
  the repo doesn't). Logical chunks, scoped paths — never bulk-stage on a shared checkout. No AI attribution
  unless the repo wants it.

## Anti-patterns (blockers, not style nits)

- Marking done on "the unit test passes" without exercising the real thing.
- A test that mocks the boundary/framework and asserts against the mock.
- Running tests on a different runtime/version than the repo pins (masks ABI/version drift).
- `test.skip` / `.only` / assertions that can't fail; a test that passes even when the code is deleted.
- Leaking singleton/global state between tests (no reset).
- Silent truncation (top-N, sampling) with no log line saying what was dropped.
- Self-approving in the same pass that wrote the code; committing secrets; refactors/features not asked for.
- **Wave crimes:** two subagents sharing a file "carefully"; a subagent editing backlog.md/checks.sh/shared
  configs; trusting N per-agent green claims instead of one barrier gate; parallelizing type-coupled
  refactors; letting a failed task block its independent siblings.

See `templates/TASK-template.md` and `templates/checks.sh`.
