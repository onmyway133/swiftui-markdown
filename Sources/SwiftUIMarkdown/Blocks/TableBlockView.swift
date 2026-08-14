import SwiftUI

/// Renders a GFM-style table from the block groups produced for a single table.
///
/// The groups list passed here is the full document group list; the view extracts
/// header, row, and cell groups that belong to this table's subtree.
struct TableBlockView: View {
    let groups: [BlockGroup]

    @Environment(\.markdownTheme) private var theme

    var body: some View {
        let rows = tableRows()
        if rows.isEmpty { return AnyView(EmptyView()) }
        return AnyView(
            Grid(alignment: .topLeading, horizontalSpacing: 1, verticalSpacing: 1) {
                ForEach(Array(rows.enumerated()), id: \.offset) { rowIndex, cells in
                    GridRow {
                        ForEach(Array(cells.enumerated()), id: \.offset) { _, cell in
                            theme.inlineText(from: cell.content)
                                .font(rowIndex == 0 ? theme.bodyFont.bold() : theme.bodyFont)
                                .foregroundColor(theme.bodyColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(rowIndex == 0
                                    ? theme.codeBackground
                                    : (rowIndex % 2 == 0
                                        ? theme.codeBackground.opacity(0.4)
                                        : Color.clear)
                                )
                        }
                    }
                }
            }
            .background(theme.quoteBarColor.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        )
    }

    private func tableRows() -> [[BlockGroup]] {
        var rowMap: [Int: [BlockGroup]] = [:]
        var rowOrder: [Int] = []

        for group in groups {
            switch group.kind {
            case .tableHeaderRow:
                if rowMap[-1] == nil {
                    rowOrder.append(-1)
                    rowMap[-1] = []
                }
            case .tableRow(let index):
                if rowMap[index] == nil {
                    rowOrder.append(index)
                    rowMap[index] = []
                }
            case .tableCell:
                if let lastKey = rowOrder.last {
                    rowMap[lastKey]?.append(group)
                }
            default:
                break
            }
        }

        return rowOrder.compactMap { rowMap[$0] }
    }
}

extension Font {
    func bold() -> Font {
        weight(.bold)
    }
}
