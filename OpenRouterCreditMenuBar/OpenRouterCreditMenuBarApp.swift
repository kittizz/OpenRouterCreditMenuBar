//
//  OpenRouterCreditMenuBarApp.swift
//  OpenRouterCreditMenuBar
//
//  Created by Kittithat Patepakorn on 24/5/2568 BE.
//

import SwiftUI

@main
struct OpenRouterCreditMenuBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
                .environmentObject(appDelegate.creditManager)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    @Published var creditManager = OpenRouterCreditManager()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // ซ่อน dock icon แต่ยังคงให้ app สามารถแสดง window ได้
        NSApp.setActivationPolicy(.accessory)

        // ปิดเฉพาะ main window ไม่ใช่ทุก window
        if let mainWindow = NSApp.windows.first(where: { $0.title.isEmpty }) {
            mainWindow.close()
        }

        // สร้าง menu bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let statusButton = statusItem?.button {
            statusButton.title = "Loading..."
            statusButton.action = #selector(showMenu)
            statusButton.target = self
        }

        // สร้าง popover
        popover = NSPopover()
        popover?.contentViewController = NSHostingController(
            rootView: MenuBarView()
                .environmentObject(creditManager)
        )
        popover?.behavior = .transient

        // เริ่ม fetch credit
        Task {
            await creditManager.fetchCredit()
            await MainActor.run {
                updateMenuBarTitle()
            }
        }

        // ตั้ง timer สำหรับ refresh
        Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
            Task {
                await self.creditManager.fetchCredit()
                await MainActor.run {
                    self.updateMenuBarTitle()
                }
            }
        }
    }

    @objc func showMenu() {
        if let statusButton = statusItem?.button {
            if popover?.isShown == true {
                popover?.performClose(nil)
            } else {
                popover?.show(
                    relativeTo: statusButton.bounds, of: statusButton, preferredEdge: .minY)
            }
        }
    }

    func updateMenuBarTitle() {
        if let credit = creditManager.currentCredit {
            statusItem?.button?.title = "$\(String(format: "%.2f", credit))"
        } else {
            statusItem?.button?.title = "Error"
        }
    }
}
