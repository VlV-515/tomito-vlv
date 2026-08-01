import SwiftUI

struct TimerView: View {
    @EnvironmentObject private var state: TimerState
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.055, green: 0.071, blue: 0.118), Color(red: 0.10, green: 0.075, blue: 0.12)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                header
                Spacer()
                timer
                controls
                Spacer()
                footer
            }
            .padding(32)
        }
        .foregroundStyle(.white)
        .onAppear { state.applyWindowLevel() }
    }

    private var header: some View {
        HStack {
            AppIconView(size: 24)
            Text("Tomito vlv")
                .font(.headline.weight(.semibold))
            Spacer()
            Text(state.copy.phaseName.uppercased())
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.55))
            Text(state.phaseTitle)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 11)
                .padding(.vertical, 6)
                .background(phaseColor.opacity(0.22), in: Capsule())
                .foregroundStyle(phaseColor)
        }
    }

    private var timer: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.08), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: max(0.008, state.progress))
                    .stroke(phaseColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.25), value: state.progress)
                Text(state.formattedTime)
                    .font(.system(size: 78, weight: .thin, design: .rounded))
                    .monospacedDigit()
                    .accessibilityLabel("\(state.phaseTitle), \(state.formattedTime)")
            }
            .frame(width: 280, height: 280)
            Text(state.isRunning ? state.copy.phaseName : state.copy.start)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.58))
        }
    }

    private var controls: some View {
        HStack(spacing: 12) {
            Button(action: state.toggleRunning) {
                Label(state.isRunning ? state.copy.pause : state.copy.start,
                      systemImage: state.isRunning ? "pause.fill" : "play.fill")
                    .frame(minWidth: 130)
            }
            .buttonStyle(PrimaryTimerButton(color: phaseColor))
            .keyboardShortcut(.return, modifiers: .command)
            .accessibilityLabel(state.isRunning ? state.copy.pause : state.copy.start)

            Menu {
                Button(state.copy.stop, action: state.stop)
                Button(state.copy.restart, action: state.restart)
                Divider()
                Button(state.copy.skip, action: state.skip)
            } label: {
                Image(systemName: "ellipsis")
                    .frame(width: 34, height: 34)
            }
            .menuStyle(.borderlessButton)
            .accessibilityLabel("Timer actions")
        }
    }

    private var footer: some View {
        HStack {
            Label("\(state.copy.sessionCount): \(state.completedSessions)", systemImage: "checkmark.circle")
            Spacer()
            Button {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            } label: {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.plain)
            .accessibilityLabel(state.copy.settings)
            Button {
                openAbout()
            } label: {
                Image(systemName: "info.circle")
            }
            .buttonStyle(.plain)
            .accessibilityLabel(state.copy.aboutTitle)
        }
        .font(.footnote)
        .foregroundStyle(.white.opacity(0.58))
    }

    private var phaseColor: Color {
        switch state.phase {
        case .session: state.settings.accent == "forest" ? Color(red: 0.20, green: 0.80, blue: 0.47) : Color(red: 0.96, green: 0.25, blue: 0.22)
        case .shortBreak, .longBreak: Color(red: 0.20, green: 0.80, blue: 0.47)
        }
    }

    private func openAbout() {
        openWindow(id: "about")
    }
}

struct PrimaryTimerButton: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(color.opacity(configuration.isPressed ? 0.70 : 1), in: Capsule())
            .foregroundStyle(.white)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

struct MenuBarView: View {
    @EnvironmentObject private var state: TimerState
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            Text(state.phaseTitle)
                .font(.headline)
            Text(state.formattedTime)
                .font(.system(.title, design: .rounded).monospacedDigit())
            Divider()
            Button(state.isRunning ? state.copy.pause : state.copy.start, action: state.toggleRunning)
            Button(state.copy.skip, action: state.skip)
            Button(state.copy.restart, action: state.restart)
            Divider()
            Button(state.copy.settings) {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            }
            Button(state.copy.aboutTitle) {
                openWindow(id: "about")
            }
            Divider()
            Button("Quit Tomito vlv") { NSApp.terminate(nil) }
        }
        .padding(14)
        .frame(width: 220)
    }
}
