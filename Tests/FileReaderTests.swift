@testable import Core
import Foundation
import Testing

struct LocalFileReaderTests {
    private let logger = Logger(logLevel: .info)

    /// Returns all files.
    @Test func testFileReaderReturnsUnfilteredFileList() async throws {
        let filePaths = [
            "foo.swift",
            "bar.xib",
        ]
        let fileManager = MockFileManager(filePaths: filePaths)
        let fileBrowser = LocalFileBrowser(using: fileManager,
                                           logger: logger)
        let foundPaths = try! fileBrowser.getFilePaths()
        #expect(foundPaths.count == 2)
    }
}
