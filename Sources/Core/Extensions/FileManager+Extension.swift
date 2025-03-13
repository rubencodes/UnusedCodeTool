import Foundation

extension FileManager: FileManaging {
    func files(atPath path: String) -> [String]? {
        enumerator(atPath: path)?.allObjects.compactMap { $0 as? String }
    }
}
