import SwiftUI

extension MarkdownTheme {
    /// System-default theme with dynamic type and adaptive colors.
    public static let `default` = MarkdownTheme(
        headingFont: { level in
            switch level {
            case 1: .system(size: 28, weight: .bold)
            case 2: .system(size: 22, weight: .bold)
            case 3: .system(size: 18, weight: .semibold)
            case 4: .system(size: 16, weight: .semibold)
            case 5: .system(size: 14, weight: .medium)
            default: .system(size: 13, weight: .medium)
            }
        },
        headingColor: .primary,
        bodyFont: .body,
        bodyColor: .primary,
        codeFont: .system(.body, design: .monospaced),
        codeBackground: Color(white: 0.95),
        codeForeground: Color(red: 0.76, green: 0.12, blue: 0.38),
        quoteBarColor: Color(white: 0.80),
        quoteTextColor: .secondary,
        linkColor: .accentColor,
        blockSpacing: 12
    )

    /// GitHub-inspired theme with tighter spacing and familiar code colors.
    public static let github = MarkdownTheme(
        headingFont: { level in
            switch level {
            case 1: .system(size: 26, weight: .heavy)
            case 2: .system(size: 20, weight: .bold)
            case 3: .system(size: 16, weight: .semibold)
            case 4: .system(size: 15, weight: .semibold)
            case 5: .system(size: 14, weight: .medium)
            default: .system(size: 13, weight: .medium)
            }
        },
        headingColor: Color(red: 0.09, green: 0.09, blue: 0.09),
        bodyFont: .system(size: 15),
        bodyColor: Color(red: 0.18, green: 0.18, blue: 0.18),
        codeFont: .system(size: 13, design: .monospaced),
        codeBackground: Color(red: 0.94, green: 0.95, blue: 0.96),
        codeForeground: Color(red: 0.49, green: 0.06, blue: 0.44),
        quoteBarColor: Color(red: 0.82, green: 0.84, blue: 0.87),
        quoteTextColor: Color(red: 0.40, green: 0.43, blue: 0.47),
        linkColor: Color(red: 0.02, green: 0.36, blue: 0.73),
        blockSpacing: 8
    )
}
