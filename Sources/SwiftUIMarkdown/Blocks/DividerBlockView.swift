import SwiftUI

struct DividerBlockView: View {
    @Environment(\.markdownTheme) private var theme

    var body: some View {
        Divider()
            .padding(.vertical, 4)
    }
}
