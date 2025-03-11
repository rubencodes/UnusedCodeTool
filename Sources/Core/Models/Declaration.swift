import Foundation

/// Represents a code item found in a Swift file.
struct Declaration: Hashable {
    let file: String
    let line: String
    let at: Int
    let type: String
    let name: String
    let modifiers: [String]

    /// Whether the item is an override (exempt from usage checks).
    var isOverride: Bool {
        modifiers.contains("override")
    }

    /// Whether the item is exposed to IB.
    var isIBLinked: Bool {
        modifiers.contains("@IBOutlet") || modifiers.contains("@IBAction")
    }

    /// Whether the item is private or fileprivate (restricts usage check to same file).
    var isPrivate: Bool {
        modifiers.contains("private") || modifiers.contains("fileprivate")
    }
}

extension Declaration: Comparable {
    static func < (lhs: Declaration, rhs: Declaration) -> Bool {
        if lhs.file != rhs.file {
            return lhs.file < rhs.file
        } else if lhs.at != rhs.at {
            return lhs.at < rhs.at
        } else {
            return lhs.name < rhs.name
        }
    }
}
