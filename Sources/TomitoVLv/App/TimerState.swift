import AppKit
import Combine
import Foundation
import IOKit.pwr_mgt
import SwiftUI
import UserNotifications

enum TimerPhase: String, CaseIterable, Identifiable {
    case session
    case shortBreak
    case longBreak

    var id: String { rawValue }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case english
    case spanish

    var id: String { rawValue }
    var flag: String { self == .english ? "🇺🇸" : "🇲🇽" }
    var name: String { self == .english ? "English" : "Español" }
}

enum AppTheme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

@MainActor
final class TimerSettings: ObservableObject {
    @Published var sessionMinutes: Int { didSet { save() } }
    @Published var shortBreakMinutes: Int { didSet { save() } }
    @Published var longBreakMinutes: Int { didSet { save() } }
    @Published var longBreakEvery: Int { didSet { save() } }
    @Published var autoStartSession: Bool { didSet { save() } }
    @Published var autoStartBreak: Bool { didSet { save() } }
    @Published var breaksEnabled: Bool { didSet { save() } }
    @Published var keepMacAwake: Bool { didSet { save() } }
    @Published var pauseOnSleep: Bool { didSet { save() } }
    @Published var resumeOnWake: Bool { didSet { save() } }
    @Published var hideWhenRunning: Bool { didSet { save() } }
    @Published var showWhenFinished: Bool { didSet { save() } }
    @Published var keepWindowFront: Bool { didSet { save() } }
    @Published var language: AppLanguage { didSet { save() } }
    @Published var theme: AppTheme { didSet { save() } }
    @Published var accent: String { didSet { save() } }

    private let defaults = UserDefaults.standard
    private var loading = true

    init() {
        sessionMinutes = max(1, defaults.object(forKey: "sessionMinutes") as? Int ?? 25)
        shortBreakMinutes = max(1, defaults.object(forKey: "shortBreakMinutes") as? Int ?? 5)
        longBreakMinutes = max(1, defaults.object(forKey: "longBreakMinutes") as? Int ?? 15)
        longBreakEvery = max(2, defaults.object(forKey: "longBreakEvery") as? Int ?? 4)
        autoStartSession = defaults.object(forKey: "autoStartSession") as? Bool ?? false
        autoStartBreak = defaults.object(forKey: "autoStartBreak") as? Bool ?? false
        breaksEnabled = defaults.object(forKey: "breaksEnabled") as? Bool ?? true
        keepMacAwake = defaults.object(forKey: "keepMacAwake") as? Bool ?? true
        pauseOnSleep = defaults.object(forKey: "pauseOnSleep") as? Bool ?? true
        resumeOnWake = defaults.object(forKey: "resumeOnWake") as? Bool ?? false
        hideWhenRunning = defaults.object(forKey: "hideWhenRunning") as? Bool ?? false
        showWhenFinished = defaults.object(forKey: "showWhenFinished") as? Bool ?? true
        keepWindowFront = defaults.object(forKey: "keepWindowFront") as? Bool ?? false
        language = AppLanguage(rawValue: defaults.string(forKey: "language") ?? "english") ?? .english
        theme = AppTheme(rawValue: defaults.string(forKey: "theme") ?? "system") ?? .system
        accent = defaults.string(forKey: "accent") ?? "tomato"
        loading = false
    }

    var colorScheme: ColorScheme? { theme.colorScheme }

    private func save() {
        guard !loading else { return }
        defaults.set(sessionMinutes, forKey: "sessionMinutes")
        defaults.set(shortBreakMinutes, forKey: "shortBreakMinutes")
        defaults.set(longBreakMinutes, forKey: "longBreakMinutes")
        defaults.set(longBreakEvery, forKey: "longBreakEvery")
        defaults.set(autoStartSession, forKey: "autoStartSession")
        defaults.set(autoStartBreak, forKey: "autoStartBreak")
        defaults.set(breaksEnabled, forKey: "breaksEnabled")
        defaults.set(keepMacAwake, forKey: "keepMacAwake")
        defaults.set(pauseOnSleep, forKey: "pauseOnSleep")
        defaults.set(resumeOnWake, forKey: "resumeOnWake")
        defaults.set(hideWhenRunning, forKey: "hideWhenRunning")
        defaults.set(showWhenFinished, forKey: "showWhenFinished")
        defaults.set(keepWindowFront, forKey: "keepWindowFront")
        defaults.set(language.rawValue, forKey: "language")
        defaults.set(theme.rawValue, forKey: "theme")
        defaults.set(accent, forKey: "accent")
    }
}

