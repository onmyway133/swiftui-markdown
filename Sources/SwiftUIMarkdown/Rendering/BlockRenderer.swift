import Foundation
import SwiftUI

/// Renders a list of `BlockGroup` values as a vertical stack of block views.
struct BlockRenderer: View {
    let groups: [BlockGroup]

    @Environment(\.markdownTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.blockSpacing) {
            ForEach(groups) { group in
                blockView(for: group)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func blockView(for group: BlockGroup) -> some View {
        switch group.kind {
        case .heading(let level):
            HeadingBlockView(group: group, level: level)
        case .paragraph:
            ParagraphBlockView(group: group)
        case .listItem(let ordinal, let depth, let ordered):
            ListBlockView(group: group, ordinal: ordinal, depth: depth, ordered: ordered)
        case .codeBlock(let language):
            CodeBlockView(group: group, language: language)
        case .blockQuote:
            QuoteBlockView(group: group)
        case .table(let table):
            TableBlockView(table: table)
        case .image(let url, let altText):
            ImageBlockView(url: url, altText: altText)
        case .thematicBreak:
            DividerBlockView()
        }
    }
}
