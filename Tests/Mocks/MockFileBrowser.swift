@testable import Core
import Foundation

struct MockFileBrowser: FileBrowser {
    // MARK: - Internal Properties

    var filePaths: [String]?

    // MARK: - Public Functions

    func getFilePaths(in _: String,
                      matchingExtension fileExtension: String,
                      ignoringItems _: [IgnoredItem]) throws -> [String]
    {
        guard let filePaths else {
            throw NSError()
        }
        return filePaths
            .filter { $0.hasSuffix(fileExtension) }
    }
}
