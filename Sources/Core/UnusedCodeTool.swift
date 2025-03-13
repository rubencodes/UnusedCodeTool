import Foundation

public final class UnusedCodeTool {
    // MARK: - Nested Types

    private enum Arguments: String, CaseIterable {
        case directory
        case ignoreFilePath = "ignore-file-path"
        case logLevel = "level"
        case help

        var description: String {
            switch self {
            case .directory:
                return "The directory to search for unused code."
            case .ignoreFilePath:
                return "The path to a file containing a line-delimited list of items to ignore, in the format FILE_PATH=DECLARATION_NAME_REGEX"
            case .logLevel:
                return "The log verbosity level (debug, info, warning, error)."
            case .help:
                return "Show this help message."
            }
        }

        var defaultValue: String {
            switch self {
            case .directory:
                return "."
            case .ignoreFilePath:
                return ".unusedignore"
            case .logLevel:
                return LogLevel.default.rawValue
            case .help:
                return ""
            }
        }
    }

    // MARK: - Private Properties

    private let directory: String
    private let ignoreFilePath: String
    private let logLevel: LogLevel
    private let isHelpRequested: Bool

    private lazy var logger = Logger(logLevel: logLevel)
    private lazy var fileReader = LocalFileReader(logger: logger)
    private lazy var fileBrowser = LocalFileBrowser(logger: logger)
    private lazy var parser = SwiftParser(logger: logger)
    private lazy var analyzer = UsageAnalyzer(logger: logger)
    private lazy var reporter = Reporter(logger: logger)

    // MARK: - Lifecycle

    public init(arguments: [String] = CommandLine.arguments) {
        directory = ArgumentParser.find(Arguments.directory.rawValue, from: arguments) ?? Arguments.directory.defaultValue
        ignoreFilePath = ArgumentParser.find(Arguments.ignoreFilePath.rawValue, from: arguments) ?? Arguments.ignoreFilePath.defaultValue
        logLevel = if let rawValue = ArgumentParser.find(Arguments.logLevel.rawValue, from: arguments),
                      let logLevel = LogLevel(rawValue: rawValue) {
            logLevel
        } else {
            .default
        }
        isHelpRequested = ArgumentParser.find(Arguments.help.rawValue, from: arguments) != nil
    }

    // MARK: - Public Functions

    public func run() {
        let result = run(fileReader: fileReader,
                         fileBrowser: fileBrowser)
        exit(Int32(result))
    }

    // MARK: - Internal Functions

    func run(fileReader: FileReader,
             fileBrowser: FileBrowser) -> Int
    {
        guard isHelpRequested == false else {
            logger.info("""
            unused-code-tool
            
            Options:
            
            \(Arguments.allCases.map {
                "\t--\($0.rawValue) - \($0.description)\n"
            }.joined(separator: "\n"))
            """)

            return 0
        }

        // Create ignored items list.
        let ignoreFile = fileReader.readFile(at: ignoreFilePath) ?? ""
        let ignoredItems = [IgnoredItem](from: ignoreFile, logger: logger)

        // Find all Swift files.
        guard let swiftFilePaths = try? fileBrowser.getFilePaths(in: directory, matchingExtension: "swift", ignoringItems: ignoredItems),
              let xibFilePaths = try? fileBrowser.getFilePaths(in: directory, matchingExtension: "xib", ignoringItems: ignoredItems),
              let nibFilePaths = try? fileBrowser.getFilePaths(in: directory, matchingExtension: "nib", ignoringItems: ignoredItems)
        else {
            return 1
        }

        guard swiftFilePaths.isEmpty == false else {
            logger.debug("[System] No Swift files found.")
            return 0
        }

        let swiftFiles: [File] = swiftFilePaths.compactMap {
            guard let content = fileReader.readFile(at: $0) else { return nil }
            return File(path: $0, content: content)
        }

        let xibFiles: [File] = xibFilePaths.compactMap {
            guard let content = fileReader.readFile(at: $0) else { return nil }
            return File(path: $0, content: content)
        }

        let nibFiles: [File] = nibFilePaths.compactMap {
            guard let content = fileReader.readFile(at: $0) else { return nil }
            return File(path: $0, content: content)
        }

        // Search for declarations within the Swift files.
        let allDeclarations = parser.extractDeclarations(in: swiftFiles,
                                                         ignoringItems: ignoredItems)

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
                                                     in: swiftFiles,
                                                     xibs: xibFiles + nibFiles)

        // Output usage report.
        return reporter.print(for: unusedDeclarations)
    }
}
