import Foundation

/// Represents an ignored item created from the ignore file.
struct IgnoredItem {
    /// The file path to ignore within.
    let filePath: String

    /// The pattern to match the declaration against.
    let pattern: String

    // Regex created from the pattern.
    var regex: Regex<AnyRegexOutput>

    /// Attempts to create an IgnoredItem from a line of the ignore item file.
    /// Throws for a regex parsing failure.
    init?(line: Substring) throws {
        guard line.isEmpty == false,
              line.hasPrefix("#") == false
        else {
            return nil
        }

        let components = line.split(separator: ": ")
        guard components.count == 2 else { return nil }

        filePath = String(components[0])
        pattern = String(components[1])
        regex = try Regex(pattern)
    }
}

extension IgnoredItem: Equatable {
    static func == (lhs: IgnoredItem, rhs: IgnoredItem) -> Bool {
        lhs.filePath == rhs.filePath && lhs.pattern == rhs.pattern
    }
}
