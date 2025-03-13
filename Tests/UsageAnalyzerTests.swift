@testable import Core
import Foundation
import Testing

struct UsageAnalyzerTests {
    private let logger = Logger(logLevel: .info)

    /// Happy path.
    @Test func testUsageAnalyzerFindsNoUnusedItems() async throws {
        let files: [File] = [
            .init(path: "foo.swift", content: .noUnusedItems),
        ]
        let parser = SwiftParser(logger: logger)
        let declarations = parser.extractDeclarations(in: files,
                                                      ignoringItems: [])
        let analyzer = UsageAnalyzer(logger: logger)
        let unused = analyzer.findUnused(declarations: declarations,
                                         in: files,
                                         xibs: [])
        #expect(unused.count == 0)
    }

    /// Base case: we should find the one unused item.
    @Test func testUsageAnalyzerFindsUnusedItems() async throws {
        let files: [File] = [
            .init(path: "foo.swift", content: .oneUnusedItem),
        ]
        let parser = SwiftParser(logger: logger)
        let declarations = parser.extractDeclarations(in: files,
                                                      ignoringItems: [])
        let analyzer = UsageAnalyzer(logger: logger)
        let unused = analyzer.findUnused(declarations: declarations,
                                         in: files,
                                         xibs: [])
        #expect(unused.count == 1)
    }

    /// References within comments should not count as usages.
    @Test func testUsageAnalyzerFindsUnusedItemsWithComments() async throws {
        let files: [File] = [
            .init(path: "foo.swift", content: .oneUnusedItemWithComments),
        ]
        let parser = SwiftParser(logger: logger)
        let declarations = parser.extractDeclarations(in: files,
                                                      ignoringItems: [])
        let analyzer = UsageAnalyzer(logger: logger)
        let unused = analyzer.findUnused(declarations: declarations,
                                         in: files,
                                         xibs: [])
        #expect(unused.count == 1)
    }

    /// Declarations that are overrides should not count as unused.
    @Test func testUsageAnalyzerFindsUnusedItemsWithOverrideModifier() async throws {
        let files: [File] = [
            .init(path: "foo.swift", content: .oneUnusedItemWithOverride),
        ]
        let parser = SwiftParser(logger: logger)
        let declarations = parser.extractDeclarations(in: files,
                                                      ignoringItems: [])
        let analyzer = UsageAnalyzer(logger: logger)
        let unused = analyzer.findUnused(declarations: declarations,
                                         in: files,
                                         xibs: [])
        #expect(unused.count == 1)
    }

    /// Private declarations referenced from a different file should not count as usages.
    @Test func testUsageAnalyzerFindsUnusedItemsWithPrivateModifier() async throws {
        let files: [File] = [
            .init(path: "foo.swift", content: .oneUnusedItemPrivate),
            .init(path: "bar.swift", content: .privateDeclarationUsage),
        ]
        let parser = SwiftParser(logger: logger)
        let declarations = parser.extractDeclarations(in: files,
                                                      ignoringItems: [])
        let analyzer = UsageAnalyzer(logger: logger)
        let unused = analyzer.findUnused(declarations: declarations,
                                         in: files,
                                         xibs: [])
        #expect(unused.count == 1)
    }

    /// Declarations matched inside a regex should not count as usages.
    @Test func testUsageAnalyzerFindsUnusedItemsWithRegex() async throws {
        let files: [File] = [
            .init(path: "foo.swift", content: .oneUnusedItemWithRegex),
        ]
        let parser = SwiftParser(logger: logger)
        let declarations = parser.extractDeclarations(in: files,
                                                      ignoringItems: [])
        let analyzer = UsageAnalyzer(logger: logger)
        let unused = analyzer.findUnused(declarations: declarations,
                                         in: files,
                                         xibs: [])
        #expect(unused.count == 1)
    }

    /// Declarations matched inside a string should not count as usages.
    @Test func testUsageAnalyzerFindsUnusedItemsWithString() async throws {
        let files: [File] = [
            .init(path: "foo.swift", content: .oneUnusedItemWithString),
        ]
        let parser = SwiftParser(logger: logger)
        let declarations = parser.extractDeclarations(in: files,
                                                      ignoringItems: [])
        let analyzer = UsageAnalyzer(logger: logger)
        let unused = analyzer.findUnused(declarations: declarations,
                                         in: files,
                                         xibs: [])
        #expect(unused.count == 1)
    }

    /// Declarations matched inside a string interpolation should count as usages.
    @Test func testUsageAnalyzerFindsNoUnusedItemsWithStringInterpolation() async throws {
        let files: [File] = [
            .init(path: "foo.swift", content: .noUnusedItemWithStringInterpolation),
        ]
        let parser = SwiftParser(logger: logger)
        let declarations = parser.extractDeclarations(in: files,
                                                      ignoringItems: [])
        let analyzer = UsageAnalyzer(logger: logger)
        let unused = analyzer.findUnused(declarations: declarations,
                                         in: files,
                                         xibs: [])
        #expect(unused.count == 0)
    }

