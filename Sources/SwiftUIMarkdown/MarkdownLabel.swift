import Foundation
import SwiftUI

/// Renders a markdown string as inline-only styled text.
///
/// Use this for short strings in labels, list items, or anywhere you need
/// rich inline formatting without block structure. Supports bold, italic,
/// inline code, strikethrough, and links.
///
/// ```swift
/// MarkdownLabel("Download the **latest** version [here](https://example.com).")
/// ```
public struct MarkdownLabel: View {
    private let markdown: String

    @State private var attributedString = AttributedString()
    @Environment(\.markdownTheme) private var theme

    public init(_ markdown: String) {
        self.markdown = markdown
    }

    public var body: some View {
        theme.inlineText(from: attributedString)
            .font(theme.bodyFont)
            .foregroundColor(theme.bodyColor)
            .onChange(of: markdown, initial: true) { _, newValue in
                attributedString = Self.parse(newValue)
            }
    }

    private static func parse(_ markdown: String) -> AttributedString {
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace
        )
        return (try? AttributedString(markdown: markdown, options: options))
            ?? AttributedString(markdown)
    }
}

#if DEBUG
#Preview {
    VStack(alignment: .leading, spacing: 12) {
        MarkdownLabel("Plain text")
        MarkdownLabel("**Bold** and *italic*")
        MarkdownLabel("`inline code` snippet")
        MarkdownLabel("~~strikethrough~~ text")
        MarkdownLabel("A [link](https://example.com) inline")
        MarkdownLabel("Combined **bold _and italic_** text")
    }
    .padding()
}
#endif
