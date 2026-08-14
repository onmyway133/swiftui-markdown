import Foundation
import SwiftUI

/// Renders a markdown string as a full block-level document.
///
/// Supports headings, paragraphs, ordered and unordered lists, code blocks,
/// block quotes, tables, and thematic breaks. All styling is driven by the
/// ambient `MarkdownTheme`.
///
/// ```swift
/// MarkdownView("""
/// # Hello
/// This is **bold** and *italic* text.
/// """)
/// .markdownTheme(.github)
/// ```
public struct MarkdownView: View {
    private let markdown: String
    private let baseURL: URL?

    @State private var groups: [BlockGroup] = []

    public init(_ markdown: String, baseURL: URL? = nil) {
        self.markdown = markdown
        self.baseURL = baseURL
    }

    public var body: some View {
        BlockRenderer(groups: groups)
            .onChange(of: markdown, initial: true) { _, newValue in
                groups = Self.parse(newValue, baseURL: baseURL)
            }
    }

    private static func parse(_ markdown: String, baseURL: URL?) -> [BlockGroup] {
        let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .full)
        let attrStr = (try? AttributedString(markdown: markdown, options: options, baseURL: baseURL))
            ?? AttributedString(markdown)
        return attrStr.blockGroups()
    }
}

#if DEBUG
#Preview("Default Theme") {
    ScrollView {
        MarkdownView(sampleMarkdown)
            .padding()
    }
}

#Preview("GitHub Theme") {
    ScrollView {
        MarkdownView(sampleMarkdown)
            .markdownTheme(.github)
            .padding()
    }
}

private let sampleMarkdown = """
# Heading 1
## Heading 2
### Heading 3

A paragraph with **bold**, *italic*, and `inline code`.

- First item
- Second item
  - Nested item

1. Ordered first
2. Ordered second

> A blockquote with *emphasis*.

```swift
let greeting = "Hello, world"
print(greeting)
```

---

| Column A | Column B |
|----------|----------|
| Cell 1   | Cell 2   |
| Cell 3   | Cell 4   |
"""
#endif
