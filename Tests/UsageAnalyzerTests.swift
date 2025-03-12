@testable import Core
import Foundation
import Testing

struct UsageAnalyzerTests {
    private let logger = Logger(logLevel: .info)

    // Happy path.
    @Test func testUsageAnalyzerFindsNoUnusedItems() async throws {
        let files: [String: String] = [
            "foo.swift": .noUnusedItems,
        ]
        let fileReader = MockFileReader(files: files)
        let parser = SwiftParser(logger: logger)
        let declarations = parser.extractDeclarations(in: Array(files.keys),
                                                      ignoringItems: [],
                                                      using: fileReader)
        let analyzer = UsageAnalyzer(logger: logger)
        let unused = analyzer.findUnused(declarations: declarations,
                                         in: Array(files.keys),
                                         xibs: [],
                                         using: fileReader)
        #expect(unused.count == 0)
    }

    /// Base case: we should find the one unused item.
    @Test func testUsageAnalyzerFindsUnusedItems() async throws {
        let files: [String: String] = [
            "foo.swift": .oneUnusedItem,
        ]
        let fileReader = MockFileReader(files: files)
        let parser = SwiftParser(logger: logger)
        let declarations = parser.extractDeclarations(in: Array(files.keys),
                                                      ignoringItems: [],
                                                      using: fileReader)
        let analyzer = UsageAnalyzer(logger: logger)
        let unused = analyzer.findUnused(declarations: declarations,
                                         in: Array(files.keys),
                                         xibs: [],
                                         using: fileReader)
        #expect(unused.count == 1)
    }

    // Ignores missing files.
    @Test func testUsageAnalyzerFindsNoUnusedItemsIgnoringMissingSwiftFiles() async throws {
        let files: [String: String] = [
            "foo.swift": .oneUnusedItem,
        ]
        let fileReader = MockFileReader(files: files)
        let parser = SwiftParser(logger: logger)
        let declarations = parser.extractDeclarations(in: Array(files.keys),
                                                      ignoringItems: [],
                                                      using: fileReader)
        let analyzer = UsageAnalyzer(logger: logger)
        let unused = analyzer.findUnused(declarations: declarations,
                                         in: Array(files.keys) + ["bar.swift"],
                                         xibs: [],
                                         using: fileReader)
        #expect(unused.count == 1)
    }

    // Ignores missing files.
    @Test func testUsageAnalyzerFindsNoUnusedItemsIgnoringMissingXibFiles() async throws {
        let files: [String: String] = [
            "foo.swift": .oneUnusedItem,
        ]
        let fileReader = MockFileReader(files: files)
        let parser = SwiftParser(logger: logger)
        let declarations = parser.extractDeclarations(in: Array(files.keys),
                                                      ignoringItems: [],
                                                      using: fileReader)
        let analyzer = UsageAnalyzer(logger: logger)
        let unused = analyzer.findUnused(declarations: declarations,
                                         in: Array(files.keys),
                                         xibs: ["bar.xib"],
                                         using: fileReader)
        #expect(unused.count == 1)
    }

    /// References within comments should not count as usages.
    @Test func testUsageAnalyzerFindsUnusedItemsWithComments() async throws {
        let files: [String: String] = [
            "foo.swift": .oneUnusedItemWithComments,
        ]
        let fileReader = MockFileReader(files: files)
        let parser = SwiftParser(logger: logger)
        let declarations = parser.extractDeclarations(in: Array(files.keys),
                                                      ignoringItems: [],
                                                      using: fileReader)
        let analyzer = UsageAnalyzer(logger: logger)
        let unused = analyzer.findUnused(declarations: declarations,
                                         in: Array(files.keys),
                                         xibs: [],
                                         using: fileReader)
        #expect(unused.count == 1)
    }

    /// Declarations that are overrides should not count as unused.
    @Test func testUsageAnalyzerFindsUnusedItemsWithOverrideModifier() async throws {
        let files: [String: String] = [
            "foo.swift": .oneUnusedItemWithOverride,
        ]
        let fileReader = MockFileReader(files: files)
        let parser = SwiftParser(logger: logger)
        let declarations = parser.extractDeclarations(in: Array(files.keys),
                                                      ignoringItems: [],
                                                      using: fileReader)
        let analyzer = UsageAnalyzer(logger: logger)
        let unused = analyzer.findUnused(declarations: declarations,
                                         in: Array(files.keys),
                                         xibs: [],
                                         using: fileReader)
        #expect(unused.count == 1)
    }

    /// Private declarations referenced from a different file should not count as usages.
    @Test func testUsageAnalyzerFindsUnusedItemsWithPrivateModifier() async throws {
        let files: [String: String] = [
            "foo.swift": .oneUnusedItemPrivate,
            "bar.swift": .privateDeclarationUsage,
        ]
        let fileReader = MockFileReader(files: files)
        let parser = SwiftParser(logger: logger)
        let declarations = parser.extractDeclarations(in: Array(files.keys),
                                                      ignoringItems: [],
                                                      using: fileReader)
        let analyzer = UsageAnalyzer(logger: logger)
        let unused = analyzer.findUnused(declarations: declarations,
                                         in: Array(files.keys),
                                         xibs: [],
                                         using: fileReader)
        #expect(unused.count == 1)
    }

