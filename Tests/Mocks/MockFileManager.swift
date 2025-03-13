@testable import Core
import Foundation

struct MockFileManager: FileManaging {
    // MARK: - Internal Properties

    let filePaths: [String]?

    // MARK: - Public Functions

    func files(atPath _: String) -> [String]? {
        filePaths
    }
}
