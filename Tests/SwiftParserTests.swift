@testable import Core
import Foundation
import Testing

struct SwiftParserTests {
    private let logger = Logger(logLevel: .info)

    /// Happy path.
    @Test func testParserFindsDeclarations() async throws {
        let files: [File] = [
            .init(path: "foo.swift", content: .noUnusedItems),
        ]
        let parser = SwiftParser(logger: logger)
        let declarations = parser.extractDeclarations(in: files,
                                                      ignoringItems: [])
        #expect(declarations.count == 5)
    }

    /// We should ignore literal files in the ignore list.
    @Test func testParserFindsDeclarationsIgnoringIgnoredFiles() async throws {
        let files: [File] = [
            .init(path: "foo.swift", content: .noUnusedItems),
        ]
        let parser = SwiftParser(logger: logger)
        let ignoredItem = try! IgnoredItem(line: .ignoreFileLiteral)
        let declarations = parser.extractDeclarations(in: files,
                                                      ignoringItems: [ignoredItem].compactMap { $0 })
        #expect(declarations.count == 0)
    }

    /// We should ignore regex-matched files in the ignore list.
    @Test func testParserFindsDeclarationsIgnoringIgnoredFilesWithRegexFile() async throws {
        let files: [File] = [
            .init(path: "foo.swift", content: .noUnusedItems),
        ]
        let parser = SwiftParser(logger: logger)
        let ignoredItem = try! IgnoredItem(line: .ignoreFileRegex)
        let declarations = parser.extractDeclarations(in: files,
                                                      ignoringItems: [ignoredItem].compactMap { $0 })
        #expect(declarations.count == 0)
    }

    /// We should ignore literal declarations in the ignore list.
    @Test func testParserFindsDeclarationsIgnoringIgnoredItems() async throws {
        let files: [File] = [
            .init(path: "foo.swift", content: .noUnusedItems),
        ]
        let parser = SwiftParser(logger: logger)
        let ignoredItem = try! IgnoredItem(line: .ignoreFileLiteralDeclarationLiteral)
        let declarations = parser.extractDeclarations(in: files,
                                                      ignoringItems: [ignoredItem].compactMap { $0 })
        #expect(declarations.count == 4)
    }

    /// We should ignore regex-matched declarations in the ignore list.
    @Test func testParserFindsDeclarationsIgnoringIgnoredItemsWithRegexDeclaration() async throws {
        let files: [File] = [
            .init(path: "foo.swift", content: .noUnusedItems),
        ]
        let parser = SwiftParser(logger: logger)
        let ignoredItem = try! IgnoredItem(line: .ignoreFileLiteralDeclarationRegex)
        let declarations = parser.extractDeclarations(in: files,
                                                      ignoringItems: [ignoredItem].compactMap { $0 })
        #expect(declarations.count == 4)
    }

    /// We should ignore regex-matched files and declarations in the ignore list.
    @Test func testParserFindsDeclarationsIgnoringIgnoredItemsWithRegex() async throws {
        let files: [File] = [
            .init(path: "foo.swift", content: .noUnusedItems),
        ]
        let parser = SwiftParser(logger: logger)
        let ignoredItem = try! IgnoredItem(line: .ignoreFileRegexDeclarationRegex)
        let declarations = parser.extractDeclarations(in: files,
                                                      ignoringItems: [ignoredItem].compactMap { $0 })
        #expect(declarations.count == 4)
    }
}
