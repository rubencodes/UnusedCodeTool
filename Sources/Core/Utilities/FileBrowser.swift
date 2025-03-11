import Foundation

/// Handles file system interactions, such as reading files and listing paths.
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
    ///   - ignoreFilePath: A file path to a file with a list of regex file paths to ignore.
    ///   - fileManager: The `FileManager` instance to use.
    /// - Returns: A list of matched file paths.
    func getFilePaths(in directory: String = ".",
                      matchingExtension fileExtension: String? = nil,
                      ignoring ignoreFilePath: String? = nil,
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
        let filePathsNotIgnored = filter(filePaths: filePathsMatchingExtension, ignoring: ignoreFilePath)
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

    private func filter(filePaths: [String], ignoring ignoreFilePath: String?) -> [String] {
        guard let ignoreFilePath,
              let ignoreFile = readFile(at: ignoreFilePath)
        else {
            logger.debug("[FileBrowser] No ignore file specified, returning all file paths.")
            return filePaths
        }

        let ignoredFilePaths = ignoreFile.split(separator: "\n")
        let ignoredFilePathRegexes: [Regex<AnyRegexOutput>] = ignoredFilePaths
            .compactMap { ignoredFilePath in
                guard ignoredFilePath.isEmpty == false else { return nil }
                guard !ignoredFilePath.hasPrefix("#") else { return nil }
                guard let regex = try? Regex(String(ignoredFilePath)) else {
                    logger.warning("[FileBrowser] Failed to create ignore file regex from pattern: \"\(ignoredFilePath)\"")
                    return nil
                }

                logger.debug("[FileBrowser] Created ignore file regex from pattern: \"\(ignoredFilePath)\"")
                return regex
            }
        guard ignoredFilePathRegexes.isEmpty == false else {
            logger.debug("[FileBrowser] Empty ignore file, returning all file paths.")
            return filePaths
        }

        return filePaths.filter { filePath in
            ignoredFilePathRegexes.contains {
                guard (try? $0.firstMatch(in: filePath)) != nil else {
                    return false
                }

                logger.debug("[FileBrowser] Skipping file at path: \(filePath) due to match in ignore file.")
                return true
            } == false
        }
    }
}
