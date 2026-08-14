import SwiftUI

struct QuoteBlockView: View {
    let group: BlockGroup

    @Environment(\.markdownTheme) private var theme

    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(theme.quoteBarColor)
                .frame(width: 3)
            theme.inlineText(from: group.content)
                .font(theme.bodyFont)
                .foregroundColor(theme.quoteTextColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .clipShape(RoundedRectangle(cornerRadius: 2))
    }
}
