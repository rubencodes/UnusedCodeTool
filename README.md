![Unused Code Tool](./Assets/unused-code-tool.png)

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

[Reporter] If this is a false-positive or expected, please copy/paste the line item above to your unused ignore file.
```

and the script will exit with an error.

The file list output by the script can be directly copy/pasted into your [unused ignore file](https://github.com/rubencodes/UnusedCodeTool?tab=readme-ov-file#ignoring-folders-files-and-declarations-unuseditemignore) to ignore those items in the future.

## Additional Options

- `--directory` - The directory to run the code search in (defaults to `.`)
- `--ignore-file-path` - The path to the unused file ignore list (defaults to `.unusedignore`) (details below)
- `--log-level` - The verbosity level for logging (defaults to `info`) (options: `debug`, `info`, `warning`, `error`)

## Ignoring Folders, Files, and Declarations (`.unusedignore`)

So you've got a false-positive, or maybe some code you're saving for later? That's cool! Using an Unused Ignore file, there are a few different ways to ask the Unused Code Tool to errors, depending on the granularity you need.

To ignore a file or directory, add a line item with the name or a regular expression to match against.

```
# .unusedignore
# File or directory paths to ignore can be specified in the format:
# FILE_OR_DIRECTORY_PATH_REGEX
Pods
.*Test.*
\.gitignore
```

For example, the above file would ignore all files within the `Pods` directory, with `Test` in the name, or named `.gitignore`.

Alternatively, you can also ignore individual declarations within a file:

```
# .unusedignore
# Declarations to ignore can be specified in the format:
# FILE_PATH: DECLARATION_NAME_REGEX
MyWidget/MyWidget_WidgetBundle\.swift: MyWidget_WidgetBundle
.*/Localization\.swift: ThirdPartyString.*
```

For example, the above file would ignore the `MyWidget_WidgetBundle` declaration defined in the file `MyWidget/MyWidget_WidgetBundle.swift`, and also all declarations starting with `ThirdPartyString` in all files named `Localization.swift`.

Note: Items listed in this file must be valid regex. To use a literal path definition, surround the item in quotation marks:

```
# .unusedignore
# Example without regex:
"MyWidget/MyWidget_WidgetBundle.swift": "MyWidget_WidgetBundle"
.*/Localization\.swift: ThirdPartyString.*
```

## CI/CD

To assist with codebase upkeep, you can integrate this script as part of your CI/CD. See the [push](https://github.com/rubencodes/UnusedCodeTool/blob/main/.github/workflows/push.yml) workflow in this repository for an example.

## Building & Running

To build the script locally, execute the following in the command line at the root of the project:

```
swift build
```

To run the script locally:

```
swift run unused-code-tool
```

To package a new release executable, run:

```
swift build -c release
```

This will output a new binary at `.build/release/unused-code-tool`.

## FAQ

### How does this work?

The Unused Code Tool by default looks at all your Swift files, uses a regular expression to identify declarations (think: variables, functions, protocols, etc), and then searches for non-comment references to those declarations across Swift files, xib files, and nib files.

### The unused-code-tool called out a system protocol function, like `applicationDidBecomeActive`! Why?

The Unused Code Tool is very dumb! If you're not calling that function anywhere in your code, the Unused Code Tool will find it. To ignore one-off weirdness like this, use an [unused ignore file](https://github.com/rubencodes/UnusedCodeTool?tab=readme-ov-file#ignoring-folders-files-and-declarations-unuseditemignore).

### The unused-code-tool called out a third-party framework! Why?

By default we look at _all_ Swift files in the current directory. To ignore a file or framework, use an [unused ignore file](https://github.com/rubencodes/UnusedCodeTool?tab=readme-ov-file#ignoring-folders-files-and-declarations-unuseditemignore).

### If the unused-code-tool is so dumb, why should I use it?

It's actually _shockingly_ good at finding unused for being such a simple little tool. I've used it find and delete thousands of lines of unused code in my codebases, but it does require careful combing through to make sure you're not deleting anything important.

**I would never trust it to delete code automatically**, but for alerting me to new possibly unused code, it works great!
