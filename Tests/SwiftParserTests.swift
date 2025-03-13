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

        let protocolBat = declarations.contains(where: {
            $0.name == "Bat" && $0.type == "protocol"
        })
        #expect(protocolBat)

        let classFoo = declarations.contains(where: {
            $0.name == "Foo" && $0.type == "class" && $0.modifiers.contains("final")
        })
        #expect(classFoo)

        let structQuz = declarations.contains(where: {
            $0.name == "Quz" && $0.type == "struct"
        })
        #expect(structQuz)

        let varBar = declarations.contains(where: {
            $0.name == "bar" && $0.type == "var"
        })
        #expect(varBar)

        let funcBaz = declarations.contains(where: {
            $0.name == "baz" && $0.type == "func" && $0.modifiers.contains("@IBAction") })
        #expect(funcBaz)
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

        let protocolBat = declarations.contains(where: {
            $0.name == "Bat" && $0.type == "protocol"
        })
        #expect(protocolBat)

        let structQuz = declarations.contains(where: {
            $0.name == "Quz" && $0.type == "struct"
        })
        #expect(structQuz)

        let varBar = declarations.contains(where: {
            $0.name == "bar" && $0.type == "var"
        })
        #expect(varBar)

        let funcBaz = declarations.contains(where: {
            $0.name == "baz" && $0.type == "func" && $0.modifiers.contains("@IBAction") })
        #expect(funcBaz)
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

        let protocolBat = declarations.contains(where: {
            $0.name == "Bat" && $0.type == "protocol"
        })
        #expect(protocolBat)

        let structQuz = declarations.contains(where: {
            $0.name == "Quz" && $0.type == "struct"
        })
        #expect(structQuz)

        let varBar = declarations.contains(where: {
            $0.name == "bar" && $0.type == "var"
        })
        #expect(varBar)

        let funcBaz = declarations.contains(where: {
            $0.name == "baz" && $0.type == "func" && $0.modifiers.contains("@IBAction") })
        #expect(funcBaz)
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

        let protocolBat = declarations.contains(where: {
            $0.name == "Bat" && $0.type == "protocol"
        })
        #expect(protocolBat)

        let structQuz = declarations.contains(where: {
            $0.name == "Quz" && $0.type == "struct"
        })
        #expect(structQuz)

        let varBar = declarations.contains(where: {
            $0.name == "bar" && $0.type == "var"
        })
        #expect(varBar)

        let funcBaz = declarations.contains(where: {
            $0.name == "baz" && $0.type == "func" && $0.modifiers.contains("@IBAction") })
        #expect(funcBaz)
    }

    /// We should ignore regex-matched files and declarations in the ignore list.
    @Test func testParserFindsDeclarationsOK() async throws {
        let files: [File] = [
            .init(path: "foo.swift", content: .oneUnusedItemWithPrivateIBOutlet),
        ]
        let parser = SwiftParser(logger: logger)
        let declarations = parser.extractDeclarations(in: files,
                                                      ignoringItems: [])
        #expect(declarations.count == 5)

        print(declarations)

        let protocolBat = declarations.contains(where: {
            $0.name == "Bat" && $0.type == "protocol"
        })
        #expect(protocolBat)

        let classFoo = declarations.contains(where: {
            $0.name == "Foo" && $0.type == "class" && $0.modifiers.contains("final")
        })
        #expect(classFoo)

        let structQuz = declarations.contains(where: {
            $0.name == "Quz" && $0.type == "struct"
        })
        #expect(structQuz)

        let varBar = declarations.contains(where: {
            $0.name == "bar" && $0.type == "var"
        })
        #expect(varBar)

        let funcBaz = declarations.contains(where: {
            $0.name == "baz" && $0.type == "func" && $0.isIBLinked })
        #expect(funcBaz)
    }
}