    /// Declarations matched inside a regex should not count as usages.
    @Test func testUsageAnalyzerFindsUnusedItemsWithRegex() async throws {
        let files: [String: String] = [
            "foo.swift": .oneUnusedItemWithRegex,
        ]
        let fileReader = MockFileReader(files: files)
        let parser = SwiftParser(logger: logger)
        let declarations = parser.extractDeclarations(in: Array(files.keys),
                                                      ignoringItems: [],
                                                      using: fileReader)
        let analyzer = UsageAnalyzer(logger: logger)
        let unused = analyzer.findUnused(declarations: declarations,
                                         in: Array(files.keys),
                                         xibs: [],
                                         using: fileReader)
        #expect(unused.count == 1)
    }

    /// Declarations matched inside a string should not count as usages.
    @Test func testUsageAnalyzerFindsUnusedItemsWithString() async throws {
        let files: [String: String] = [
            "foo.swift": .oneUnusedItemWithString,
        ]
        let fileReader = MockFileReader(files: files)
        let parser = SwiftParser(logger: logger)
        let declarations = parser.extractDeclarations(in: Array(files.keys),
                                                      ignoringItems: [],
                                                      using: fileReader)
        let analyzer = UsageAnalyzer(logger: logger)
        let unused = analyzer.findUnused(declarations: declarations,
                                         in: Array(files.keys),
                                         xibs: [],
                                         using: fileReader)
        #expect(unused.count == 1)
    }

    /// Declarations matched inside a string interpolation should count as usages.
    @Test func testUsageAnalyzerFindsNoUnusedItemsWithStringInterpolation() async throws {
        let files: [String: String] = [
            "foo.swift": .noUnusedItemWithStringInterpolation,
        ]
        let fileReader = MockFileReader(files: files)
        let parser = SwiftParser(logger: logger)
        let declarations = parser.extractDeclarations(in: Array(files.keys),
                                                      ignoringItems: [],
                                                      using: fileReader)
        let analyzer = UsageAnalyzer(logger: logger)
        let unused = analyzer.findUnused(declarations: declarations,
                                         in: Array(files.keys),
                                         xibs: [],
                                         using: fileReader)
        #expect(unused.count == 0)
    }

    /// Declarations matched inside a xib file should count as usages.
    @Test func testUsageAnalyzerFindsNoUnusedItemsWithXibClassReference() async throws {
        let files: [String: String] = [
            "foo.swift": .oneUnusedItem,
            "foo.xib": .xibFileWithClassReference,
        ]
        let fileReader = MockFileReader(files: files)
        let fileBrowser = MockFileBrowser(filePaths: Array(files.keys))
        let swiftFiles = fileBrowser.getFilePaths(in: "", matchingExtension: ".swift", ignoringItems: [])
        let xibFiles = fileBrowser.getFilePaths(in: "", matchingExtension: ".xib", ignoringItems: [])

        let parser = SwiftParser(logger: logger)
        let declarations = parser.extractDeclarations(in: swiftFiles,
                                                      ignoringItems: [],
                                                      using: fileReader)
        let analyzer = UsageAnalyzer(logger: logger)
        let unused = analyzer.findUnused(declarations: declarations,
                                         in: swiftFiles,
                                         xibs: xibFiles,
                                         using: fileReader)
        #expect(unused.count == 0)
    }

    /// Declarations matched inside a xib file should count as usages.
    @Test func testUsageAnalyzerFindsNoUnusedItemsWithXibSelectorReference() async throws {
        let files: [String: String] = [
            "foo.swift": .oneUnusedItem,
            "foo.xib": .xibFileWithSelectorReference,
        ]
        let fileReader = MockFileReader(files: files)
        let fileBrowser = MockFileBrowser(filePaths: Array(files.keys))
        let swiftFiles = fileBrowser.getFilePaths(in: "", matchingExtension: ".swift", ignoringItems: [])
        let xibFiles = fileBrowser.getFilePaths(in: "", matchingExtension: ".xib", ignoringItems: [])

        let parser = SwiftParser(logger: logger)
        let declarations = parser.extractDeclarations(in: swiftFiles,
                                                      ignoringItems: [],
                                                      using: fileReader)
        let analyzer = UsageAnalyzer(logger: logger)
        let unused = analyzer.findUnused(declarations: declarations,
                                         in: swiftFiles,
                                         xibs: xibFiles,
                                         using: fileReader)
        #expect(unused.count == 0)
    }

    /// Declarations matched inside a xib file should count as usages.
    @Test func testUsageAnalyzerFindsNoUnusedItemsWithXibPropertyReference() async throws {
        let files: [String: String] = [
            "foo.swift": .oneUnusedItem,
            "foo.xib": .xibFileWithPropertyReference,
        ]
        let fileReader = MockFileReader(files: files)
        let fileBrowser = MockFileBrowser(filePaths: Array(files.keys))
        let swiftFiles = fileBrowser.getFilePaths(in: "", matchingExtension: ".swift", ignoringItems: [])
        let xibFiles = fileBrowser.getFilePaths(in: "", matchingExtension: ".xib", ignoringItems: [])

        let parser = SwiftParser(logger: logger)
        let declarations = parser.extractDeclarations(in: swiftFiles,
                                                      ignoringItems: [],
                                                      using: fileReader)
        let analyzer = UsageAnalyzer(logger: logger)
        let unused = analyzer.findUnused(declarations: declarations,
                                         in: swiftFiles,
                                         xibs: xibFiles,
                                         using: fileReader)
        #expect(unused.count == 0)
    }
}
