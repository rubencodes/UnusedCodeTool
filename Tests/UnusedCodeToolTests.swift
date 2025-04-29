@testable import Core
import Foundation
import Testing

struct UnusedCodeToolTests {
    /// Happy path.
    @Test func testNoFilesNoProblem() async throws {
        let tool = UnusedCodeTool(arguments: ["level=info"])
        let result = tool.run(fileReader: MockFileReader(files: [:]),
                              fileBrowser: MockFileBrowser(filePaths: []))
        #expect(result == 0)
    }

    /// Happy path.
    @Test func testHelps() async throws {
        let tool = UnusedCodeTool(arguments: ["--help"])
        let result = tool.run(fileReader: MockFileReader(files: [:]),
                              fileBrowser: MockFileBrowser(filePaths: []))
        #expect(result == 0)
    }

    /// Happier path.
    @Test func testNoUnusedCodeNoProblem() async throws {
        let files: [String: String] = [
            "foo.swift": .noUnusedItems,
        ]
        let tool = UnusedCodeTool()
        let result = tool.run(fileReader: MockFileReader(files: files),
                              fileBrowser: MockFileBrowser(filePaths: Array(files.keys)))
        #expect(result == 0)
    }

    /// Happier path.
    @Test func testNoUnusedCodeNoProblemWithXib() async throws {
        let files: [String: String] = [
            "foo.swift": .oneUnusedItem,
            "foo.xib": .xibFileWithClassReference,
        ]
        let tool = UnusedCodeTool()
        let result = tool.run(fileReader: MockFileReader(files: files),
                              fileBrowser: MockFileBrowser(filePaths: Array(files.keys)))
        #expect(result == 0)
    }

    /// Happier path.
    @Test func testNoUnusedCodeNoProblemWithNib() async throws {
        let files: [String: String] = [
            "foo.swift": .oneUnusedItem,
            "foo.nib": .xibFileWithClassReference,
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
            ".unusedignore": "",
        ]
        let tool = UnusedCodeTool()
        let result = tool.run(fileReader: MockFileReader(files: files),
                              fileBrowser: MockFileBrowser(filePaths: Array(files.keys)))
        #expect(result == 1)
    }

    @Test func testUnusedEnumCaseProblem() async throws {
        let files: [String: String] = [
            "foo.swift": .oneUnusedEnumCase
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
            ".unusedignore": .unusedIgnoreFile,
        ]
        let tool = UnusedCodeTool()
        let result = tool.run(fileReader: MockFileReader(files: files),
                              fileBrowser: MockFileBrowser(filePaths: Array(files.keys)))
        #expect(result == 0)
    }

    /// Finds unused code, ignoring it because of the ignore file.
    @Test func testNoUnusedCodeNoProblemIfIgnored() async throws {
        let files: [String: String] = [
            "foo.swift": "",
            ".unusedignore": .unusedIgnoreFile,
        ]
        let tool = UnusedCodeTool()
        let result = tool.run(fileReader: MockFileReader(files: files),
                              fileBrowser: MockFileBrowser(filePaths: Array(files.keys)))
        #expect(result == 0)
    }

    /// Errors on file browser failure.
    @Test func testErrorsOnFileBrowserFailure() async throws {
        let tool = UnusedCodeTool()
        let result = tool.run(fileReader: MockFileReader(files: [:]),
                              fileBrowser: MockFileBrowser(filePaths: nil))
        #expect(result == 1)
    }

    /// Errors silently on file reader failure.
    @Test func testErrorsSilentlyOnFileReaderFailure() async throws {
        let tool = UnusedCodeTool()
        let result = tool.run(fileReader: MockFileReader(files: nil),
                              fileBrowser: MockFileBrowser(filePaths: [
                                  "foo.swift",
                                  "foo.xib",
                                  "foo.nib",
                              ]))
        #expect(result == 0)
    }
}
