import Foundation

/// Represents an ignored item created from the ignore file.
/// Supports ignoring entire files or specific declarations within files.
final class IgnoredItem {
    // MARK: - Public Properties

    /// The original ignore script line.
    var line: String

    /// Whether this item has been used to filter.
    var hasFiltered: Bool = false

    /// Whether this item filters declarations (versus only files).
    var hasDeclarationFilter: Bool {
        declarationRegex != nil
    }

    // MARK: - Private Properties

    /// The regex pattern to match file paths against.
    private let fileRegexPattern: String
    private let fileRegex: Regex<AnyRegexOutput>

    /// The optional regex pattern to match declarations against.
    private let declarationRegexPattern: String?
    private let declarationRegex: Regex<AnyRegexOutput>?

    // MARK: - Lifecycle

    /// Attempts to create an `IgnoredItem` from a line of the ignore file.
    /// Throws for a regex parsing failure.
    init?(line: Substring) throws {
        let cleanedLine = line.replacing(Regex<Any>.singleLineHashComment, with: "").trimmingCharacters(in: .whitespaces)
        guard !cleanedLine.isEmpty else { return nil }

        self.line = cleanedLine
        let components = cleanedLine.split(separator: ": ", maxSplits: 1).map(String.init)
        fileRegexPattern = IgnoredItem.parsePattern(components[0])
        fileRegex = try Regex(fileRegexPattern)
        declarationRegexPattern = components.count > 1 ? IgnoredItem.parsePattern(components[1]) : nil
        declarationRegex = if let declarationRegexPattern {
            try Regex(declarationRegexPattern)
        } else {
            nil
        }
    }

    // MARK: - Public Functions

    /// Checks if a given file path matches this ignored item.
    func matches(filePath: String) -> Bool {
        return (try? fileRegex.firstMatch(in: filePath)) != nil
    }

    /// Checks if a given declaration name matches this ignored item.
    func matches(declaration: Declaration) -> Bool {
        guard let declarationRegex else { return false }
        return (try? declarationRegex.firstMatch(in: declaration.name)) != nil
    }

    // MARK: - Private Static Functions

    /// Parses a pattern, escaping it if it's surrounded by quotes.
    private static func parsePattern(_ rawPattern: String) -> String {
        if rawPattern.hasPrefix("\""), rawPattern.hasSuffix("\"") {
            // Strip quotes and escape it for an exact match
            let stripped = String(rawPattern.dropFirst().dropLast())
            return NSRegularExpression.escapedPattern(for: stripped)
        }
        // Otherwise, it's a regex as-is
        return rawPattern
    }
}

extension IgnoredItem: Equatable {
    static func == (lhs: IgnoredItem, rhs: IgnoredItem) -> Bool {
        lhs.fileRegexPattern == rhs.fileRegexPattern &&
            lhs.declarationRegexPattern == rhs.declarationRegexPattern
    }
}

extension [IgnoredItem] {
    init(from ignoreFile: String, logger: Logger) {
        self = ignoreFile
            .split(separator: "\n")
            .compactMap {
                do {
                    return try IgnoredItem(line: $0)
                } catch {
                    logger.warning("[IgnoredItems] Failed to create regexes for ignore file line: \"\($0)\"")
                    return nil
                }
            }
    }
}
