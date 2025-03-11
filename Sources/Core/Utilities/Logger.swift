import Foundation

/// Writes logs to stdout.
struct Logger {

    // MARK: - Private Properties

    private let logLevel: LogLevel

    // MARK: - Lifecycle

    init(logLevel: LogLevel) {
        self.logLevel = logLevel
    }

    // MARK: - Public Functions

    func debug(_ message: String) {
        guard logLevel <= .debug else { return }
        print("\(message, color: .cyan)")
    }

    func info(_ message: String) {
        guard logLevel <= .info else { return }
        print(message)
    }

    func warning(_ message: String) {
        guard logLevel <= .warning else { return }
        print("\(message, color: .yellow)")
    }

    func error(_ message: String) {
        guard logLevel <= .error else { return }
        print("\(message, color: .magenta)")
    }
}
