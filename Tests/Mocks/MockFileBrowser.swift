@testable import Core
import Foundation

struct MockFileBrowser: FileBrowser {
    // MARK: - Internal Properties

    let filePaths: [String]

    // MARK: - Public Functions

    func getFilePaths(in _: String,
                      matchingExtension fileExtension: String?,
                      ignoringItems _: [IgnoredItem]) -> [String]
    {
        filePaths
            .filter { $0.hasSuffix(fileExtension ?? "") }
    }
}
