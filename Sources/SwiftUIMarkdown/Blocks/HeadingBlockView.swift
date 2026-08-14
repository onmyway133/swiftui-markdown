import SwiftUI

struct HeadingBlockView: View {
    let group: BlockGroup
    let level: Int

    @Environment(\.markdownTheme) private var theme

    var body: some View {
        theme.inlineText(from: group.content)
            .font(theme.headingFont(level))
            .foregroundColor(theme.headingColor)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, level == 1 ? 4 : 2)
    }
}
