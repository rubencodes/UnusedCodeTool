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
    /// - Returns: A list of unused code items.
    func findUnused(declarations: [Declaration],
                    in filePaths: [String],
                    xibs: [String],
                    using fileBrowser: FileBrowser) -> [Declaration]
    {
        var usages = [Declaration: Int]()

        for filePath in filePaths {
            guard let content = fileBrowser.readFile(at: filePath) else {
                logger.warning("[UsageAnalyzer] Failed to read contents of file: \(filePath)")
                continue
            }

            let words = content.sanitized
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
            let classRegex: Regex = .xibClass
            let classUsages = xmlString.matches(of: classRegex)
            for classUsage in classUsages {
                let name = classUsage.output.className

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

        for declaration in declarations.sorted() {
            logger.debug("[UsageAnalyzer] \(declaration.file):\(declaration.at): \(declaration.type) \(declaration.name) used \(usages[declaration] ?? 0) time(s).")
        }

        return declarations.filter { (usages[$0] ?? 0) <= 1 && !$0.isOverride }
    }
}
