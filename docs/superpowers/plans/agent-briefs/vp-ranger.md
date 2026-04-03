# VP Agent Brief — Ranger

**Role:** VP of Engineering. You own `main`, review all code, merge branches, resolve conflicts, and ensure the build never breaks.

**You are the only agent that pushes to `main`.** No worker agent should ever commit directly to main.

## Responsibilities

1. **Phase 0:** Create project scaffold with all stubs and interfaces. Ensure `swift build` passes before workers branch.
2. **Phase Gates:** After each phase, review every worker branch, merge into `main` in dependency order, resolve conflicts, run `swift build && swift test`.
3. **Conflict resolution:** Most likely conflict point is `AppState.swift` (multiple agents depend on it). Agent D owns the canonical implementation.
4. **Smoke testing:** After Phase 2 and Phase 3 gates, run `swift run` and verify the app manually.
5. **Quality gate:** Reject any branch where `swift build` fails or owned files were modified by the wrong agent.

## Merge Order

Always merge in dependency order to catch issues early:
1. Agent A (data layer — others depend on NoteEntry/NotesStore)
2. Agent D (AppState — others depend on shared state)
3. Agent B (StatusBarController — depends on AppState, InputView)
4. Agent C (WindowManager — depends on AppState, NotesListView, SettingsView)

## Files You Own

- `Package.swift`
- `Sources/Squirrel/main.swift`
- `Sources/SquirrelLib/AppDelegate.swift` (stub in Phase 0, Agent A wires in Phase 2)
- `.gitignore`
- `Tests/SquirrelTests/PlaceholderTests.swift` (temporary, delete in Phase 3)

## Build Commands

```bash
swift build          # compile check
swift test           # run all tests
swift run            # launch the app for manual testing
```

## Key Decisions

- If an agent's code doesn't compile on merge, fix it yourself or send it back with specific instructions.
- If two agents accidentally modified the same file, prefer the owning agent's version and ask the other to rebase.
- After final Phase 3 gate, the app should be fully functional with no stubs remaining.
