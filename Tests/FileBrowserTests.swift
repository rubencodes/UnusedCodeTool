@testable import Core
import Foundation
import Testing

struct LocalFileBrowserTests {
    private let logger = Logger(logLevel: .info)

    /// Returns files matching extension.
    @Test func testFileBrowserReturnsExtensionFilteredFileList() async throws {
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

    /// Returns files ignoring items in ignore list.
    @Test func testFileBrowserReturnsIgnoredItemFilteredFileList() async throws {
        let directory = "./folder"
        let filePaths = [
            "foo.swift",
            "bar.xib",
            "baz.xib"
        ]
        let fileManager = MockFileManager(filePaths: filePaths)
        let fileBrowser = LocalFileBrowser(using: fileManager,
                                           logger: logger)
        let ignoredItems = [
            try! IgnoredItem(line: ".*r.xib"),
        ].compactMap { $0 }
        let foundPaths = try! fileBrowser.getFilePaths(in: directory,
                                                       matchingExtension: "xib",
                                                       ignoringItems: ignoredItems)
        #expect(foundPaths.first == "\(directory)/\(filePaths.last ?? "")")
    }

    /// Throws an error when file manager fails.
    @Test func testFileBrowserThrowsWhenFileManagerFailure() async throws {
        let fileManager = MockFileManager(filePaths: nil)
        let fileBrowser = LocalFileBrowser(using: fileManager,
                                           logger: logger)
        #expect(throws: ApplicationError.fileReadError) {
            try fileBrowser.getFilePaths(matchingExtension: "")
        }
    }
}
