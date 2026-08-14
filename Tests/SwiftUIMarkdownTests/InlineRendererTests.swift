import Foundation
import Testing
@testable import SwiftUIMarkdown

@Suite("MarkdownTheme.inlineText")
struct InlineRendererTests {
    @Test("renders plain text without crashing")
    func plainText() throws {
        let attrStr = try AttributedString(
            markdown: "Hello, world.",
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )
        let text = MarkdownTheme.default.inlineText(from: attrStr)
        _ = text
    }

    @Test("renders bold text without crashing")
    func boldText() throws {
        let attrStr = try AttributedString(
            markdown: "**Bold**",
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )
        let text = MarkdownTheme.default.inlineText(from: attrStr)
        _ = text
    }

    @Test("renders inline code without crashing")
    func inlineCode() throws {
        let attrStr = try AttributedString(
            markdown: "`code`",
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )
        let text = MarkdownTheme.default.inlineText(from: attrStr)
        _ = text
    }
}
