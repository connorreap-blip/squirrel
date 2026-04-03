import SwiftUI
import AppKit

public struct SettingsView: View {
    @ObservedObject private var appState: AppState

    public init(appState: AppState) {
        self.appState = appState
    }

    public var body: some View {
        Form {
            Section("Notes File") {
                HStack {
                    Text(appState.notesFilePath)
                        .font(.system(size: 12, design: .monospaced))
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Spacer()
                    Button("Choose...") {
                        chooseFolder()
                    }
                }
            }

            Section("Keyboard Shortcut") {
                HStack {
                    Text("\u{2318}S then Q")
                    Spacer()
                    Text("Opens quick input")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }

            Section("General") {
                Toggle("Launch at login", isOn: $appState.launchAtLogin)
            }
        }
        .formStyle(.grouped)
        .frame(width: 400, height: 220)
        .padding()
    }

    static func notesFilePath(forDirectory directoryURL: URL) -> String {
        directoryURL.appendingPathComponent("notes.txt").path
    }

    private func chooseFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "Choose where Squirrel saves notes"
        panel.prompt = "Select Folder"

        if panel.runModal() == .OK, let selectedDirectory = panel.url {
            appState.notesFilePath = Self.notesFilePath(forDirectory: selectedDirectory)
        }
    }
}
