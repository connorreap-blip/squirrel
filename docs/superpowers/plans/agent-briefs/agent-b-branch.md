# Agent B Brief — Branch (Menu Bar + Input)

**Role:** Own the menu bar presence and quick input popover. You control the primary interaction surface.

## Your Files

| File | Phase | Action |
|------|-------|--------|
| `Sources/SquirrelLib/StatusBarController.swift` | 1 | Replace stub |
| `Sources/SquirrelLib/Views/InputView.swift` | 1 | Replace stub |
| `Sources/SquirrelLib/StatusBarController.swift` | 2 | Fix popover focus |
| `Sources/SquirrelLib/Views/InputView.swift` | 3 | Add escape key handler |

## Interfaces You Provide

```swift
public class StatusBarController {
    public var onViewNotes: (() -> Void)?
    public var onRevealInFinder: (() -> Void)?
    public var onOpenSettings: (() -> Void)?
    public init(appState: AppState)
    public func togglePopover()
}
```

The `on*` callbacks are wired by Agent A in Phase 2 (AppDelegate). In Phase 1, they're defined but not connected.

## Interfaces You Depend On

- `AppState` (Agent D) — passed to init, holds `store` for saving notes
- `NotesStore` (Agent A) — used via `appState.store.append()` in InputView
- `InputView` uses `appState.store.append()` to save notes

## Key Implementation Details

- **Left-click** on status item → `togglePopover()`
- **Right-click** → `showContextMenu()` with NSMenu
- Context menu uses `statusItem.menu` trick: set menu, perform click, then nil out menu so left-click still works
- Popover uses `.transient` behavior (auto-dismiss on click outside)
- InputView: Return on empty field dismisses without saving, Return with text saves and dismisses

## Branch Strategy

- Phase 1: `agent-b/core`
- Phase 2: `agent-b/integration`
- Phase 3: `agent-b/polish`

**Wait for the VP's phase gate signal** (`.context/phase-gate-N-complete.md`) before branching for the next phase.

## Build Verification

No unit tests required for UI components, but `swift build` must pass:
```bash
swift build
```
