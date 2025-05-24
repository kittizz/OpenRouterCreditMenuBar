import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var creditManager: OpenRouterCreditManager

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "creditcard")
                    .foregroundColor(.blue)
                Text("OpenRouter Credit")
                    .font(.headline)
            }
            .padding(.top, 8)

            Divider()

            if creditManager.isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading...")
                        .font(.caption)
                }
            } else if let credit = creditManager.currentCredit {
                VStack(spacing: 4) {
                    Text("Available Credit")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(String(format: "%.4f", credit))")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            } else if let error = creditManager.errorMessage {
                VStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                    Text("Error")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(error)
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                }
            }

            Divider()

            VStack(spacing: 8) {
                Button("Refresh") {
                    Task {
                        await creditManager.fetchCredit()
                    }
                }
                .controlSize(.small)

                Button("View Activity") {
                    if let url = URL(string: "https://openrouter.ai/activity") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .controlSize(.small)

                SettingsLink {
                    Text("Settings")
                }
                .controlSize(.small)

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .controlSize(.small)
            }
        }
        .padding()
        .frame(width: 200)
    }
}
