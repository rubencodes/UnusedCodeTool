import Foundation

extension String {
    /// Sanitizes a string for easier parsing, removing:
    /// - regex literals
    /// - multi-line comments
    /// - escaped quotes
    var sanitized: String {
        replacing(Regex<Any>.regexLiterals, with: "")
            .replacing(Regex<Any>.escapedQuotes, with: "")
            .replacing(Regex<Any>.stringLiteral) { match in
                let original = match.output.stringLiteral // Extract content inside quotes
                let interpolations = original.matches(of: Regex<Any>.stringInterpolation)
                guard interpolations.isEmpty == false else { return "\"\"" }
                let interpolatedValues = interpolations.map { $0.output.interpolated }
                return interpolatedValues.joined(separator: " ")
            }
            .replacing(Regex<Any>.multilineComment, with: "")
            .replacing(Regex<Any>.singleLineComment, with: "")
    }
}
