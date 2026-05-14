import SwiftUI
import AppKit
import ServiceManagement

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover!
    private var settingsWindow: NSWindow?
    private var aboutWindow: NSWindow?
    private var faqWindow: NSWindow?
    let viewModel = AppViewModel()

    func applicationDidFinishLaunching(_ notification: Notification) {
        CrashLogger.info("InspirationBar 启动")
        NSApp.setActivationPolicy(.accessory)

        syncLaunchAtLogin()

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(
                systemSymbolName: "lightbulb.circle.fill",
                accessibilityDescription: "InspirationBar"
            )
            button.action = #selector(togglePopover)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        popover = NSPopover()
        popover.contentSize = NSSize(
            width: viewModel.settings.popoverWidth,
            height: viewModel.settings.popoverHeight
        )
        popover.contentViewController = NSHostingController(
            rootView: ContentView().environmentObject(viewModel)
        )
        popover.behavior = .transient

        // 首次启动弹出授权窗口
        if viewModel.needsFirstLaunchPrompt {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.showFirstLaunchPrompt()
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        viewModel.saveImmediately()
    }

    // MARK: - 开机自启同步

    private func syncLaunchAtLogin() {
        guard #available(macOS 13, *) else { return }
        let registered = SMAppService.mainApp.status == .enabled
        if viewModel.settings.launchAtLogin != registered {
            if viewModel.settings.launchAtLogin {
                try? SMAppService.mainApp.register()
            }
        }
    }

    private func showFirstLaunchPrompt() {
        let alert = NSAlert()
        alert.messageText = viewModel.strings.text(.loginPromptTitle)
        alert.informativeText = viewModel.strings.text(.loginPromptMessage)
        alert.addButton(withTitle: viewModel.strings.text(.loginPromptEnable))
        alert.addButton(withTitle: viewModel.strings.text(.loginPromptSkip))
        alert.alertStyle = .informational

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            if #available(macOS 13, *) {
                try? SMAppService.mainApp.register()
            }
            viewModel.settings.launchAtLogin = true
        }
        viewModel.completeSetup()
    }

    // MARK: - 状态栏交互

    @objc private func togglePopover(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            let menu = NSMenu()
            let settingsItem = NSMenuItem(
                title: viewModel.strings.text(.settingsMenu),
                action: #selector(openSettings),
                keyEquivalent: ","
            )
            settingsItem.target = self
            menu.addItem(settingsItem)

            let aboutItem = NSMenuItem(
                title: viewModel.strings.text(.aboutBar),
                action: #selector(showAbout),
                keyEquivalent: ""
            )
            aboutItem.target = self
            menu.addItem(aboutItem)

            let faqItem = NSMenuItem(
                title: viewModel.strings.text(.faq),
                action: #selector(showFAQ),
                keyEquivalent: ""
            )
            faqItem.target = self
            menu.addItem(faqItem)

            menu.addItem(.separator())
            let quitItem = NSMenuItem(
                title: viewModel.strings.text(.quitApp),
                action: #selector(quitApp),
                keyEquivalent: "q"
            )
            quitItem.target = self
            menu.addItem(quitItem)
            statusItem?.menu = menu
            sender.performClick(nil)
            statusItem?.menu = nil
        } else {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.contentSize = NSSize(
                    width: viewModel.settings.popoverWidth,
                    height: viewModel.settings.popoverHeight
                )
                popover.show(
                    relativeTo: sender.bounds,
                    of: sender,
                    preferredEdge: .minY
                )
                if #available(macOS 14, *) {
                    NSApp.activate(ignoringOtherApps: true)
                }
            }
        }
    }

    // MARK: - 窗口

    @objc private func openSettings() {
        popover.performClose(nil)

        if settingsWindow == nil {
            let controller = NSHostingController(
                rootView: SettingsView().environmentObject(viewModel)
            )
            let window = NSWindow(contentViewController: controller)
            window.title = viewModel.strings.text(.settingsMenu)
            window.styleMask = [.titled, .closable, .miniaturizable]
            window.isReleasedWhenClosed = false
            window.center()
            settingsWindow = window
        }

        settingsWindow?.title = viewModel.strings.text(.settingsMenu)
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func showAbout() {
        popover.performClose(nil)

        if aboutWindow == nil {
            let controller = NSHostingController(
                rootView: AboutView().environmentObject(viewModel)
            )
            let window = NSWindow(contentViewController: controller)
            window.title = viewModel.strings.text(.aboutBar)
            window.styleMask = [.titled, .closable]
            window.isReleasedWhenClosed = false
            window.setContentSize(NSSize(width: 340, height: 240))
            window.center()
            aboutWindow = window
        }

        aboutWindow?.title = viewModel.strings.text(.aboutBar)
        aboutWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func showFAQ() {
        popover.performClose(nil)

        if faqWindow == nil {
            let controller = NSHostingController(
                rootView: FAQView().environmentObject(viewModel)
            )
            let window = NSWindow(contentViewController: controller)
            window.title = viewModel.strings.text(.faq)
            window.styleMask = [.titled, .closable]
            window.isReleasedWhenClosed = false
            window.setContentSize(NSSize(width: 440, height: 380))
            window.center()
            faqWindow = window
        }

        faqWindow?.title = viewModel.strings.text(.faq)
        faqWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func quitApp() {
        viewModel.saveImmediately()
        NSApp.terminate(self)
    }
}
