import Foundation

extension String {
    static var oneUnusedItem: String {
        """
        protocol Bat {}

        private final class Foo: Bat {
            struct Quz {
                func baz() {}
            }

            var bar = "baz"

            init() {
                Quz().baz()
                print(bar)
            }
        }
        """
    }

    static var noUnusedItems: String {
        """
        // cute, right?
        \(oneUnusedItem)

        Foo()
        """
    }

    static var oneUnusedItemWithComments: String {
        """
        \(oneUnusedItem)

        /*

        Multi-line commented usages should be omitted as possible usages.

        Foo()

        */

        // Commented usages should be omitted as possible usages.
        // Foo()
        """
    }

    static var oneUnusedItemWithOverride: String {
        """
        \(oneUnusedItem)

        // Overriden items should be omitted from unused list.
        override func bat() {}
        """
    }

    static var oneUnusedItemWithRegex: String {
        """
        \(oneUnusedItem)

        // Regexes should be omitted as possible usages.
        #/.*Foo.*/#
        """
    }

    static var oneUnusedItemWithString: String {
        """
        \(oneUnusedItem)

        // Strings should be omitted as possible usages.
        print("Foo")
        """
    }

    static var noUnusedItemWithStringInterpolation: String {
        """
        \(oneUnusedItem)

        // Interpolated usages should count as usages.
        print("corge \\(Foo())grault")
        """
    }

    static var privateDeclarationUsage: String {
        """
        // Usages of private items should not as usages from other files.
        print(Foo())
        """
    }

    static var unusedIgnoreFile: String {
        """
        # An example unused ignore file.
        \(Substring.ignoreFileLiteralDeclarationRegex)
        """
    }
}

extension Substring {
    static var ignoreFileLiteral: Substring {
        "\"foo.swift\""
    }

    static var ignoreFileRegex: Substring {
        ".*.swift"
    }

    static var ignoreFileLiteralDeclarationLiteral: Substring {
        "\"foo.swift\": \"Bat\""
    }

    static var ignoreFileLiteralDeclarationRegex: Substring {
        "\"foo.swift\": F.*"
    }

    static var ignoreFileRegexDeclarationRegex: Substring {
        ".*.swift: F.*"
    }
}
