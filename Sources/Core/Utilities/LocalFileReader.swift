import Foundation

/// Reads files from disk.
struct LocalFileReader: FileReader {
    // MARK: - Private Properties

    private let logger: Logger

    // MARK: - Lifecycle

    init(logger: Logger) {
        self.logger = logger
    }

    // MARK: - Public Functions

    /// Reads the contents of the given file path.
    /// - Parameter filePath: The path to the file to read.
    /// - Returns: A string with the contents of that file, if any.
    func readFile(at filePath: String) -> String? {
        guard let content = try? String(contentsOfFile: filePath, encoding: .utf8) else {
            logger.debug("[LocalFileReader] Failed to read file at path: \(filePath)")
            return nil
        }

        return content
    }
}
