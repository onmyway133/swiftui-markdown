import SwiftUI

struct ListBlockView: View {
    let group: BlockGroup
    let ordinal: Int
    let depth: Int
    let ordered: Bool

    @Environment(\.markdownTheme) private var theme

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            markerText
                .font(theme.bodyFont)
                .foregroundColor(theme.bodyColor)
                .frame(width: 20, alignment: ordered ? .trailing : .center)
            theme.inlineText(from: group.content)
                .font(theme.bodyFont)
                .foregroundColor(theme.bodyColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.leading, CGFloat(depth) * 20)
    }

    private var markerText: Text {
        ordered ? Text("\(ordinal).") : Text("•")
    }
}
