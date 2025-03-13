import Foundation

// Command line argument parsing tools.
enum ArgumentParser {
    /// Finds an argument with the given name using regex, returning the value if it exists.
    /// - Parameters:
    ///   - name: The name of the argument to match.
    ///   - arguments: The list of received command line arguments.
    /// - Returns: The argument value, if any.
    static func find(_ name: String, from arguments: [String]) -> String? {
        for argument in arguments {
            guard let match = argument.wholeMatch(of: Regex<Any>.argument) else { continue }
            guard match.output.argumentName == name else { continue }
            return "\(match.output.argumentValue ?? "")"
        }

        return nil
    }
}
