import Foundation

/// Log level to use for execution.
enum LogLevel: String, Equatable {
    case debug
    case info
    case warning
    case error
    case off

    private var intValue: Int {
        switch self {
        case .debug: return 0
        case .info: return 1
        case .warning: return 2
        case .error: return 3
        case .off: return 4
        }
    }

    static var `default`: LogLevel { .info }

    static func <= (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.intValue <= rhs.intValue
    }
}
