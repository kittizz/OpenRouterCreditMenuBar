//
//  SettingsView.swift
//  OpenRouterCreditMenuBar
//

import ServiceManagement
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var creditManager: OpenRouterCreditManager
    @State private var apiKey: String = ""
    @State private var isEnabled: Bool = true
    @State private var openAtLogin: Bool = false
    @State private var refreshInterval: Double = 300  // default 5 minutes

    private let refreshIntervalOptions: [Double] = [30, 60, 180, 300, 600, 1800, 3600]

    var body: some View {
        Form {
            Section("General") {
                Toggle("Enable Credit Monitoring", isOn: $isEnabled)
                    .onChange(of: isEnabled) { _, newValue in
                        creditManager.isEnabled = newValue
                        if newValue {
                            Task {
                                await creditManager.fetchCredit()
                            }
                        }
                    }

                Toggle("Open at Login", isOn: $openAtLogin)
                    .onChange(of: openAtLogin) { _, newValue in
                        setLoginItemEnabled(newValue)
                    }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Refresh Interval")
                        .font(.headline)

                    Picker("Refresh Interval", selection: $refreshInterval) {
                        Text("30 seconds").tag(30.0)
                        Text("1 minute").tag(60.0)
                        Text("3 minutes").tag(180.0)
                        Text("5 minutes").tag(300.0)
                        Text("10 minutes").tag(600.0)
                        Text("30 minutes").tag(1800.0)
                        Text("1 hour").tag(3600.0)
                    }
                    .pickerStyle(.menu)
                    .onChange(of: refreshInterval) { _, newValue in
                        creditManager.refreshInterval = newValue
                    }

                    Text("How often to check credit balance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Section("API Configuration") {
                SecureField("OpenRouter API Key", text: $apiKey)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: apiKey) { _, newValue in
                        creditManager.apiKey = newValue
                    }
                HStack {
                    Button("Test Connection") {
                        Task {
                            await creditManager.fetchCredit()
                        }
                    }
                    .disabled(apiKey.isEmpty)

                    if creditManager.isLoading {
                        ProgressView()
                            .scaleEffect(0.5)
                    }
                }
            }

            if let error = creditManager.errorMessage {
                Section("Status") {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .foregroundColor(.red)
                }
            }
        }
        .formStyle(.grouped)
        .frame(maxWidth: 400, maxHeight: .infinity)
        .onAppear {
            loadSettings()
        }
    }

    private func loadSettings() {
        apiKey = creditManager.apiKey
        isEnabled = creditManager.isEnabled
        refreshInterval = creditManager.refreshInterval
        openAtLogin = SMAppService.mainApp.status == .enabled
    }

    private func setLoginItemEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to \(enabled ? "enable" : "disable") login item: \(error)")
        }
    }
}
