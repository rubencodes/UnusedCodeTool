import Foundation

/// Extracts declarations from Swift files using basic pattern matching.
struct SwiftParser {
    // MARK: - Private Properties

    private let logger: Logger

    // MARK: - Lifecycle

    init(logger: Logger) {
        self.logger = logger
    }

    // MARK: - Public Functions

    /// Extracts code items from a Swift file's content.
    /// - Parameters:
    ///   - content: The content of the file.
    ///   - filePath: The path of the file being analyzed.
    /// - Returns: A list of identified code items.
    func extractDeclarations(from content: String,
                             in filePath: String,
                             ignoringItems ignoredItems: [IgnoredItem]) -> [Declaration]
    {
        // If the entire file is ignored, return nothing.
        if ignoredItems.contains(where: { $0.matches(filePath: filePath) && !$0.hasDeclarationFilter }) {
            logger.debug("[SwiftParser] Skipping file: \(filePath) due to ignore rule.")
            return []
        }

        let cleanedContent = content
            .replacing(Regex<Any>.multilineComment, with: "")
        let lines = cleanedContent.components(separatedBy: "\n")

        return lines.enumerated().compactMap { index, line in
            let cleanedLine = line.replacing(Regex<Any>.singleLineComment, with: "")
            guard !cleanedLine.isEmpty else { return nil }

            guard let match = cleanedLine.firstMatch(of: Regex<Any>.declaration) else { return nil }

            let type = String(match.output.variableType)
            let name = String(match.output.variableName)
            let modifiers = findModifiers(from: line, for: type, in: filePath)

            let declaration = Declaration(file: filePath, line: line, at: index + 1, type: type, name: name, modifiers: modifiers)

            // If the declaration is ignored, return nil.
            if let matchedIgnoreRule = ignoredItems.first(where: { $0.matches(filePath: filePath) && $0.matches(declaration: declaration) }) {
                logger.debug("[SwiftParser] Skipping declaration \"\(name)\" at \(filePath) due to ignore file line:\n\t- \(matchedIgnoreRule.line)")
                matchedIgnoreRule.hasFiltered = true
                return nil
            }

            logger.debug("[SwiftParser] Found \(type) \(name) in \(filePath).")
            return declaration
        }
    }

    // MARK: - Private Functions

    private func findModifiers(from line: String, for type: String, in filePath: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: "(.*?)\\s*\\b" + type + "\\b") else {
            logger.error("[SwiftParser] Error matching modifiers in file path: \(filePath):\n\(line)\nModifier: \(type)")
            return []
        }

        guard let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
              let range = Range(match.range(at: 1), in: line)
        else {
            return []
        }

        return line[range].split(separator: " ").map(String.init)
    }
}
