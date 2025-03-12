@testable import Core
import Foundation
import Testing

struct UnusedCodeToolTests {

    /// Happy path.
    @Test func testNoFilesNoProblem() async throws {
        let tool = UnusedCodeTool()
        let result = tool.run(fileReader: MockFileReader(files: [:]),
                              fileBrowser: MockFileBrowser(filePaths: []))
        #expect(result == 0)
    }
    
    /// Happier path.
    @Test func testNoUnusedCodeNoProblem() async throws {
        let files: [String: String] = [
            "foo.swift": .noUnusedItems
        ]
        let tool = UnusedCodeTool()
        let result = tool.run(fileReader: MockFileReader(files: files),
                              fileBrowser: MockFileBrowser(filePaths: Array(files.keys)))
        #expect(result == 0)
    }

    /// Finds unused code.
    @Test func testUnusedCodeProblem() async throws {
        let files: [String: String] = [
            "foo.swift": .oneUnusedItem,
            ".unusedignore": ""
        ]
        let tool = UnusedCodeTool()
        let result = tool.run(fileReader: MockFileReader(files: files),
                              fileBrowser: MockFileBrowser(filePaths: Array(files.keys)))
        #expect(result == 1)
    }

    /// Finds unused code, ignoring it because of the ignore file.
    @Test func testUnusedCodeNoProblemIfIgnored() async throws {
        let files: [String: String] = [
            "foo.swift": .oneUnusedItem,
            ".unusedignore": .unusedIgnoreFile
        ]
        let tool = UnusedCodeTool()
        let result = tool.run(fileReader: MockFileReader(files: files),
                              fileBrowser: MockFileBrowser(filePaths: Array(files.keys)))
        #expect(result == 0)
    }
}