@MainActor
final class TimerState: ObservableObject {
    @Published private(set) var phase: TimerPhase = .session
    @Published private(set) var remainingSeconds: Int
    @Published private(set) var isRunning = false
    @Published private(set) var completedSessions = 0
    @Published var settings: TimerSettings

    private var ticker: Timer?
    private var sleepAssertion: IOPMAssertionID = 0
    private var resumeAfterWake = false
    private var observers: [NSObjectProtocol] = []

    init() {
        let loadedSettings = TimerSettings()
        settings = loadedSettings
        remainingSeconds = loadedSettings.sessionMinutes * 60
        requestNotifications()
        observeSleep()
    }

    deinit {
        ticker?.invalidate()
        if sleepAssertion != 0 { IOPMAssertionRelease(sleepAssertion) }
        observers.forEach(NotificationCenter.default.removeObserver)
    }

    var copy: AppCopy { AppCopy(language: settings.language) }
    var formattedTime: String {
        String(format: "%02d:%02d", remainingSeconds / 60, remainingSeconds % 60)
    }
    var phaseTitle: String { copy.phase(phase) }
    var progress: Double {
        let total = max(1, duration(for: phase))
        return 1 - Double(remainingSeconds) / Double(total)
    }

    func toggleRunning() { isRunning ? pause() : start() }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        ticker?.invalidate()
        ticker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
        RunLoop.main.add(ticker!, forMode: .common)
        updateSleepAssertion()
        if settings.hideWhenRunning { NSApp.keyWindow?.orderOut(nil) }
    }

    func pause() {
        isRunning = false
        ticker?.invalidate()
        ticker = nil
        updateSleepAssertion()
    }

    func stop() {
        pause()
        remainingSeconds = duration(for: phase)
    }

    func restart() {
        remainingSeconds = duration(for: phase)
    }

    func skip() {
        pause()
        advancePhase()
    }

    func applySettings() {
        guard !isRunning else { return }
        remainingSeconds = duration(for: phase)
        applyWindowLevel()
    }

    func applyWindowLevel() {
        NSApp.windows.forEach { $0.level = settings.keepWindowFront ? .floating : .normal }
    }

    private func tick() {
        guard remainingSeconds > 0 else {
            finishPhase()
            return
        }
        remainingSeconds -= 1
        if remainingSeconds == 0 { finishPhase() }
    }

    private func finishPhase() {
        let finished = phase
        pause()
        if finished == .session { completedSessions += 1 }
        notifyFinished(finished)
        advancePhase()
    }

    private func advancePhase() {
        switch phase {
        case .session:
            if settings.breaksEnabled {
                phase = completedSessions.isMultiple(of: settings.longBreakEvery) ? .longBreak : .shortBreak
            } else {
                phase = .session
            }
        case .shortBreak, .longBreak:
            phase = .session
        }
        remainingSeconds = duration(for: phase)
        let shouldStart = phase == .session ? settings.autoStartSession : settings.autoStartBreak
        if shouldStart { start() }
    }

    private func duration(for phase: TimerPhase) -> Int {
        switch phase {
        case .session: settings.sessionMinutes * 60
        case .shortBreak: settings.shortBreakMinutes * 60
        case .longBreak: settings.longBreakMinutes * 60
        }
    }

    private func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    private func notifyFinished(_ phase: TimerPhase) {
        let content = UNMutableNotificationContent()
        content.title = copy.phaseComplete(phase)
        content.body = copy.nextPhase(phase)
        content.sound = .default
        UNUserNotificationCenter.current().add(UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        ))
        if settings.showWhenFinished {
            NSApp.activate(ignoringOtherApps: true)
            NSApp.windows.first?.makeKeyAndOrderFront(nil)
        }
    }

    private func updateSleepAssertion() {
        if isRunning && settings.keepMacAwake && sleepAssertion == 0 {
            let result = IOPMAssertionCreateWithName(
                kIOPMAssertionTypeNoDisplaySleep as CFString,
                IOPMAssertionLevel(kIOPMAssertionLevelOn),
                "Tomito vlv timer is active" as CFString,
                &sleepAssertion
            )
            if result != kIOReturnSuccess { sleepAssertion = 0 }
        } else if (!isRunning || !settings.keepMacAwake) && sleepAssertion != 0 {
            IOPMAssertionRelease(sleepAssertion)
            sleepAssertion = 0
        }
    }

    private func observeSleep() {
        let center = NSWorkspace.shared.notificationCenter
        observers.append(center.addObserver(forName: NSWorkspace.willSleepNotification, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.resumeAfterWake = self.isRunning
                if self.settings.pauseOnSleep { self.pause() }
            }
        })
        observers.append(center.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                if self.resumeAfterWake && self.settings.resumeOnWake { self.start() }
                self.resumeAfterWake = false
            }
        })
    }
}

