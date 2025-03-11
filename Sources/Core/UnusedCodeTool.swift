import Foundation

public final class UnusedCodeTool {
    // MARK: - Nested Types

    private enum Arguments: String {
        case directory
        case ignoreFilePath = "ignore-file-path"
        case ignoreItemPath = "ignore-item-path"
        case logLevel = "level"

        var description: String {
            switch self {
            case .directory:
                return "The directory to search for unused code."
            case .ignoreFilePath:
                return "The path to a file containing a line-delimited list of file or directory regex paths to ignore."
            case .ignoreItemPath:
                return "The path to a file containing a line-delimited list of items to ignore, in the format FILE_PATH=DECLARATION_NAME_REGEX"
            case .logLevel:
                return "The log verbosity level (debug, info, warning, error)."
            }
        }

        var defaultValue: String {
            switch self {
            case .directory:
                return "."
            case .ignoreFilePath:
                return ".unusedfileignore"
            case .ignoreItemPath:
                return ".unuseditemignore"
            case .logLevel:
                return "\(LogLevel.info.rawValue)"
            }
        }
    }

    // MARK: - Private Properties

    private let directory: String
    private let ignoreFilePath: String
    private let ignoreItemPath: String
    private let logLevel: LogLevel

    private lazy var logger = Logger(logLevel: logLevel)
    private lazy var fileBrowser = FileBrowser(logger: logger)
    private lazy var parser = SwiftParser(logger: logger)
    private lazy var analyzer = UsageAnalyzer(logger: logger)
    private lazy var reporter = Reporter(logger: logger)

    // MARK: - Lifecycle

    public init(arguments: [String] = CommandLine.arguments) {
        directory = ArgumentParser.find(Arguments.directory.rawValue, from: arguments) ?? Arguments.directory.defaultValue
        ignoreFilePath = ArgumentParser.find(Arguments.ignoreFilePath.rawValue, from: arguments) ?? Arguments.ignoreFilePath.defaultValue
        ignoreItemPath = ArgumentParser.find(Arguments.ignoreItemPath.rawValue, from: arguments) ?? Arguments.ignoreItemPath.defaultValue
        logLevel = LogLevel(rawValue: ArgumentParser.find(Arguments.logLevel.rawValue, from: arguments) ?? Arguments.logLevel.defaultValue) ?? .info
    }

    // MARK: - Public Functions

    public func run() {
        // Find all Swift files.
        let swiftFilePaths = fileBrowser.getFilePaths(in: directory, matchingExtension: "swift", ignoring: ignoreFilePath)
        guard swiftFilePaths.isEmpty == false else { return }

        // Search for declarations within the Swift files.
        let allDeclarations = swiftFilePaths.compactMap { filePath -> [Declaration] in
            guard let contents = fileBrowser.readFile(at: filePath) else { return [] }
            return parser.extractDeclarations(from: contents, in: filePath)
        }.flatMap { $0 }

        // Find unused declarations.
        let xibFilePaths = fileBrowser.getFilePaths(in: directory, matchingExtension: "xib", ignoring: ignoreFilePath)
        let nibFilePaths = fileBrowser.getFilePaths(in: directory, matchingExtension: "nib", ignoring: ignoreFilePath)
        let unusedDeclarations = analyzer.findUnused(declarations: allDeclarations,
                                                     in: swiftFilePaths,
                                                     xibs: xibFilePaths + nibFilePaths,
                                                     using: fileBrowser,
                                                     ignoring: ignoreItemPath)

        // Output usage report.
        reporter.print(for: unusedDeclarations)
    }
}
