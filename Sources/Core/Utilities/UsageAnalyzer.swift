import Foundation

/// Finds unused code by running a text-based search for references across files.
struct UsageAnalyzer {

    // MARK: - Private Properties

    private let logger: Logger

    // MARK: - Lifecycle

    init(logger: Logger) {
        self.logger = logger
    }

    // MARK: - Public Functions

    /// Finds unused code items.
    /// - Parameters:
    ///   - items: A list of parsed code items.
    ///   - filePaths: Paths of all Swift files in the project.
    ///   - xibs: Paths of all XIB files in the project.
    ///   - fileBrowser: The file browser used to read file contents.
    ///   - ignoreItems: A file path to a file with a list of regex items to ignore.
    /// - Returns: A list of unused code items.
    func findUnused(declarations: [Declaration],
                    in filePaths: [String],
                    xibs: [String],
                    using fileBrowser: FileBrowser,
                    ignoring ignoreItemPath: String? = nil) -> [Declaration] {
        var usages = [Declaration: Int]()

        for filePath in filePaths {
            guard let content = fileBrowser.readFile(at: filePath) else {
                logger.warning("[UsageAnalyzer] Failed to read contents of file: \(filePath)")
                continue
            }

            let words = content
                .replacing(Regex<Any>.singleLineComment, with: "")
                .replacing(Regex<Any>.multilineComment, with: "")
                .components(separatedBy: CharacterSet.validVariableNameCharacters.inverted)
            let wordCount = Dictionary(words.map { ($0, 1) }, uniquingKeysWith: +)

            for item in declarations where !item.isPrivate || item.file == filePath {
                usages[item] = (usages[item] ?? 0) + (wordCount[item.name] ?? 0)
            }
        }

        for filePath in xibs {
            guard let content = fileBrowser.readFile(at: filePath) else {
                logger.warning("[UsageAnalyzer] Failed to read contents of file: \(filePath)")
                continue
            }

            let xmlString = content.split(separator: "\n").joined(separator: " ")

            // Find class links.
            let classRegex: Regex = .xibProperty
            let classUsages = xmlString.matches(of: classRegex)
            for classUsage in classUsages {
                let name = classUsage.output.propertyName

                for item in declarations where item.name == name && !item.isPrivate {
                    usages[item] = (usages[item] ?? 0) + 1
                }
            }

            // Find @IBAction links.
            let actionRegex: Regex = .xibSelector
            let actionUsages = xmlString.matches(of: actionRegex)
            for actionUsage in actionUsages {
                let name = actionUsage.output.selectorName

                for item in declarations where item.name == name && (!item.isPrivate || item.isIBLinked) {
                    usages[item] = (usages[item] ?? 0) + 1
                }
            }

            // Find @IBOutlet links.
            let propertyRegex: Regex = .xibProperty
            let propertyUsages = xmlString.matches(of: propertyRegex)
            for propertyUsage in propertyUsages {
                let name = propertyUsage.output.propertyName

                for item in declarations where item.name == name && (!item.isPrivate || item.isIBLinked) {
                    usages[item] = (usages[item] ?? 0) + 1
                }
            }
        }

        declarations.sorted().forEach {
            logger.debug("[UsageAnalyzer] \($0.file):\($0.at): \($0.type) \($0.name) used \(usages[$0] ?? 0) time(s).")
        }

        return filter(declarations: declarations, ignoring: ignoreItemPath, using: fileBrowser)
            .filter { (usages[$0] ?? 0) <= 1 && !$0.isOverride }
    }

    // MARK: - Private Functions

    private func filter(declarations: [Declaration],
                        ignoring ignoreItemPath: String?,
                        using fileBrowser: FileBrowser) -> [Declaration] {
        guard let ignoreItemPath,
              let ignoreItem = fileBrowser.readFile(at: ignoreItemPath) else {
            logger.debug("[UsageAnalyzer] No ignore file specified, returning all unused items.")
            return declarations
        }

        let ignoredItemPaths = ignoreItem.split(separator: "\n")
        let ignoredItemPathRegexes: [(String, Regex<AnyRegexOutput>)] = ignoredItemPaths
            .compactMap { ignoredItemPath in
                guard ignoredItemPath.isEmpty == false else { return nil }
                guard !ignoredItemPath.hasPrefix("#") else { return nil }

                let components = ignoredItemPath.split(separator: ": ")
                guard components.count == 2 else { return nil }

                let filePath = String(components[0])
                let regexPattern = String(components[1])
                guard let regex = try? Regex(regexPattern) else {
                    logger.warning("[UsageAnalyzer] Failed to create ignore item regex from pattern: \"\(regexPattern)\"")
                    return nil
                }

                logger.debug("[UsageAnalyzer] Created ignore item regex from pattern: \"\(regexPattern)\" in file path \"\(filePath)\"")
                return (filePath, regex)
            }
        guard ignoredItemPathRegexes.isEmpty == false else {
            logger.debug("[UsageAnalyzer] Empty ignore file, returning all unused items.")
            return declarations
        }

        return declarations.filter { declaration in
            return ignoredItemPathRegexes.contains { (filePath, regex) in
                guard declaration.file == filePath else {
                    return false
                }

                guard (try? regex.firstMatch(in: declaration.name)) != nil else {
                    return false
                }

                logger.debug("[UsageAnalyzer] Skipping decaration \"\(declaration.name)\" at path: \(filePath) due to match in ignore file.")
                return true
            } == false
        }
    }
}
