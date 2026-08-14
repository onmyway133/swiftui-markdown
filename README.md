# SwiftUIMarkdown

A zero-dependency SwiftUI markdown renderer for iOS 18, macOS 15, and beyond. Built on Foundation's `AttributedString` with `PresentationIntent` run-walking — no third-party parsers, no heavyweight abstractions.

[![Swift 6](https://img.shields.io/badge/Swift-6.0-orange)](https://swift.org)
[![iOS 18+](https://img.shields.io/badge/iOS-18+-blue)](https://developer.apple.com/ios/)
[![macOS 15+](https://img.shields.io/badge/macOS-15+-blue)](https://developer.apple.com/macos/)
[![No Dependencies](https://img.shields.io/badge/dependencies-none-brightgreen)]()

<p align="center">
  <img src="screenshots/1.png" width="260" alt="All block types" />
  <img src="screenshots/2.png" width="260" alt="Default vs GitHub theme" />
  <img src="screenshots/3.png" width="260" alt="Live editor" />
</p>

---

## Features

- **Full block-level rendering** — headings H1–H6, paragraphs, ordered and unordered lists, code blocks, block quotes, tables, thematic breaks
- **Inline formatting** — bold, italic, strikethrough, inline code, links
- **Zero dependencies** — built entirely on Foundation and SwiftUI
- **Simple theming** — one `MarkdownTheme` struct, no protocol hierarchies
- **Swift 6 strict concurrency** — fully `Sendable`, safe across actors
- **Interactive playground** — live editor + theme comparison built in

---

## Quick Start

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/onmyway133/swiftui-markdown", from: "1.0.0"),
],
```

Render markdown:

```swift
import SwiftUIMarkdown

struct ContentView: View {
    var body: some View {
        ScrollView {
            MarkdownView("""
            # Hello from SwiftUIMarkdown

            Render **bold**, *italic*, `code`, and [links](https://github.com/onmyway133).

            > Simple. Zero dependencies. Swift 6.
            """)
            .padding()
        }
    }
}
```

Inline-only text:

```swift
MarkdownLabel("Download the **latest** version [here](https://example.com).")
```

---

## Block Type Support

| Block | Syntax | Notes |
|-------|--------|-------|
| Heading | `# H1` … `###### H6` | Levels 1–6 |
| Paragraph | Plain text | Inline formatting supported |
| Unordered list | `- item` | Nested via indentation |
| Ordered list | `1. item` | Ordinal labels |
| Code block | ` ```lang ` | Optional language caption |
| Block quote | `> text` | Left bar accent |
| Table | GFM pipe syntax | Header row bolded |
| Thematic break | `---` | Standard divider |
| **Inline bold** | `**text**` | |
| **Inline italic** | `*text*` | |
| **Inline code** | `` `code` `` | Themed color |
| **Inline link** | `[text](url)` | Accent color |
| **Strikethrough** | `~~text~~` | |

---

## Theming

Apply a built-in preset:

```swift
MarkdownView(markdown)
    .markdownTheme(.github)
```

Customize by copy-and-modifying a preset:

```swift
var theme = MarkdownTheme.default
theme.headingColor = .purple
theme.quoteBarColor = .purple
theme.linkColor = .orange
theme.blockSpacing = 16

MarkdownView(markdown)
    .markdownTheme(theme)
```

`MarkdownTheme` properties:

| Property | Type | Description |
|----------|------|-------------|
| `headingFont` | `(Int) -> Font` | Font for heading levels 1–6 |
| `headingColor` | `Color` | Heading text color |
| `bodyFont` | `Font` | Paragraph font |
| `bodyColor` | `Color` | Paragraph text color |
| `codeFont` | `Font` | Monospaced font for code |
| `codeBackground` | `Color` | Code block background fill |
| `codeForeground` | `Color` | Code text and inline code color |
| `quoteBarColor` | `Color` | Left bar color for block quotes |
| `quoteTextColor` | `Color` | Block quote text color |
| `linkColor` | `Color` | Hyperlink color |
| `blockSpacing` | `CGFloat` | Vertical gap between blocks |

---

## Example App

An Xcode project is included in `Examples/MarkdownPreview/`. It contains a three-tab iOS app:

- **Blocks** — all supported block types rendered with the default theme
- **Themes** — side-by-side comparison of `.default` and `.github`
- **Editor** — live markdown editor with real-time preview

Open it directly:

```sh
open Examples/MarkdownPreview/MarkdownPreview.xcodeproj
```

The project references `SwiftUIMarkdown` as a local package (no network required). Each view in `ContentView.swift` also has `#Preview` macros for instant canvas rendering.

---

## Architecture

```
MarkdownView(markdown)
      │
      ▼  AttributedString(markdown:, options: .full)
      │
      ▼  attrStr.blockGroups()       ← walks runs, groups by PresentationIntent identity
      │
      ▼  BlockRenderer               ← VStack dispatching on BlockGroup.Kind
      │
      ├─ HeadingBlockView            ← InlineRenderer.text() + themed font
      ├─ ParagraphBlockView          ← InlineRenderer.text() + body style
      ├─ ListBlockView               ← HStack(bullet, text) + depth indent
      ├─ CodeBlockView               ← ScrollView + monospaced + language caption
      ├─ QuoteBlockView              ← HStack(bar, text)
      ├─ TableBlockView              ← Grid + GridRow per row
      └─ DividerBlockView            ← Divider()
```

Inline formatting (`bold`, `italic`, `code`, `link`) is handled inside `InlineRenderer`, which iterates `AttributedString.runs` and applies theme overrides on top of what `Text(AttributedString)` already renders natively.

---

## Requirements

- Swift 6.0+
- iOS 18+ / macOS 15+ / tvOS 18+ / watchOS 11+ / visionOS 2+

---

## License

MIT © [onmyway133](https://github.com/onmyway133)
