import AppKit
import SwiftUI

@main
struct TomitoVLvApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var state = TimerState()

    var body: some Scene {
        WindowGroup {
            TimerView()
                .environmentObject(state)
                .preferredColorScheme(state.settings.colorScheme)
                .frame(minWidth: 640, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 720, height: 640)
        .commands {
            CommandMenu("Timer") {
                Button(state.copy.startPauseResume) { state.toggleRunning() }
                    .keyboardShortcut(.return, modifiers: .command)
                Button(state.copy.skip) { state.skip() }
                    .keyboardShortcut(.rightArrow, modifiers: .command)
                Button(state.copy.restart) { state.restart() }
                    .keyboardShortcut(.delete, modifiers: .command)
            }
        }

        Window(state.copy.settings, id: "settings") {
            PreferencesView()
                .environmentObject(state)
                .preferredColorScheme(state.settings.colorScheme)
        }
        .defaultSize(width: 420, height: 360)

        Window(state.copy.aboutTitle, id: "about") {
            AboutView()
                .environmentObject(state)
                .preferredColorScheme(state.settings.colorScheme)
        }
        .defaultSize(width: 480, height: 500)

        MenuBarExtra {
            MenuBarView()
                .environmentObject(state)
        } label: {
            HStack(spacing: 4) {
                Image(nsImage: MenuBarTomatoIcon.image)
                if state.isRunning {
                    Text(state.formattedTime)
                        .monospacedDigit()
                }
            }
            .accessibilityLabel(state.isRunning ? "Tomito vlv, \(state.formattedTime) remaining" : "Tomito vlv")
        }
        .menuBarExtraStyle(.window)
    }
}

private enum MenuBarTomatoIcon {
    static let image: NSImage = {
        let image = NSImage(size: NSSize(width: 18, height: 18))
        image.lockFocus()
        NSColor.black.setFill()

        NSBezierPath(ovalIn: NSRect(x: 2, y: 2, width: 14, height: 12)).fill()
        NSBezierPath(roundedRect: NSRect(x: 8, y: 12, width: 2, height: 4), xRadius: 1, yRadius: 1).fill()

        let leaves = NSBezierPath()
        leaves.move(to: NSPoint(x: 9, y: 12))
        leaves.line(to: NSPoint(x: 4.5, y: 15.5))
        leaves.line(to: NSPoint(x: 8.5, y: 14))
        leaves.line(to: NSPoint(x: 9, y: 17))
        leaves.line(to: NSPoint(x: 10, y: 14))
        leaves.line(to: NSPoint(x: 14, y: 15.5))
        leaves.close()
        leaves.fill()

        image.unlockFocus()
        image.isTemplate = true
        return image
    }()
}
