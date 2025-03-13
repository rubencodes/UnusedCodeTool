@testable import Core
import Foundation
import Testing

struct LocalFileBrowserTests {
    private let logger = Logger(logLevel: .info)

    /// Returns all files.
    @Test func testFileBrowserReturnsUnfilteredFileList() async throws {
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

    /// Returns files matching extension.
    @Test func testFileBrowserReturnsExtensionFilteredFileList() async throws {
        let filePaths = [
            "foo.swift",
            "bar.xib",
        ]
        let fileManager = MockFileManager(filePaths: filePaths)
        let fileBrowser = LocalFileBrowser(using: fileManager,
                                           logger: logger)
        let foundPaths = try! fileBrowser.getFilePaths(matchingExtension: "swift")
        #expect(foundPaths.count == 1)
    }

    /// Returns files ignoring items in ignore list.
    @Test func testFileBrowserReturnsIgnoredItemFilteredFileList() async throws {
        let filePaths = [
            "foo.swift",
            "bar.xib",
        ]
        let fileManager = MockFileManager(filePaths: filePaths)
        let fileBrowser = LocalFileBrowser(using: fileManager,
                                           logger: logger)
        let ignoredItems = [
            try! IgnoredItem(line: ".*.xib"),
        ].compactMap { $0 }
        let foundPaths = try! fileBrowser.getFilePaths(ignoringItems: ignoredItems)
        #expect(foundPaths.count == 1)
    }

    /// Throws an error when file manager fails.
    @Test func testFileBrowserThrowsWhenFileManagerFailure() async throws {
        let fileManager = MockFileManager(filePaths: nil)
        let fileBrowser = LocalFileBrowser(using: fileManager,
                                           logger: logger)
        #expect(throws: ApplicationError.fileReadError) {
            try fileBrowser.getFilePaths()
        }
    }
}