    /// Declarations matched inside a xib file should count as usages.
    @Test func testUsageAnalyzerFindsNoUnusedItemsWithXibClassReference() async throws {
        let swiftFiles: [File] = [
            .init(path: "foo.swift", content: .oneUnusedItem),
        ]
        let xibFiles: [File] = [
            .init(path: "foo.xib", content: .xibFileWithClassReference),
        ]

        let parser = SwiftParser(logger: logger)
        let declarations = parser.extractDeclarations(in: swiftFiles,
                                                      ignoringItems: [])
        let analyzer = UsageAnalyzer(logger: logger)
        let unused = analyzer.findUnused(declarations: declarations,
                                         in: swiftFiles,
                                         xibs: xibFiles)
        #expect(unused.count == 0)
    }

    /// Declarations matched inside a xib file should count as usages.
    @Test func testUsageAnalyzerFindsNoUnusedItemsWithPrivateXibClassReference() async throws {
        let swiftFiles: [File] = [
            .init(path: "foo.swift", content: .oneUnusedItemWithPrivateClass),
        ]
        let xibFiles: [File] = [
            .init(path: "foo.xib", content: .xibFileWithClassReference),
        ]

        let parser = SwiftParser(logger: logger)
        let declarations = parser.extractDeclarations(in: swiftFiles,
                                                      ignoringItems: [])
        let analyzer = UsageAnalyzer(logger: logger)
        let unused = analyzer.findUnused(declarations: declarations,
                                         in: swiftFiles,
                                         xibs: xibFiles)
        #expect(unused.count == 0)
    }

    /// Declarations matched inside a xib file should count as usages.
    @Test func testUsageAnalyzerFindsNoUnusedItemsWithXibSelectorReference() async throws {
        let swiftFiles: [File] = [
            .init(path: "foo.swift", content: .oneUnusedItemWithIBAction),
        ]
        let xibFiles: [File] = [
            .init(path: "foo.xib", content: .xibFileWithSelectorReference),
        ]

        let parser = SwiftParser(logger: logger)
        let declarations = parser.extractDeclarations(in: swiftFiles,
                                                      ignoringItems: [])
        let analyzer = UsageAnalyzer(logger: logger)
        let unused = analyzer.findUnused(declarations: declarations,
                                         in: swiftFiles,
                                         xibs: xibFiles)
        #expect(unused.count == 0)
    }

    /// Declarations matched inside a xib file should count as usages.
    @Test func testUsageAnalyzerFindsNoUnusedItemsWithPrivateXibSelectorReference() async throws {
        let swiftFiles: [File] = [
            .init(path: "foo.swift", content: .oneUnusedItemWithPrivateIBAction),
        ]
        let xibFiles: [File] = [
            .init(path: "foo.xib", content: .xibFileWithSelectorReference),
        ]

        let parser = SwiftParser(logger: logger)
        let declarations = parser.extractDeclarations(in: swiftFiles,
                                                      ignoringItems: [])
        let analyzer = UsageAnalyzer(logger: logger)
        let unused = analyzer.findUnused(declarations: declarations,
                                         in: swiftFiles,
                                         xibs: xibFiles)
        #expect(unused == [])
    }

    /// Declarations matched inside a xib file should count as usages.
    @Test func testUsageAnalyzerFindsNoUnusedItemsWithXibPropertyReference() async throws {
        let swiftFiles: [File] = [
            .init(path: "foo.swift", content: .oneUnusedItemWithIBOutlet),
        ]
        let xibFiles: [File] = [
            .init(path: "foo.xib", content: .xibFileWithPropertyReference),
        ]

        let parser = SwiftParser(logger: logger)
        let declarations = parser.extractDeclarations(in: swiftFiles,
                                                      ignoringItems: [])
        let analyzer = UsageAnalyzer(logger: logger)
        let unused = analyzer.findUnused(declarations: declarations,
                                         in: swiftFiles,
                                         xibs: xibFiles)
        #expect(unused == [])
    }

    /// Declarations matched inside a xib file should count as usages.
    @Test func testUsageAnalyzerFindsNoUnusedItemsWithPrivateXibPropertyReference() async throws {
        let swiftFiles: [File] = [
            .init(path: "foo.swift", content: .oneUnusedItemWithPrivateIBOutlet),
        ]
        let xibFiles: [File] = [
            .init(path: "foo.xib", content: .xibFileWithPropertyReference),
        ]

        let parser = SwiftParser(logger: logger)
        let declarations = parser.extractDeclarations(in: swiftFiles,
                                                      ignoringItems: [])
        let analyzer = UsageAnalyzer(logger: logger)
        let unused = analyzer.findUnused(declarations: declarations,
                                         in: swiftFiles,
                                         xibs: xibFiles)
        #expect(unused == [])
    }
}
