import Foundation

protocol FileBrowser {
    func getFilePaths(in directory: String,
                      matchingExtension fileExtension: String?,
                      ignoringItems ignoredItems: [IgnoredItem]) -> [String]
}
