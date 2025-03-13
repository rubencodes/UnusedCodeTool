@testable import Core
import Foundation
import Testing

struct ArgumentParserTests {
    /// Happy path.
    @Test func testArgumentParserParsesArguments() async throws {
        let arguments = [
            "--foo=bar",
            "baz=bat",
        ]

        let foo = ArgumentParser.find("foo", from: arguments)
        #expect(foo == "bar")

        let baz = ArgumentParser.find("baz", from: arguments)
        #expect(baz == "bat")

        let qux = ArgumentParser.find("qux", from: arguments)
        #expect(qux == nil)
    }
}
