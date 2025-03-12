import Foundation

extension Regex {
    /// Matches multi-line comments, e.g. `/* foo bar */`
    static var multilineComment: Regex<Substring> {
        #/\/\*[\s\S]*?\*\//#
    }

    /// Matches single-line comments, e.g. `// foo bar`
    static var singleLineComment: Regex<Substring> {
        #/(?:\/\/.*\n|\/\/.*$)/#
    }

    /// Matches single-line hash comments, e.g. `# foo bar`
    static var singleLineHashComment: Regex<Substring> {
        #/#(?:.*)$/#
    }

    /// Matches declarations, e.g. `var foo = "bar"`
    /// Captures the variable type (var) and variable name (foo).
    static var declaration: Regex<(Substring, variableType: Substring, variableName: Substring)> {
        #/(?<variableType>func|let|var|class|enum|struct|protocol)\s+(?<variableName>\w+)/#
    }

    /// Matches classes in xib files, e.g. `<xml class="foo"></xml>`
    /// Captures the class name (foo).
    static var xibClass: Regex<(Substring, className: Substring)> {
        #/(?:class|customClass)="(?<className>\w+)"/#
    }

    /// Matches selectors in xib files, e.g. `<xml selector="foo:"></xml>`
    /// Captures the selector name (foo).
    static var xibSelector: Regex<(Substring, selectorName: Substring)> {
        #/selector="(?<selectorName>\w+):?"/#
    }

    /// Matches properties in xib files, e.g. `<xml property="foo"></xml>`
    /// Captures the property name (foo).
    static var xibProperty: Regex<(Substring, propertyName: Substring)> {
        #/property="(?<propertyName>\w+)"/#
    }

    /// Matches command line arguments, e.g. `--foo=bar`
    /// Captures the argument name (foo) and the argument value (bar).
    static var argument: Regex<(Substring, argumentName: Substring, argumentValue: Substring)> {
        #/-?-?(?<argumentName>\w+)=\"?(?<argumentValue>.+)\"?/#
    }

    /// Matches regex literals, e.g. `#/(.*)/#`
    static var regexLiterals: Regex<Substring> {
        #/\#\/.*?\/\#/#
    }

    /// Matches escaped quotes, e.g. `"foo \"world\""`
    static var escapedQuotes: Regex<Substring> {
        #/\\"/#
    }

    /// Matches string literals:
    /// - `"foo"` (single-line)
    /// - `"foo \" bar"` (escaped quotes)
    /// - `""" foo """` (multiline string)
    static var stringLiteral: Regex<(Substring, stringLiteral: Substring)> {
        #/(?<stringLiteral>""".*?"""|"(?:[^"\\]|\\.)*?")/#
    }

    /// Matches string interpolations inside literals, e.g. `"foo \(bar) baz"`
    static var stringInterpolation: Regex<(Substring, interpolated: Substring)> {
        #/\\\((?<interpolated>.*?)\)/#
    }
}
