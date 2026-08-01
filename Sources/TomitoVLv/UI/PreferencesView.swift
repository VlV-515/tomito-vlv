import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject private var state: TimerState

    var body: some View {
        TabView {
            general
                .tabItem { Label(state.copy.general, systemImage: "timer") }
            appearance
                .tabItem { Label(state.copy.appearance, systemImage: "paintpalette") }
            advanced
                .tabItem { Label(state.copy.advanced, systemImage: "moon.stars") }
        }
        .padding(12)
        .frame(width: 500, height: 360)
    }

    private var general: some View {
        Form {
            Section {
                SettingTextField(state.copy.sessionDuration, value: $state.settings.sessionMinutes, in: 1...180, unit: state.copy.minutes)
                SettingTextField(state.copy.shortBreak, value: $state.settings.shortBreakMinutes, in: 1...60, unit: state.copy.minutes)
                SettingTextField(state.copy.longBreak, value: $state.settings.longBreakMinutes, in: 1...120, unit: state.copy.minutes)
                SettingTextField(state.copy.longBreakEvery, value: $state.settings.longBreakEvery, in: 2...12, unit: state.copy.sessions)
            }
            Section {
                Toggle(state.copy.autoSession, isOn: $state.settings.autoStartSession)
                Toggle(state.copy.autoBreak, isOn: $state.settings.autoStartBreak)
                Toggle(state.copy.breaks, isOn: $state.settings.breaksEnabled)
            }
        }
        .formStyle(.grouped)
        .onChange(of: state.settings.sessionMinutes) { _ in state.applySettings() }
        .onChange(of: state.settings.shortBreakMinutes) { _ in state.applySettings() }
        .onChange(of: state.settings.longBreakMinutes) { _ in state.applySettings() }
    }

    private var appearance: some View {
        Form {
            Section {
                Picker(state.copy.languageTitle, selection: $state.settings.language) {
                    ForEach(AppLanguage.allCases) { language in
                        Text("\(language.flag) \(language.name)").tag(language)
                    }
                }
                Picker(state.copy.theme, selection: $state.settings.theme) {
                    Text(state.copy.system).tag(AppTheme.system)
                    Text(state.copy.light).tag(AppTheme.light)
                    Text(state.copy.dark).tag(AppTheme.dark)
                }
                Picker(state.copy.accent, selection: $state.settings.accent) {
                    Text(state.copy.tomato).tag("tomato")
                    Text(state.copy.forest).tag("forest")
                }
            }
        }
        .formStyle(.grouped)
    }

    private var advanced: some View {
        Form {
            Section(state.copy.sleep) {
                Toggle(state.copy.keepAwake, isOn: $state.settings.keepMacAwake)
                    .help("Uses a macOS power assertion only while the timer is running.")
                Toggle(state.copy.pauseOnSleep, isOn: $state.settings.pauseOnSleep)
                Toggle(state.copy.resumeOnWake, isOn: $state.settings.resumeOnWake)
            }
            Section(state.copy.window) {
                Toggle(state.copy.hideWhenRunning, isOn: $state.settings.hideWhenRunning)
                Toggle(state.copy.showWhenFinished, isOn: $state.settings.showWhenFinished)
                Toggle(state.copy.keepFront, isOn: $state.settings.keepWindowFront)
                    .onChange(of: state.settings.keepWindowFront) { _ in state.applyWindowLevel() }
            }
        }
        .formStyle(.grouped)
    }
}

private struct SettingTextField: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let unit: String

    init(_ title: String, value: Binding<Int>, in range: ClosedRange<Int>, unit: String) {
        self.title = title
        _value = value
        self.range = range
        self.unit = unit
    }

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            TextField("", value: limitedValue, format: .number)
                .multilineTextAlignment(.trailing)
                .textFieldStyle(.roundedBorder)
                .frame(width: 52)
            Text(unit)
                .foregroundStyle(.secondary)
                .frame(width: 64, alignment: .leading)
        }
    }

    private var limitedValue: Binding<Int> {
        Binding(
            get: { value },
            set: { value = min(max($0, range.lowerBound), range.upperBound) }
        )
    }
}
