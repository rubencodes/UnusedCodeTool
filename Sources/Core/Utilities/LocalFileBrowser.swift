import Foundation

/// Browses files from disk.
struct LocalFileBrowser: FileBrowser {
    // MARK: - Private Properties

    private let fileManager: FileManaging
    private let logger: Logger

    // MARK: - Lifecycle

    init(using fileManager: FileManaging = FileManager.default,
         logger: Logger)
    {
        self.fileManager = fileManager
        self.logger = logger
    }

    // MARK: - Public Functions

    /// Gets all file paths within a directory.
    /// - Parameters:
    ///   - directory: The directory to search. Defaults to the current directory.
    ///   - fileExtension: A file extension to filter by, if any.
    ///   - ignoringItems: A list of items to ignore.
    /// - Returns: A list of matched file paths.
    func getFilePaths(in directory: String = ".",
                      matchingExtension fileExtension: String? = nil,
                      ignoringItems ignoredItems: [IgnoredItem] = []) throws -> [String]
    {
        guard let rawFilePaths = fileManager.files(atPath: directory) else {
            logger.error("[LocalFileBrowser] Failed to enumerate items in directory \"\(directory)\"")
            throw ApplicationError.fileReadError
        }
        let filePaths = rawFilePaths.map { "\(directory)\(directory.hasSuffix("/") ? "" : "/")\($0)" }
        logger.debug("[LocalFileBrowser] File Path Count - All: \(filePaths.count)")
        let filePathsMatchingExtension = filter(filePaths: filePaths, matchingExtension: fileExtension)
        logger.debug("[LocalFileBrowser] File Path Count - Matching Extension (\(fileExtension ?? "none")): \(filePathsMatchingExtension.count)")
        let filePathsNotIgnored = filter(filePaths: filePathsMatchingExtension, ignoringItems: ignoredItems)
        logger.debug("[LocalFileBrowser] File Path Count - Not Ignored: \(filePathsNotIgnored.count)")

        return filePathsNotIgnored
    }

    // MARK: - Private Functions

    private func filter(filePaths: [String], matchingExtension fileExtension: String?) -> [String] {
        guard let fileExtension else {
            logger.debug("[LocalFileBrowser] No file extension filter specified, returning all file paths.")
            return filePaths
        }

        return filePaths.filter { filePath in
            guard filePath.hasSuffix(".\(fileExtension)") else {
                logger.debug("[LocalFileBrowser] Skipping file at path: \(filePath) due to non-matching file extension.")
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

            logger.debug("[LocalFileBrowser] Skipping file at \(filePath) due to ignore file line:\n\t- \(matchedIgnoreRule.line)")
            matchedIgnoreRule.hasFiltered = true
            return false
        }
    }
}
