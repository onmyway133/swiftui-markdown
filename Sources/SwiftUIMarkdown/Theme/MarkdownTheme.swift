import SwiftUI

/// All visual styling for a `MarkdownView`.
///
/// Copy-and-modify the built-in presets to create your own:
/// ```swift
/// var theme = MarkdownTheme.default
/// theme.headingColor = .purple
/// view.markdownTheme(theme)
/// ```
public struct MarkdownTheme: Sendable {
    /// Returns the font for a heading at the given level (1–6).
    public var headingFont: @Sendable (Int) -> Font
    public var headingColor: Color
    public var bodyFont: Font
    public var bodyColor: Color
    public var codeFont: Font
    public var codeBackground: Color
    public var codeForeground: Color
    public var quoteBarColor: Color
    public var quoteTextColor: Color
    public var linkColor: Color
    /// Vertical spacing between top-level blocks.
    public var blockSpacing: CGFloat

    public init(
        headingFont: @Sendable @escaping (Int) -> Font,
        headingColor: Color,
        bodyFont: Font,
        bodyColor: Color,
        codeFont: Font,
        codeBackground: Color,
        codeForeground: Color,
        quoteBarColor: Color,
        quoteTextColor: Color,
        linkColor: Color,
        blockSpacing: CGFloat
    ) {
        self.headingFont = headingFont
        self.headingColor = headingColor
        self.bodyFont = bodyFont
        self.bodyColor = bodyColor
        self.codeFont = codeFont
        self.codeBackground = codeBackground
        self.codeForeground = codeForeground
        self.quoteBarColor = quoteBarColor
        self.quoteTextColor = quoteTextColor
        self.linkColor = linkColor
        self.blockSpacing = blockSpacing
    }
}

// MARK: - Environment

struct MarkdownThemeKey: EnvironmentKey {
    typealias Value = MarkdownTheme
    static let defaultValue = MarkdownTheme.default
}

extension EnvironmentValues {
    var markdownTheme: MarkdownTheme {
        get { self[MarkdownThemeKey.self] }
        set { self[MarkdownThemeKey.self] = newValue }
    }
}

extension View {
    /// Applies a `MarkdownTheme` to all `MarkdownView` and `MarkdownLabel` instances in the view hierarchy.
    public func markdownTheme(_ theme: MarkdownTheme) -> some View {
        environment(\.markdownTheme, theme)
    }
}
