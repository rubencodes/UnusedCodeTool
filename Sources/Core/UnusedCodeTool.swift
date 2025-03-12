import Foundation

public final class UnusedCodeTool {
    // MARK: - Nested Types

    private enum Arguments: String {
        case directory
        case ignoreFilePath = "ignore-file-path"
        case logLevel = "level"

        var description: String {
            switch self {
            case .directory:
                return "The directory to search for unused code."
            case .ignoreFilePath:
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
                return ".unusedignore"
            case .logLevel:
                return "\(LogLevel.default.rawValue)"
            }
        }
    }

    // MARK: - Private Properties

    private let directory: String
    private let ignoreFilePath: String
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
        logLevel = LogLevel(rawValue: ArgumentParser.find(Arguments.logLevel.rawValue, from: arguments) ?? Arguments.logLevel.defaultValue) ?? .default
    }

    // MARK: - Public Functions

    public func run() {
        // Create ignored items list.
        let ignoredItems = [IgnoredItem](from: ignoreFilePath, using: fileBrowser, logger: logger)

        // Find all Swift files.
        let swiftFilePaths = fileBrowser.getFilePaths(in: directory, matchingExtension: "swift", ignoringItems: ignoredItems)
        let xibFilePaths = fileBrowser.getFilePaths(in: directory, matchingExtension: "xib", ignoringItems: ignoredItems)
        let nibFilePaths = fileBrowser.getFilePaths(in: directory, matchingExtension: "nib", ignoringItems: ignoredItems)
        guard swiftFilePaths.isEmpty == false else {
            logger.debug("[System] No Swift files found.")
            return
        }

        // Search for declarations within the Swift files.
        let allDeclarations = swiftFilePaths.compactMap { filePath -> [Declaration] in
            guard let contents = fileBrowser.readFile(at: filePath) else { return [] }
            return parser.extractDeclarations(from: contents, in: filePath, ignoringItems: ignoredItems)
        }.flatMap { $0 }

        // Warn if any ignore items are unused:
        let unusedIgnoreItems = ignoredItems.filter { $0.hasFiltered == false }
        if unusedIgnoreItems.isEmpty == false {
            logger.warning("[System] The following ignored items were not found in the code:")
            for unusedIgnoreItem in unusedIgnoreItems {
                logger.warning("\t- \(unusedIgnoreItem.line)")
            }
            logger.warning("[System] Please practice proper hygiene in your ignore file and remove them posthaste!")
        }

        // Find unused declarations.
        let unusedDeclarations = analyzer.findUnused(declarations: allDeclarations,
                                                     in: swiftFilePaths,
                                                     xibs: xibFilePaths + nibFilePaths,
                                                     using: fileBrowser)

        // Output usage report.
        reporter.print(for: unusedDeclarations)
    }
}
