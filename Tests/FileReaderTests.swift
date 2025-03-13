@testable import Core
import Foundation
import Testing

struct LocalFileReaderTests {
    private let logger = Logger(logLevel: .info)

    /// Returns all swift files.
    @Test func testFileReaderReturnsSwiftFileList() async throws {
        let directory = "./folder"
        let filePaths = [
            "foo.swift",
            "bar.xib",
        ]
        let fileManager = MockFileManager(filePaths: filePaths)
        let fileBrowser = LocalFileBrowser(using: fileManager,
                                           logger: logger)
        let foundPaths = try! fileBrowser.getFilePaths(in: directory, matchingExtension: "swift")
        #expect(foundPaths.first == "\(directory)/\(filePaths.first ?? "")")
    }

    /// Returns all xib files.
    @Test func testFileReaderReturnsXibFileList() async throws {
        let directory = "./folder"
        let filePaths = [
            "foo.swift",
            "bar.xib",
        ]
        let fileManager = MockFileManager(filePaths: filePaths)
        let fileBrowser = LocalFileBrowser(using: fileManager,
                                           logger: logger)
        let foundPaths = try! fileBrowser.getFilePaths(in: directory, matchingExtension: "xib")
        #expect(foundPaths.first == "\(directory)/\(filePaths.last ?? "")")
    }
}
