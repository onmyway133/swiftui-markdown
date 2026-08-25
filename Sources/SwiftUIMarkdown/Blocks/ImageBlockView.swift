import SwiftUI

struct ImageBlockView: View {
    let url: URL
    let altText: String

    @Environment(\.markdownTheme) private var theme

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: theme.imageMaxHeight)
            case .failure:
                fallback
            case .empty:
                fallback
            @unknown default:
                fallback
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var fallback: some View {
        if altText.isEmpty {
            EmptyView()
        } else {
            Text(altText)
                .font(theme.bodyFont)
                .foregroundColor(theme.bodyColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
