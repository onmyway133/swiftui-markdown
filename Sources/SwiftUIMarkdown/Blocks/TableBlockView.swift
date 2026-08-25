import SwiftUI

/// Renders a GFM-style table assembled during parsing into a single `BlockGroup.Table` value.
///
/// Column count and alignment always come from `table.columns`; every row's `cells` array is
/// already padded/truncated to `columns.count` by the parser, so this view never needs to guard
/// against ragged rows itself.
struct TableBlockView: View {
    let table: BlockGroup.Table

    @Environment(\.markdownTheme) private var theme

    var body: some View {
        if table.columns.isEmpty {
            EmptyView()
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                grid
                    .background(theme.tableBorderColor)
                    .clipShape(RoundedRectangle(cornerRadius: theme.tableCornerRadius))
            }
        }
    }

    private var grid: some View {
        Grid(alignment: .topLeading, horizontalSpacing: 1, verticalSpacing: 1) {
            GridRow {
                ForEach(Array(table.columns.enumerated()), id: \.offset) { _, column in
                    cellView(column.header, alignment: column.alignment, isHeader: true, background: theme.tableHeaderBackground)
                        .accessibilityAddTraits(.isHeader)
                }
            }
            .accessibilityElement(children: .combine)

            ForEach(table.rows) { row in
                GridRow {
                    ForEach(Array(zip(table.columns, row.cells).enumerated()), id: \.offset) { _, pair in
                        let (column, cell) = pair
                        cellView(
                            cell,
                            alignment: column.alignment,
                            isHeader: false,
                            background: row.id.isMultiple(of: 2) ? theme.tableRowAlternateBackground : Color.clear
                        )
                        .accessibilityLabel(Text(column.header) + Text(": ") + Text(cell))
                    }
                }
                .accessibilityElement(children: .combine)
            }
        }
    }

    @ViewBuilder
    private func cellView(
        _ content: AttributedString,
        alignment: PresentationIntent.TableColumn.Alignment,
        isHeader: Bool,
        background: Color
    ) -> some View {
        theme.inlineText(from: content)
            .font(isHeader ? theme.bodyFont.bold() : theme.bodyFont)
            .foregroundColor(theme.bodyColor)
            .multilineTextAlignment(textAlignment(for: alignment))
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .frame(minWidth: theme.tableMinColumnWidth, maxWidth: .infinity, alignment: frameAlignment(for: alignment))
            .background(background)
    }

    private func textAlignment(for alignment: PresentationIntent.TableColumn.Alignment) -> TextAlignment {
        switch alignment {
        case .left:
            .leading
        case .center:
            .center
        case .right:
            .trailing
        default:
            .leading
        }
    }

    private func frameAlignment(for alignment: PresentationIntent.TableColumn.Alignment) -> Alignment {
        switch alignment {
        case .left:
            .topLeading
        case .center:
            .top
        case .right:
            .topTrailing
        default:
            .topLeading
        }
    }
}

extension Font {
    func bold() -> Font {
        weight(.bold)
    }
}
