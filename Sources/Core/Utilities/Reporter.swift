import Foundation

/// Outputs report of unused items.
struct Reporter {
    // MARK: - Private Properties

    private let logger: Logger

    // MARK: - Lifecycle

    init(logger: Logger) {
        self.logger = logger
    }

    /// Prints a summary of unused code items, if any.
    /// - Parameters:
    ///   - unusedDeclarations: A list of unused code items.
    /// - Returns:
    ///   - Count of unused items.
    func print(for unusedDeclarations: [Declaration]) -> Int {
        guard unusedDeclarations.isEmpty else {
            logger.info("[Reporter] Found \(unusedDeclarations.count) unused items:")
            for unusedDeclaration in unusedDeclarations.sorted() {
                logger.error("\"\(unusedDeclaration.file)\": \(unusedDeclaration.name)")
            }
            logger.info("")
            logger.info("[Reporter] If this is a false-positive or expected, please copy/paste the line item above to your unused ignore file.")
            return unusedDeclarations.count
        }

        // Omitted at default log level, per unix guidelines.
        logger.debug("[Reporter] Found 0 unused items.")
        return unusedDeclarations.count
    }
}
