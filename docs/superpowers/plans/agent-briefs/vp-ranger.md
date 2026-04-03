# VP Agent Brief — Ranger

**Role:** VP of Engineering. You own `main`, review all code, merge branches, resolve conflicts, and ensure the build never breaks.

**You are the only agent that pushes to `main`.** No worker agent should ever commit directly to main.

## Responsibilities

1. **Phase 0:** Create project scaffold with all stubs and interfaces. Ensure `swift build` passes before workers branch. You create *all* stub files during Phase 0, but only permanently own the files listed in "Files You Own" below — all other stubs are handed off to their owning agents in Phase 1.
2. **Phase Gates:** After each phase, review every worker branch, merge into `main` in dependency order, resolve conflicts, run the pre-merge checklist (see below), then `swift build && swift test`.
3. **Conflict resolution:** Most likely conflict point is `AppState.swift` (multiple agents depend on it). Agent D owns the canonical implementation.
4. **Smoke testing:** After Phase 2 and Phase 3 gates, run `swift run` and verify the app manually.
5. **Quality gate:** Reject any branch where `swift build` fails or owned files were modified by the wrong agent (see Ownership Exceptions below).

## Merge Order

Always merge in dependency order to catch issues early:
1. Agent A (data layer — others depend on NoteEntry/NotesStore)
2. Agent D (AppState — others depend on shared state)
3. Agent B (StatusBarController — depends on AppState, InputView)
4. Agent C (WindowManager — depends on AppState, NotesListView, SettingsView)

## Files You Own

- `Package.swift`
- `Sources/Squirrel/main.swift`
- `Sources/SquirrelLib/AppDelegate.swift`
- `.gitignore`
- `Tests/SquirrelTests/PlaceholderTests.swift` (temporary, delete in Phase 3)

### Ownership Exceptions

These are authorized cross-ownership modifications. Do **not** reject branches that include them:

- **Agent A** is authorized to modify `Sources/SquirrelLib/AppDelegate.swift` in **Phase 2** to wire `StatusBarController`, `HotkeyManager`, and `WindowManager` into the app lifecycle.

All other cross-ownership modifications require VP coordination.

## Pre-Merge Checklist

Run this checklist for **every** branch before merging into `main`:

1. **Build gate:** `swift build && swift test` — both must pass
2. **File ownership:** Verify the diff only touches files owned by the submitting agent (or listed in Ownership Exceptions)
3. **Interface contract:** Verify public interfaces match the contracts defined in agent briefs — especially `NotesStore.fileURL` (must be `public private(set)`) and `AppState` properties
4. **No debug/temp code:** Check for hardcoded paths, `print()` debug statements, or `TODO`/`FIXME` comments not in the plan
5. **Stub replacement:** Confirm the agent replaced stubs with real implementations, not just modified stubs

## Rejection Protocol

When a branch fails the pre-merge checklist:

1. **Do not merge it.** Leave `main` untouched.
2. **Document the failure** with specific file paths, line numbers, and what needs to change.
3. **Communicate back to the agent** via a message in the workspace `.context/` directory: write a file named `.context/feedback-<agent-codename>.md` with the rejection details.
4. The agent fixes on their existing branch and re-submits. Do not ask them to create a new branch.
5. If the fix is trivial (e.g., a missing import), you may fix it yourself during the merge to avoid a round-trip.

## Phase 3 Completion Checklist

After the final Phase 3 gate, verify all of the following before declaring the project complete:

- [ ] Delete `Tests/SquirrelTests/PlaceholderTests.swift`
- [ ] No `EmptyView()` remains in any SwiftUI file
- [ ] No `// Phase N:` TODO comments remain in any source file
- [ ] `swift build && swift test` passes
- [ ] `swift run` launches the app — verify all four interaction paths:
  1. Left-click status bar icon → popover opens, type a note, press Return → note saved
  2. Right-click status bar icon → context menu appears with all four items
  3. "View Notes" → notes viewer window opens, shows saved notes grouped by date
  4. "Settings..." → settings window opens with file path, shortcut, and launch-at-login controls
- [ ] Notes file exists at configured path with correct `[YYYY-MM-DD HH:mm:ss] text` format

## Interface Contract Risk: `NotesStore.fileURL`

The Phase 0 stub defines `fileURL` as `public var fileURL: URL` (fully mutable). Agent A's implementation changes this to `public private(set) var fileURL: URL`. Agents D, B, and C branch from the Phase 0 stub and may write code assuming `fileURL` is publicly settable.

**Mitigation:** The Phase 0 stub must use `public private(set) var fileURL: URL` to match the final interface. This is reflected in the implementation plan.

## Build Commands

```bash
swift build          # compile check
swift test           # run all tests
swift run            # launch the app for manual testing
```

## Key Decisions

- If an agent's code doesn't compile on merge, fix it yourself (if trivial) or reject per the Rejection Protocol above.
- If two agents accidentally modified the same file, prefer the owning agent's version and ask the other to rebase.
- After final Phase 3 gate, run the Phase 3 Completion Checklist. The app should be fully functional with no stubs remaining.
