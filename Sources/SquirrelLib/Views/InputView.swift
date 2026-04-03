import SwiftUI

public struct InputView: View {
    @ObservedObject var appState: AppState
    @State private var text = ""
    @State private var errorMessage: String?
    let dismiss: () -> Void

    public init(appState: AppState, dismiss: @escaping () -> Void) {
        self.appState = appState
        self.dismiss = dismiss
    }

    public var body: some View {
        VStack(spacing: 8) {
            TextField("Stash a thought...", text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: 14))
                .padding(10)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(8)
                .onSubmit {
                    saveAndDismiss()
                }

            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 11))
                    .foregroundColor(.red)
            }

            HStack {
                Text("Return to stash")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Spacer()
                Text("esc to dismiss")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)
        }
        .padding(12)
        .frame(width: 360)
    }

    private func saveAndDismiss() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            dismiss()
            return
        }

        do {
            errorMessage = nil
            try appState.store.append(trimmed)
            text = ""
            dismiss()
        } catch {
            errorMessage = "Can't write to file - check Settings"
        }
    }
}
