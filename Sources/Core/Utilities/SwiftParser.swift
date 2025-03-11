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
    func extractDeclarations(from content: String, in filePath: String) -> [Declaration] {
        let multilineCommentRegex: Regex = .multilineComment
        let cleanedContent = content.replacing(multilineCommentRegex, with: "")
        let lines = cleanedContent.components(separatedBy: "\n")

        return lines.enumerated().compactMap { index, line in
            let commentRegex: Regex = .singleLineComment
            let cleanedLine = line.replacing(commentRegex, with: "")
            guard !cleanedLine.isEmpty else { return nil }

            let declarationRegex: Regex = .declaration
            guard let match = cleanedLine.firstMatch(of: declarationRegex) else { return nil }

            let type = String(match.output.variableType)
            let name = String(match.output.variableName)
            let modifiers = findModifiers(from: line, for: type, in: filePath)
            logger.debug("[SwiftParser] Found \(type) \(name) in file path: \(filePath):\n\(line)\n")
            return Declaration(file: filePath, line: line, at: index + 1, type: type, name: name, modifiers: modifiers)
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
