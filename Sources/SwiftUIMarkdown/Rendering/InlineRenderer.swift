import SwiftUI

extension MarkdownTheme {
    /// Builds a SwiftUI `Text` from an `AttributedString` by iterating runs and
    /// applying theme-specific overrides for inline code and links on top of what
    /// `Text(AttributedString)` already renders from `InlinePresentationIntent`.
    func inlineText(from attrStr: AttributedString) -> Text {
        var result = Text("")
        for run in attrStr.runs {
            var runText = Text(AttributedString(attrStr[run.range]))
            let inline = run.inlinePresentationIntent ?? []
            if inline.contains(.code) {
                runText = runText.font(codeFont).foregroundColor(codeForeground)
            }
            if run.link != nil {
                runText = runText.foregroundColor(linkColor)
            }
            result = result + runText
        }
        return result
    }
}
