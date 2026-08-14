/// SwiftUIMarkdown — A zero-dependency SwiftUI markdown renderer.
///
/// ## Overview
///
/// - ``MarkdownView``: Renders a full markdown document with block-level structure.
/// - ``MarkdownLabel``: Renders inline markdown as a styled `Text`.
/// - ``MarkdownTheme``: Controls all visual styling. Apply via `.markdownTheme(_:)`.
///
/// ## Quick Start
///
/// ```swift
/// import SwiftUIMarkdown
///
/// struct ContentView: View {
///     var body: some View {
///         ScrollView {
///             MarkdownView(myMarkdownString)
///                 .markdownTheme(.github)
///                 .padding()
///         }
///     }
/// }
/// ```
@_exported import struct SwiftUI.Color
@_exported import struct SwiftUI.Font
