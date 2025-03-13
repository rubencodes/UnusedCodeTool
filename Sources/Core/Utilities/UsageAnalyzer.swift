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
    ///   - files: All Swift files in the project.
    ///   - xibs: All XIB files in the project.
    /// - Returns: A list of unused code items.
    func findUnused(declarations: [Declaration],
                    in files: [File],
                    xibs: [File]) -> [Declaration]
    {
        var usages = [Declaration: Int]()

        for file in files {
            let words = file.content.sanitized
                .components(separatedBy: CharacterSet.validVariableNameCharacters.inverted)
            let wordCount = Dictionary(words.map { ($0, 1) }, uniquingKeysWith: +)

            for item in declarations where !item.isPrivate || item.file == file.path {
                usages[item] = (usages[item] ?? 0) + (wordCount[item.name] ?? 0)
            }
        }

        for file in xibs {
            let xmlString = file.content.split(separator: "\n").joined(separator: " ")

            // Find class links.
            let classRegex: Regex = .xibClass
            let classUsages = xmlString.matches(of: classRegex)
            for classUsage in classUsages {
                let name = classUsage.output.className

                for item in declarations where item.name == name {
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
