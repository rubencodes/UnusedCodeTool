import Foundation

extension String {
    static var oneUnusedItem: String {
        """
        protocol Bat {}

        final class Foo: Bat {
            struct Quz {
                @IBAction func baz() {}
            }

            var bar = "baz"

            init() {
                Quz().baz()
                print(bar)
            }
        }
        """
    }

    static var oneUnusedItemPrivate: String {
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
    static var oneUnusedItemWithPrivateClass: String {
        """
        protocol Bat {}

        private final class Foo: Bat {
            struct Quz {
                @IBAction func baz() {}
            }

            var bar = "baz"

            init() {
                Quz().baz()
                print(bar)
            }
        }
        """
    }

    static var oneUnusedItemWithPrivateIBAction: String {
        """
        protocol Bat {}

        final class Foo: Bat {
            struct Quz {
                @IBAction private func baz() {}
            }

            @IBOutlet var bar = "baz"

            init() {
                Quz()
                print(bar)
            }
        }
        
        Foo()
        """
    }

    static var oneUnusedItemWithIBAction: String {
        """
        protocol Bat {}

        final class Foo: Bat {
            struct Quz {
                @IBAction func baz() {}
            }

            @IBOutlet var bar = "baz"

            init() {
                Quz()
                print(bar)
            }
        }
        
        Foo()
        """
    }

    static var oneUnusedItemWithPrivateIBOutlet: String {
        """
        protocol Bat {}

        final class Foo: Bat {
            struct Quz {
                @IBAction func baz() {}
            }

            @IBOutlet private var bar = "baz"

            init() {
                Quz().baz()
            }
        }
        
        Foo()
        """
    }

    static var oneUnusedItemWithIBOutlet: String {
        """
        protocol Bat {}

        final class Foo: Bat {
            struct Quz {
                @IBAction func baz() {}
            }

            @IBOutlet var bar = "baz"

            init() {
                Quz().baz()
            }
        }
        
        Foo()
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

    static var unusedIgnoreFileTwoItems: String {
        """
        # An example unused ignore file.
        \(Substring.ignoreFileLiteralDeclarationRegex)
        \(Substring.ignoreFileRegex)
        """
    }

    static var xibFileWithClassReference: String {
        """
        <object class="Foo"/>
        """
    }

    static var xibFileWithSelectorReference: String {
        """
        <object selector="baz"/>
        """
    }

    static var xibFileWithPropertyReference: String {
        """
        <object property="bar"/>
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
        "\"foo.swift\": \"Foo\""
    }

    static var ignoreFileLiteralDeclarationRegex: Substring {
        "\"foo.swift\": F.*"
    }

    static var ignoreFileRegexDeclarationRegex: Substring {
        ".*.swift: F.*"
    }
}
