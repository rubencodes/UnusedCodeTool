import Foundation

protocol FileManaging {
    func files(atPath path: String) -> [String]?
}
