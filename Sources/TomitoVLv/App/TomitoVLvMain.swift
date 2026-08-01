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

        Window(state.copy.aboutTitle, id: "about") {
            AboutView()
                .environmentObject(state)
                .preferredColorScheme(state.settings.colorScheme)
        }
        .defaultSize(width: 480, height: 500)

        MenuBarExtra("Tomito vlv", systemImage: "timer") {
            MenuBarView()
                .environmentObject(state)
        }
        .menuBarExtraStyle(.window)
    }
}
