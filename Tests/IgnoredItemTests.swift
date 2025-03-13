@testable import Core
import Foundation
import Testing

struct IgnoredItemTests {
    /// Fails for empty line.
    @Test func testIgnoredItemFromEmptyLine() async throws {
        let item = try? IgnoredItem(line: "")
        #expect(item == nil)
    }

    /// Creates ignore file item from file literal.
    @Test func testIgnoredItemFromFileLiteral() async throws {
        let item = try? IgnoredItem(line: "\"file.swift\"")
        #expect(item?.matches(filePath: "file.swift") == true)
        #expect(item?.matches(filePath: "file2.swift") == false)
        #expect(item?.hasDeclarationFilter == false)
    }

    /// Creates ignore file item from file regex.
    @Test func testIgnoredItemFromFileRegex() async throws {
        let item = try? IgnoredItem(line: ".*.swift")
        #expect(item?.matches(filePath: "file.swift") == true)
        #expect(item?.matches(filePath: "file.xib") == false)
        #expect(item?.hasDeclarationFilter == false)

        let match = Declaration(file: "", line: "", at: 0, type: "var", name: "foo", modifiers: [])
        #expect(item?.matches(declaration: match) == false)
    }

    /// Creates ignore file item from file literal with declaration literal.
    @Test func testIgnoredItemFromFileLiteralWithDeclarationLiteral() async throws {
        let item = try? IgnoredItem(line: "\"file.swift\": \"foo\"")
        #expect(item?.matches(filePath: "file.swift") == true)
        #expect(item?.hasDeclarationFilter == true)

        let match = Declaration(file: "", line: "", at: 0, type: "var", name: "foo", modifiers: [])
        #expect(item?.matches(declaration: match) == true)

        let noMatch = Declaration(file: "", line: "", at: 0, type: "var", name: "bar", modifiers: [])
        #expect(item?.matches(declaration: noMatch) == false)
    }

    /// Creates ignore file item from file literal with declaration regex.
    @Test func testIgnoredItemFromFileLiteralWithDeclarationRegex() async throws {
        let item = try? IgnoredItem(line: "\"file.swift\": f.*")
        #expect(item?.matches(filePath: "file.swift") == true)
        #expect(item?.hasDeclarationFilter == true)

        let match = Declaration(file: "", line: "", at: 0, type: "var", name: "foo", modifiers: [])
        #expect(item?.matches(declaration: match) == true)

        let noMatch = Declaration(file: "", line: "", at: 0, type: "var", name: "bar", modifiers: [])
        #expect(item?.matches(declaration: noMatch) == false)
    }

    /// Creates ignore file item from file regex with declaration regex.
    @Test func testIgnoredItemFromFileRegexWithDeclarationRegex() async throws {
        let item = try? IgnoredItem(line: ".*.swift: f.*")
        #expect(item?.matches(filePath: "file.swift") == true)
        #expect(item?.matches(filePath: "file.xib") == false)
        #expect(item?.hasDeclarationFilter == true)

        let match = Declaration(file: "", line: "", at: 0, type: "var", name: "foo", modifiers: [])
        #expect(item?.matches(declaration: match) == true)

        let noMatch = Declaration(file: "", line: "", at: 0, type: "var", name: "bar", modifiers: [])
        #expect(item?.matches(declaration: noMatch) == false)
    }

    /// Creates ignore file item from file regex with declaration regex.
    @Test func testIgnoredEquality() async throws {
        let item1 = try? IgnoredItem(line: ".*.swift: f.*")
        let item2 = try? IgnoredItem(line: ".*.swift: f.*")
        #expect(item1 != nil)
        #expect(item1 != nil)
        #expect(item1 == item2)
    }

    /// Creates unused ignore item array from file content.
    @Test func testIgnoredItems() async throws {
        let logger = Logger(logLevel: .default)
        let empty = [IgnoredItem](from: "", logger: logger)
        #expect(empty == [])
        let invalid = [IgnoredItem](from: "\n\\: .*", logger: logger)
        #expect(invalid.first == nil)
        let item = [IgnoredItem](from: .unusedIgnoreFile, logger: logger)
        #expect(item.count == 1)
        let items = [IgnoredItem](from: .unusedIgnoreFileTwoItems, logger: logger)
        #expect(items.count == 2)
    }
}
