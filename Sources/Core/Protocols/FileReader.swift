import Foundation

protocol FileReader {
    func readFile(at filePath: String) -> String?
}
