# Unused Code Tool

Unused Code Tool uses a simple text pattern matching approach to detect unused code. It's not intended to be perfect, just to help find obvious instances of unused code.

This package is adapted from the original [unused script](https://github.com/PaulTaykalo/swift-scripts) by [@PaulTaykalo](https://github.com/PaulTaykalo).

## Limitations

Due to the nature of the pattern matching approach, this tool often yields both false-positives and false-negatives. For example, when conforming to a protocol, often functions are called only by the system or an external actor, and therefore are not referenced, which results in a false-positive.

## Requirements

This binary requires macOS version 13 or above.

## Usage

To use this tool, download the binary from Github [here](https://github.com/rubencodes/UnusedCodeTool/blob/main/unused-code-tool). Then, run the binary from the command line to detect unused code in your current working directory:

```
./unused-code-tool
```

If no unused code is detected, the tool will silently exit. If unused code is found, you will see a report like this:

```
[Reporter] Found 4 unused items:
./MyApp/App Delegate/AppDelegate.swift: applicationDidBecomeActive
./Modules/GraphQL/Sources/Internal/Extensions/Localization.swift: importanceText
./Modules/Utilities/Sources/Public/Views/CircularProgressRing/UICircularProgressRing.swift: startProgress
./Modules/SharedUI/Sources/Public/Views/CircularProgressRing/UICircularProgressRing.swift: pauseProgress

[Reporter] If this is a false positive or an exception, please copy/paste the line item above to your unuseditemignore file.
```

and the script will exit with an error.

## Additional Options

- `--directory` - The directory to run the code search in (defaults to `.`)
- `--ignore-file-path` - The path to the unused file ignore list (defaults to `.unusedfileignore`) (details below)
- `--ignore-item-path` - The path to the unused item ignore list (defaults to `.unuseditemignore`) (details below)
- `--log-level` - The verbosity level for logging (defaults to `info`) (options: `debug`, `info`, `warning`, `error`)

## Ignoring Code

There are two ways to ask the Unused Code Tool to ignore code, with different levels of granularity.

### Ignore File (`.unusedfileignore`)

To ignore a file or directory, use the Ignore File to list patterns to ignore.

```
# .unusedfileignore
# File or directory paths to ignore (must be valid regex)
Pods
Tests/.*
```

For example, the above file would ignore all files within the `Pods` and `Tests` directories.

### Ignore Item (`.unuseditemignore`)

When false-positives occur, use the Ignore Item to list patterns to ignore within a file.

```
# .unuseditemignore
# Declarations to ignore; format is FILE_PATH: DECLARATION_NAME_REGEX
./MyWidget/MyWidget_WidgetBundle.swift: MyWidget_WidgetBundle
./Localization.swift: ThirdPartyString.*
```

For example, the above file would ignore the `MyWidget_WidgetBundle` declaration defined at the path `./MyWidget/MyWidget_WidgetBundle.swift`, and also all declarations in `Localization.swift` starting with `ThirdPartyString`.

**Note**: Regex is only supported for the declaration name.

## CI/CD

To assist with codebase upkeep, you can integrate this script as part of your CI/CD. See the [push](https://github.com/rubencodes/UnusedCodeTool/blob/main/.github/workflows/push.yml) workflow in this repository for an example.

## Building & Running

To build the script locally, execute the following in the command line at the root of the project:

```
swift build
```

To run the script lcoally:

```
swift run unused-code-tool
```

To package a new release executable, run:

```
swift build -c release
```

This will output a new binary at `.build/release/unused-code-tool`.
