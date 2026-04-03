# Agent D Brief — Den (Hotkey + Settings + State)

**Role:** Own the global keyboard shortcut, settings UI, and shared application state. You control how the app is configured and how it responds to the `⌘S Q` chord.

## Your Files

| File | Phase | Action |
|------|-------|--------|
| `Sources/SquirrelLib/HotkeyManager.swift` | 1 | Replace stub |
| `Sources/SquirrelLib/AppState.swift` | 1 | Replace stub |
| `Sources/SquirrelLib/Views/SettingsView.swift` | 1 | Replace stub |
| `Tests/SquirrelTests/AppStateTests.swift` | 2 | Create |
| `Sources/SquirrelLib/HotkeyManager.swift` | 3 | Add accessibility check |

## Interfaces You Provide

```swift
public class AppState: ObservableObject {
    @Published public var notesFilePath: String
    @Published public var launchAtLogin: Bool
    public let store: NotesStore
    public init()
}

public class HotkeyManager {
    public var onTrigger: (() -> Void)?
    public init()
    public func start()
    public func stop()
    public static func checkAccessibility() -> Bool
}

public struct SettingsView: View {
    public init(appState: AppState)
}
```

## Interfaces You Depend On

- `NotesStore` (Agent A) — created and owned by AppState
- `NoteEntry` (Agent A) — indirectly, through NotesStore

## Key Implementation Details

### HotkeyManager — Chord State Machine
```
Idle ──[⌘S]──> WaitingForQ ──[Q within 500ms]──> Trigger (call onTrigger)
                    │                                     │
                    ├──[500ms timeout]──> Idle             └──> Idle
                    └──[any other key]──> Idle
```

- Primary: `CGEvent.tapCreate` — can consume the Q keypress so it doesn't type in the foreground app
- Fallback: `NSEvent.addGlobalMonitorForEvents` — works without accessibility but Q will type in foreground app
- Requires Accessibility permission (System Settings > Privacy & Security > Accessibility)

### AppState — UserDefaults Persistence
- `notesFilePath`: stored in UserDefaults, `didSet` calls `store.updatePath()`
- `launchAtLogin`: stored in UserDefaults, `didSet` calls `SMAppService.mainApp.register/unregister()`

### SettingsView
- Three sections: Notes File (path + folder picker), Keyboard Shortcut (display only for v1), General (launch at login toggle)
- Folder picker uses `NSOpenPanel` — picks a directory, appends `notes.txt`

## Branch Strategy

- Phase 1: `agent-d/core`
- Phase 2: `agent-d/integration`
- Phase 3: `agent-d/polish`

**Wait for the VP's phase gate signal** (`.context/phase-gate-N-complete.md`) before branching for the next phase.

## Build Verification

```bash
swift build && swift test
```
