import SwiftUI
import SwiftUIMarkdown

struct ContentView: View {
    var body: some View {
        TabView {
            AllBlocksView()
                .tabItem { Label("Blocks", systemImage: "doc.text") }
            ThemeComparisonView()
                .tabItem { Label("Themes", systemImage: "paintpalette") }
            LiveEditorView()
                .tabItem { Label("Editor", systemImage: "pencil") }
        }
    }
}

// MARK: - All Blocks

struct AllBlocksView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                MarkdownView(fullSample)
                    .padding()
            }
            .navigationTitle("All Blocks")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Theme Comparison

struct ThemeComparisonView: View {
    private let sample = """
    # SwiftUIMarkdown

    A paragraph with **bold**, *italic*, `code`, and a [link](https://github.com/onmyway133).

    > A blockquote to compare the bar accent color.

    - Unordered item one
    - Unordered item two

    1. Ordered first
    2. Ordered second

    ```swift
    let answer = 42
    ```
    """

    var body: some View {
        NavigationStack {
            ScrollView {
                HStack(alignment: .top, spacing: 0) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Default")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                        MarkdownView(sample)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Divider()
                    VStack(alignment: .leading, spacing: 6) {
                        Text("GitHub")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                        MarkdownView(sample)
                            .markdownTheme(.github)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical)
            }
            .navigationTitle("Themes")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Live Editor

struct LiveEditorView: View {
    @State private var source = """
    # Live Preview

    Edit this text and the output updates in **real time**.

    - Item **one**
    - Item *two*

    > Try a blockquote

    ```swift
    print("Hello!")
    ```
    """

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TextEditor(text: $source)
                    .font(.system(.footnote, design: .monospaced))
                    .frame(maxHeight: .infinity)
                    .padding(8)
                Divider()
                ScrollView {
                    MarkdownView(source)
                        .padding()
                }
                .frame(maxHeight: .infinity)
            }
            .navigationTitle("Editor")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Sample

private let fullSample = """
# Heading 1
## Heading 2
### Heading 3
#### Heading 4

---

A paragraph with **bold**, *italic*, ~~strikethrough~~, `inline code`, and a [link](https://github.com/onmyway133).

Combine them: ***bold italic*** and **bold with `code`**.

---

Unordered list:

- First item
- Second item
- Third item

Ordered list:

1. Step one
2. Step two
3. Step three

---

> "Simplicity is the ultimate sophistication."
> — Leonardo da Vinci

---

```swift
struct Greeter {
    let name: String
    func greet() -> String { "Hello, \\(name)!" }
}
```

---

| Language | Typing  | Paradigm   |
|----------|---------|------------|
| Swift    | Static  | Multi      |
| Python   | Dynamic | Multi      |
| Haskell  | Static  | Functional |
"""

// MARK: - Previews

#Preview("Content View") {
    ContentView()
}

#Preview("All Blocks - Default") {
    ScrollView {
        MarkdownView(fullSample)
            .padding()
    }
}

#Preview("All Blocks - GitHub") {
    ScrollView {
        MarkdownView(fullSample)
            .markdownTheme(.github)
            .padding()
    }
}

#Preview("MarkdownLabel") {
    VStack(alignment: .leading, spacing: 10) {
        MarkdownLabel("**Bold** and *italic*")
        MarkdownLabel("`code` snippet")
        MarkdownLabel("~~strikethrough~~ text")
        MarkdownLabel("[onmyway133](https://github.com/onmyway133)")
        MarkdownLabel("Mix: **bold** and *italic* with `code`")
    }
    .padding()
}

#Preview("Custom Theme") {
    ScrollView {
        MarkdownView("""
        # Custom Theme

        A paragraph with a **custom** theme — `code`, *italic*, and [links](https://example.com).

        > Blockquote with purple bar.

        - Item one
        - Item two
        """)
        .markdownTheme({
            var theme = MarkdownTheme.default
            theme.headingColor = .purple
            theme.quoteBarColor = .purple
            theme.linkColor = .orange
            return theme
        }())
        .padding()
    }
}
