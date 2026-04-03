# Agent A Brief — Acorn (Data Layer)

**Role:** Own the data model and file I/O. You are the foundation — other agents depend on `NoteEntry` and `NotesStore`.

## Your Files

| File | Phase | Action |
|------|-------|--------|
| `Sources/SquirrelLib/Models/NoteEntry.swift` | 1 | Replace stub |
| `Sources/SquirrelLib/NotesStore.swift` | 1 | Replace stub |
| `Tests/SquirrelTests/NoteEntryTests.swift` | 1 | Create |
| `Tests/SquirrelTests/NotesStoreTests.swift` | 1 | Create |
| `Sources/SquirrelLib/AppDelegate.swift` | 2 | Replace stub (wiring) — **VP-authorized cross-ownership exception** |
| `Sources/SquirrelLib/NotesStore.swift` | 3 | Add `loadRecent()` |
| `Tests/SquirrelTests/NotesStoreTests.swift` | 3 | Add lazy loading test |

## Interfaces You Provide

Other agents import and use these types. Do not change the public interface without coordinating with VP.

```swift
// NoteEntry
public struct NoteEntry: Identifiable, Equatable {
    public let id: UUID
    public let timestamp: Date
    public let text: String
    public init(id: UUID = UUID(), timestamp: Date = Date(), text: String)
    public var fileLine: String
    public static func parse(_ line: String) -> NoteEntry?
}

// NotesStore
public class NotesStore: ObservableObject {
    @Published public var notes: [NoteEntry]
    public private(set) var fileURL: URL
    public init(fileURL: URL)
    public func updatePath(_ url: URL)
    public func append(_ text: String) throws
    public func loadAll()
}
```

## Interfaces You Depend On

- `AppState` (from Agent D) — used in Phase 2 when wiring AppDelegate

## Branch Strategy

- Phase 1: `agent-a/core` (branch from `main` after Phase 0)
- Phase 2: `agent-a/integration` (branch from `main` after Phase 1 gate)
- Phase 3: `agent-a/polish` (branch from `main` after Phase 2 gate)

**Wait for the VP's phase gate signal** (`.context/phase-gate-N-complete.md`) before branching for the next phase.

## TDD Protocol

You are the primary test-writing agent. Follow strict TDD:
1. Write the failing test
2. Run it, confirm it fails
3. Write minimal implementation
4. Run it, confirm it passes
5. Commit

## Build Verification

Before marking any phase complete:
```bash
swift build && swift test
```
Both must pass.