struct AppCopy {
    let language: AppLanguage
    private var spanish: Bool { language == .spanish }
    var appName: String { "Tomito vlv" }
    var start: String { spanish ? "Iniciar" : "Start" }
    var pause: String { spanish ? "Pausar" : "Pause" }
    var resume: String { spanish ? "Reanudar" : "Resume" }
    var stop: String { spanish ? "Detener" : "Stop" }
    var skip: String { spanish ? "Saltar" : "Skip" }
    var restart: String { spanish ? "Reiniciar" : "Restart" }
    var startPauseResume: String { spanish ? "Iniciar/Pausar/Reanudar" : "Start/Pause/Resume" }
    var settings: String { spanish ? "Preferencias" : "Preferences" }
    var aboutTitle: String { spanish ? "Acerca de Tomito vlv" : "About Tomito vlv" }
    var sessionCount: String { spanish ? "Sesiones completadas" : "Completed sessions" }
    var general: String { spanish ? "General" : "General" }
    var appearance: String { spanish ? "Apariencia" : "Appearance" }
    var advanced: String { spanish ? "Avanzado" : "Advanced" }
    var sessionDuration: String { spanish ? "Duración de sesión" : "Session duration" }
    var shortBreak: String { spanish ? "Pausa corta" : "Short break" }
    var longBreak: String { spanish ? "Pausa larga" : "Long break" }
    var longBreakEvery: String { spanish ? "Pausa larga cada" : "Long break every" }
    var sessions: String { spanish ? "sesiones" : "sessions" }
    var minutes: String { spanish ? "minutos" : "minutes" }
    var autoSession: String { spanish ? "Iniciar sesión automáticamente" : "Start sessions automatically" }
    var autoBreak: String { spanish ? "Iniciar pausas automáticamente" : "Start breaks automatically" }
    var breaks: String { spanish ? "Activar pausas" : "Enable breaks" }
    var languageTitle: String { spanish ? "Idioma" : "Language" }
    var theme: String { spanish ? "Tema" : "Theme" }
    var accent: String { spanish ? "Acento" : "Accent" }
    var window: String { spanish ? "Ventana" : "Window" }
    var hideWhenRunning: String { spanish ? "Ocultar al iniciar temporizador" : "Hide when timer starts" }
    var showWhenFinished: String { spanish ? "Mostrar al terminar fase" : "Show when phase ends" }
    var keepFront: String { spanish ? "Mantener ventana al frente" : "Keep window in front" }
    var sleep: String { spanish ? "Sueño del Mac" : "Mac sleep" }
    var keepAwake: String { spanish ? "Evitar que el Mac se duerma mientras el temporizador está activo" : "Keep Mac awake while timer is active" }
    var pauseOnSleep: String { spanish ? "Pausar cuando el Mac se duerme" : "Pause when Mac sleeps" }
    var resumeOnWake: String { spanish ? "Reanudar cuando el Mac despierta" : "Resume when Mac wakes" }
    var sourceCode: String { spanish ? "Código abierto" : "Open source" }
    var version: String { spanish ? "Versión" : "Version" }
    var github: String { "GitHub" }
    var sourceForge: String { "SourceForge" }
    var tomato: String { spanish ? "Tomate" : "Tomato" }
    var forest: String { spanish ? "Bosque" : "Forest" }
    var phaseName: String { spanish ? "Fase actual" : "Current phase" }
    var system: String { spanish ? "Automático" : "System" }
    var light: String { spanish ? "Claro" : "Light" }
    var dark: String { spanish ? "Oscuro" : "Dark" }

    func phase(_ phase: TimerPhase) -> String {
        switch phase {
        case .session: spanish ? "Sesión" : "Session"
        case .shortBreak: spanish ? "Pausa corta" : "Short break"
        case .longBreak: spanish ? "Pausa larga" : "Long break"
        }
    }

    func phaseComplete(_ completedPhase: TimerPhase) -> String {
        spanish ? "\(phase(completedPhase)) terminada" : "\(phase(completedPhase)) complete"
    }

    func nextPhase(_ phase: TimerPhase) -> String {
        switch phase {
        case .session: spanish ? "Es momento de tomar una pausa." : "Time for a break."
        case .shortBreak, .longBreak: spanish ? "Listo para una nueva sesión." : "Ready for a new session."
        }
    }
}
