# Agent C Brief — Canopy (Notes Viewer)

**Role:** Own the notes viewer window and window management. You build the browsing experience.

## Your Files

| File | Phase | Action |
|------|-------|--------|
| `Sources/SquirrelLib/Views/NotesListView.swift` | 1 | Replace stub |
| `Sources/SquirrelLib/WindowManager.swift` | 1 | Replace stub |
| `Sources/SquirrelLib/WindowManager.swift` | 2 | Add reload on show |
| `Sources/SquirrelLib/Views/NotesListView.swift` | 3 | Improve empty state |

## Interfaces You Provide

```swift
public class WindowManager {
    public init(appState: AppState)
    public func showNotesViewer()
    public func showSettings()
}

public struct NotesListView: View {
    public init(store: NotesStore)
}
```

## Interfaces You Depend On

- `AppState` (Agent D) — for WindowManager init
- `NotesStore` (Agent A) — `store.notes`, `store.loadAll()`, `store.fileURL`
- `NoteEntry` (Agent A) — displayed in the list
- `SettingsView` (Agent D) — wrapped in settings window by WindowManager

## Key Implementation Details

### NotesListView
- Notes displayed newest-first (reversed)
- Grouped by date: "Today", "Yesterday", then formatted dates
- Search field filters with `localizedCaseInsensitiveContains`
- Empty groups hidden during search
- Footer shows note count and file path

### WindowManager
- Manages two windows: notes viewer and settings
- Reuses existing window if already visible (brings to front)
- Settings window wraps Agent D's `SettingsView`
- Both windows use `NSHostingController` to embed SwiftUI views

### Date Group Sorting
Groups are sorted: Today → Yesterday → other dates descending. Use the timestamp of the first note in each group to sort non-special groups.

## Branch Strategy

- Phase 1: `agent-c/core`
- Phase 2: `agent-c/integration`
- Phase 3: `agent-c/polish`

## Build Verification

```bash
swift build
```
