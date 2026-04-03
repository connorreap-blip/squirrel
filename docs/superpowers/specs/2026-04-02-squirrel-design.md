# Squirrel — macOS Menu Bar Note Stasher

**Date:** 2026-04-02
**Status:** Design approved

## Overview

Squirrel is a macOS menu bar app for capturing quick notes. Click the squirrel icon (or press `⌘S Q`), type a thought, hit Return — done. Every entry is appended to a plain text file with a timestamp. A built-in viewer lets you browse and search your notes.

## Architecture

- **Language:** Swift
- **UI Framework:** SwiftUI with minimal AppKit (`NSStatusItem`, `NSPopover`, global hotkey monitor)
- **App Type:** Menu bar only — no Dock icon (`LSUIElement = true` in Info.plist)
- **Target:** macOS 13+ (Ventura)
- **Storage:** Plain text file, one note per line
- **Dependencies:** None (pure Apple frameworks)

## Interaction Model

### Menu Bar Icon

- Squirrel emoji (🐿️) rendered as an `NSStatusItem` using SF Symbols or a custom template image for proper light/dark adaptation
- **Left-click:** Opens the quick input popover
- **Right-click:** Opens the context menu

### Quick Input Popover

- `NSPopover` anchored to the status item
- Contains a single-line `TextField` with placeholder text: "Stash a thought..."
- **Return:** Appends the note to the file and dismisses the popover
- **Escape:** Dismisses without saving
- Input field auto-focuses when popover appears
- Follows system appearance (light/dark mode)

### Global Keyboard Shortcut

- **Chord:** `⌘S` then `Q` — press `⌘S`, release, then press `Q`
- Opens the same popover as left-clicking the icon
- If popover is already open, the chord dismisses it
- Configurable in Settings
- Implemented via `NSEvent.addGlobalMonitorForEvents` with a chord state machine (listen for `⌘S` keydown, then `Q` within 500ms)

### Right-Click Context Menu

1. **View Notes** — opens the Squirrel notes viewer window
2. **Reveal in Finder** — shows the notes file in Finder via `NSWorkspace`
3. **Settings...** — opens the settings window
4. **Quit Squirrel** — terminates the app

## Notes Viewer

- Separate `NSWindow` (not a popover) — resizable, closable
- Opened from the right-click context menu "View Notes"
- Reads and parses the notes file on open

### Layout

- **Title bar area:** Squirrel icon + "Squirrel" label + search field (right-aligned)
- **Content:** Scrollable list of notes grouped by date
  - Group headers: "Today", "Yesterday", then formatted dates (e.g., "Mar 31, 2026")
  - Each note shows the text (left) and time (right, e.g., "9:14 PM")
- **Footer:** Note count + file path display

### Search

- Real-time filtering as the user types
- Case-insensitive substring match against note text
- Filtered results maintain date grouping (empty groups hidden)

## Storage

### File Format

```
[2026-04-02 21:14:32] Remember to refactor the auth middleware
[2026-04-02 15:42:08] Call dentist tomorrow at 10
[2026-04-02 13:08:44] Look into SwiftData for the next project
```

- One line per note: `[YYYY-MM-DD HH:mm:ss] <note text>\n`
- Timestamps in local time
- UTF-8 encoded plain text
- Append-only — the app never modifies or deletes existing lines

### Default Path

- `~/Documents/Squirrel/notes.txt`
- Directory created automatically on first launch if it doesn't exist
- Configurable in Settings via a folder picker

## Settings

A simple settings window with three controls:

1. **Notes file path** — current path display + "Choose..." button (folder picker via `NSOpenPanel`)
2. **Keyboard shortcut** — displays current chord, allows reconfiguration
3. **Launch at login** — toggle switch (implemented via `SMAppService` on macOS 13+)

Settings stored in `UserDefaults`.

## System Appearance

- Follows macOS system appearance automatically (light/dark mode)
- No custom theming — uses standard SwiftUI styling for native look

## Project Structure

```
Squirrel/
├── Squirrel.xcodeproj
├── Squirrel/
│   ├── SquirrelApp.swift          # App entry point, NSStatusItem setup
│   ├── AppState.swift             # Observable app state (settings, notes data)
│   ├── StatusBarController.swift  # Menu bar icon, popover, context menu management
│   ├── HotkeyManager.swift        # Global keyboard chord listener
│   ├── NotesStore.swift           # File read/write/parse operations
│   ├── Views/
│   │   ├── InputView.swift        # Quick input popover content
│   │   ├── NotesViewerWindow.swift # Notes viewer window setup
│   │   ├── NotesListView.swift    # Scrollable notes list with date groups
│   │   ├── SearchBar.swift        # Search field component
│   │   └── SettingsView.swift     # Settings window content
│   ├── Models/
│   │   └── NoteEntry.swift        # Note data model (timestamp + text)
│   ├── Assets.xcassets/
│   │   └── AppIcon.appiconset/    # Squirrel app icon
│   └── Info.plist
└── README.md
```

## Edge Cases

- **Empty input:** Return on an empty field dismisses without appending
- **File permissions:** If the file can't be written, show a brief inline error in the popover ("Can't write to file — check Settings")
- **File deleted externally:** Recreate on next write; viewer shows empty state
- **Very large file:** Viewer loads lazily (read last N lines first, load more on scroll up)
- **Concurrent writes:** Not a concern — single-process, serial appends
