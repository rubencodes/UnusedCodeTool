import Foundation

struct FileBrowser {
    // MARK: - Private Properties

    private let logger: Logger

    // MARK: - Lifecycle

    init(logger: Logger) {
        self.logger = logger
    }

    // MARK: - Public Functions

    /// Gets all file paths within a directory.
    /// - Parameters:
    ///   - directory: The directory to search. Defaults to the current directory.
    ///   - fileExtension: A file extension to filter by, if any.
    ///   - ignoringItems: A list of items to ignore.
    ///   - fileManager: The `FileManager` instance to use.
    /// - Returns: A list of matched file paths.
    func getFilePaths(in directory: String = ".",
                      matchingExtension fileExtension: String? = nil,
                      ignoringItems ignoredItems: [IgnoredItem] = [],
                      using fileManager: FileManager = .default) -> [String]
    {
        guard let enumerator = fileManager.enumerator(atPath: directory) else {
            logger.error("[FileBrowser] Failed to enumerate items in directory \"\(directory)\"")
            exit(1)
        }
        let filePaths = enumerator.allObjects.compactMap { $0 as? String }.map { "\(directory)\(directory.hasSuffix("/") ? "" : "/")\($0)" }
        logger.debug("[FileBrowser] File Path Count - All: \(filePaths.count)")
        let filePathsMatchingExtension = filter(filePaths: filePaths, matchingExtension: fileExtension)
        logger.debug("[FileBrowser] File Path Count - Matching Extension (\(fileExtension ?? "none")): \(filePathsMatchingExtension.count)")
        let filePathsNotIgnored = filter(filePaths: filePathsMatchingExtension, ignoringItems: ignoredItems)
        logger.debug("[FileBrowser] File Path Count - Not Ignored: \(filePathsNotIgnored.count)")

        return filePathsNotIgnored
    }

    /// Reads the contents of the given file path.
    /// - Parameter filePath: The path to the file to read.
    /// - Returns: A string with the contents of that file, if any.
    func readFile(at filePath: String) -> String? {
        guard let content = try? String(contentsOfFile: filePath, encoding: .utf8) else {
            logger.debug("[FileBrowser] Failed to read file at path: \(filePath)")
            return nil
        }

        return content
    }

    // MARK: - Private Functions

    private func filter(filePaths: [String], matchingExtension fileExtension: String?) -> [String] {
        guard let fileExtension else {
            logger.debug("[FileBrowser] No file extension filter specified, returning all file paths.")
            return filePaths
        }

        return filePaths.filter { filePath in
            guard filePath.hasSuffix(".\(fileExtension)") else {
                logger.debug("[FileBrowser] Skipping file at path: \(filePath) due to non-matching file extension.")
                return false
            }

            return true
        }
    }

    private func filter(filePaths: [String], ignoringItems ignoredItems: [IgnoredItem]) -> [String] {
        filePaths.filter { filePath in
            guard let matchedIgnoreRule = ignoredItems.first(where: { $0.matches(filePath: filePath) && !$0.hasDeclarationFilter }) else {
                return true
            }

            logger.debug("[FileBrowser] Skipping file at \(filePath) due to ignore file line:\n\t- \(matchedIgnoreRule.line)")
            matchedIgnoreRule.hasFiltered = true
            return false
        }
    }
}
