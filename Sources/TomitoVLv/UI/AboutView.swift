import SwiftUI

struct AboutView: View {
    @EnvironmentObject private var state: TimerState

    var body: some View {
        VStack(spacing: 16) {
            AppIconView(size: 112)
            Text("Tomito vlv")
                .font(.title.bold())
            Text("A calmer Pomodoro timer for macOS.")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("\(state.copy.version) 1.1.0")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Divider().padding(.horizontal, 32)
            Text(state.copy.sourceCode)
                .font(.headline)
            VStack(alignment: .leading, spacing: 10) {
                Link(destination: URL(string: "https://github.com/VlV-515/tomito-vlv")!) {
                    Label("VlV-515/tomito-vlv", systemImage: "chevron.left.forwardslash.chevron.right")
                }
                Link(destination: URL(string: "https://sourceforge.net/projects/tomito-vlv/")!) {
                    Label(state.copy.sourceForge, systemImage: "shippingbox")
                }
            }
            .font(.body.weight(.medium))
            .buttonStyle(.link)
            Spacer()
            Text("Made for focused work. Private by design.")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AppIconView: View {
    let size: CGFloat

    var body: some View {
        Group {
            if let url = Bundle.module.url(forResource: "AppIcon-source", withExtension: "png"),
               let image = NSImage(contentsOf: url) {
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.high)
            } else {
                Image(systemName: "timer")
                    .resizable()
                    .scaledToFit()
                    .padding(size * 0.2)
                    .foregroundStyle(.red)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
        .accessibilityLabel("Tomito vlv icon")
    }
}
