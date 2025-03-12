@testable import Core
import Foundation

struct MockFileReader: FileReader {
    // MARK: - Internal Properties

    let files: [String: String]

    // MARK: - Public Functions

    func readFile(at filePath: String) -> String? {
        files[filePath]
    }
}
