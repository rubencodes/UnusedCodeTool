import Foundation

extension CharacterSet {
    /// Characters valid for a variable. Used to detect usage.
    static var validVariableNameCharacters: CharacterSet {
        return CharacterSet.alphanumerics.union(.init(charactersIn: "_"))
    }
}
