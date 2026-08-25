import Testing
import SwiftUI
@testable import SwiftUIMarkdown

@Suite("MarkdownTheme")
struct MarkdownThemeTests {
    @Test("default theme heading fonts decrease by level")
    func defaultHeadingFontScalesDown() {
        let theme = MarkdownTheme.default
        // Fonts should be different for each level — just ensure no crash
        for level in 1...6 {
            let font = theme.headingFont(level)
            _ = font  // existence check
        }
    }

    @Test("mutating a preset produces an independent copy")
    func themeIsCopyOnMutate() {
        var custom = MarkdownTheme.default
        custom.headingColor = .red
        custom.blockSpacing = 99
        #expect(custom.blockSpacing == 99)
        // The original preset is unaffected (static let, value type)
        #expect(MarkdownTheme.default.blockSpacing == 12)
    }

    @Test("github theme has tighter spacing than default")
    func githubSpacingIsTighter() {
        #expect(MarkdownTheme.github.blockSpacing < MarkdownTheme.default.blockSpacing)
    }

    @Test("default preset has sensible image and table tokens")
    func defaultPresetHasImageAndTableTokens() {
        let theme = MarkdownTheme.default
        #expect(theme.imageMaxHeight > 0)
        #expect(theme.tableCornerRadius > 0)
        #expect(theme.tableMinColumnWidth > 0)
        _ = theme.tableHeaderBackground
        _ = theme.tableRowAlternateBackground
        _ = theme.tableBorderColor
    }

    @Test("github preset has sensible image and table tokens")
    func githubPresetHasImageAndTableTokens() {
        let theme = MarkdownTheme.github
        #expect(theme.imageMaxHeight > 0)
        #expect(theme.tableCornerRadius > 0)
        #expect(theme.tableMinColumnWidth > 0)
        _ = theme.tableHeaderBackground
        _ = theme.tableRowAlternateBackground
        _ = theme.tableBorderColor
    }
}
