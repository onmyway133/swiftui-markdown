import SwiftUI

struct ParagraphBlockView: View {
    let group: BlockGroup

    @Environment(\.markdownTheme) private var theme

    var body: some View {
        theme.inlineText(from: group.content)
            .font(theme.bodyFont)
            .foregroundColor(theme.bodyColor)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
