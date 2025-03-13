@testable import Core
import Foundation
import Testing

struct DeclarationTests {
    /// Sort by file name, line number, and name.
    @Test func testModifiers() async throws {
        let foo = Declaration(file: "a.swift", line: "var foo = 0", at: 0, type: "var", name: "foo", modifiers: [
            "private",
            "@IBOutlet",
            "override",
        ])
        #expect(foo.isOverride == true)
        #expect(foo.isPrivate == true)
        #expect(foo.isIBLinked == true)

        let foo2 = Declaration(file: "a.swift", line: "var foo = 0", at: 0, type: "var", name: "foo", modifiers: [
            "override",
        ])
        #expect(foo2.isOverride == true)
        #expect(foo2.isPrivate == false)
        #expect(foo2.isIBLinked == false)

        let foo3 = Declaration(file: "a.swift", line: "var foo = 0", at: 0, type: "var", name: "foo", modifiers: [
            "private",
        ])
        #expect(foo3.isOverride == false)
        #expect(foo3.isPrivate == true)
        #expect(foo3.isIBLinked == false)

        let foo4 = Declaration(file: "a.swift", line: "var foo = 0", at: 0, type: "var", name: "foo", modifiers: [
            "@IBOutlet",
        ])
        #expect(foo4.isOverride == false)
        #expect(foo4.isPrivate == false)
        #expect(foo4.isIBLinked == true)
    }

    /// Sort by file name, line number, and name.
    @Test func testDeclarationsSortCorrectly() async throws {
        let a1 = Declaration(file: "a.swift", line: "var foo = 0", at: 0, type: "var", name: "foo", modifiers: [])
        let a2 = Declaration(file: "a.swift", line: "var bar = 0, var baz = 1", at: 1, type: "var", name: "bar", modifiers: [])
        let a3 = Declaration(file: "a.swift", line: "var bar = 0, var baz = 1", at: 1, type: "var", name: "baz", modifiers: [])
        let b = Declaration(file: "b.swift", line: "var bar = 0", at: 0, type: "var", name: "bar", modifiers: [])
        let c = Declaration(file: "c.swift", line: "var bar = 0", at: 0, type: "var", name: "bar", modifiers: [])
        let declarations: [Declaration] = [a1, a2, a3, b, c].shuffled().sorted()
        #expect(declarations == [a1, a2, a3, b, c])
    }
}
