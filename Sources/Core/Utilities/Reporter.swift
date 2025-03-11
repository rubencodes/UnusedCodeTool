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
    func print(for unusedDeclarations: [Declaration]) {
        guard unusedDeclarations.isEmpty else {
            logger.info("[Reporter] Found \(unusedDeclarations.count) unused items:")
            unusedDeclarations.sorted().forEach {
                logger.error("\($0.file): \($0.name)")
            }
            logger.info("")
            logger.info("[Reporter] If this is a false positive or an exception, please copy/paste the line item above to your unuseditemignore file.")
            exit(1)
        }

        // Omitted at default log level, per unix guidelines.
        logger.debug("[Reporter] Found 0 unused items.")
        exit(0)
    }
}
