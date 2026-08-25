import Foundation

/// A logical block of rendered markdown content, derived from `AttributedString` runs
/// grouped by their `PresentationIntent` identity.
struct BlockGroup: Identifiable, Sendable {
    enum Kind: Sendable {
        case heading(level: Int)
        case paragraph
        case listItem(ordinal: Int, depth: Int, ordered: Bool)
        case codeBlock(language: String?)
        case blockQuote
        case table(Table)
        case image(url: URL, altText: String)
        case thematicBreak
    }

    /// A GFM table assembled from its header row, columns, and data rows.
    struct Table: Sendable {
        struct Column: Sendable {
            let header: AttributedString
            let alignment: PresentationIntent.TableColumn.Alignment
        }

        struct Row: Identifiable, Sendable {
            let id: Int
            let cells: [AttributedString]
        }

        let columns: [Column]
        let rows: [Row]
    }

    let id: Int
    var kind: Kind
    var content: AttributedString
}

extension AttributedString {
    /// Segments the attributed string into `BlockGroup` values by walking runs and grouping
    /// contiguous text that shares the same representative `PresentationIntent` identity.
    ///
    /// The "representative" component is the most specific structural node — `listItem`,
    /// `tableCell`, `codeBlock`, `header`, etc. — rather than always using the innermost
    /// `paragraph` wrapper that Foundation appends inside block containers.
    ///
    /// Table cells are diverted into a `TableAccumulator` keyed by the table's own identity
    /// so the table's column definitions (from `PresentationIntent.Kind.table`) remain the
    /// single source of truth for column count, rather than being inferred from however many
    /// cell runs happen to appear.
    func blockGroups() -> [BlockGroup] {
        var groups: [Int: BlockGroup] = [:]
        var order: [Int] = []
        var tableAccumulators: [Int: TableAccumulator] = [:]

        for run in runs {
            guard let intent = run.presentationIntent else { continue }
            let components = intent.components
            let slice = AttributedString(self[run.range])

            if let cellInfo = components.tableCellInfo() {
                if tableAccumulators[cellInfo.tableIdentity] == nil {
                    tableAccumulators[cellInfo.tableIdentity] = TableAccumulator(columns: cellInfo.columns)
                    order.append(cellInfo.tableIdentity)
                }
                if cellInfo.isHeader {
                    tableAccumulators[cellInfo.tableIdentity]!.appendHeaderCell(slice, column: cellInfo.columnIndex)
                } else {
                    tableAccumulators[cellInfo.tableIdentity]!.appendRowCell(
                        slice,
                        row: cellInfo.rowIndex,
                        column: cellInfo.columnIndex
                    )
                }
                continue
            }

            guard let representative = components.representativeComponent() else { continue }
            let identity = representative.identity

            if groups[identity] != nil {
                if case .image = groups[identity]!.kind {
                    groups[identity]!.kind = .paragraph
                }
                groups[identity]!.content += slice
                continue
            }

            if representative.kind == .paragraph, let imageURL = run.imageURL {
                let altText = String(slice.characters).replacing("\u{FFFC}", with: "")
                groups[identity] = BlockGroup(
                    id: identity,
                    kind: .image(url: imageURL, altText: altText),
                    content: slice
                )
            } else {
                let kind = BlockGroup.Kind(
                    from: representative.kind,
                    components: components,
                    indentationLevel: intent.indentationLevel
                )
                groups[identity] = BlockGroup(id: identity, kind: kind, content: slice)
            }
            order.append(identity)
        }

        for (identity, accumulator) in tableAccumulators {
            groups[identity] = BlockGroup(id: identity, kind: .table(accumulator.finalize()), content: AttributedString())
        }

        return order.compactMap { groups[$0] }
    }
}

/// Where a run sits within a table: which table, its column definitions, and its row/column position.
private struct TableCellInfo {
    let tableIdentity: Int
    let columns: [PresentationIntent.TableColumn]
    let isHeader: Bool
    let rowIndex: Int
    let columnIndex: Int
}

/// Accumulates header and data cells for a single table, keyed by column and row index, so the
/// final `BlockGroup.Table` always has exactly `columns.count` cells per row regardless of how
/// many cell runs Foundation actually emitted for that row.
private struct TableAccumulator {
    let columns: [PresentationIntent.TableColumn]
    private var headerCells: [Int: AttributedString] = [:]
    private var rowCells: [Int: [Int: AttributedString]] = [:]
    private var rowOrder: [Int] = []

    init(columns: [PresentationIntent.TableColumn]) {
        self.columns = columns
    }

    mutating func appendHeaderCell(_ text: AttributedString, column: Int) {
        headerCells[column, default: AttributedString()] += text
    }

    mutating func appendRowCell(_ text: AttributedString, row: Int, column: Int) {
        if rowCells[row] == nil {
            rowCells[row] = [:]
            rowOrder.append(row)
        }
        rowCells[row]![column, default: AttributedString()] += text
    }

    func finalize() -> BlockGroup.Table {
        let tableColumns = columns.enumerated().map { index, column in
            BlockGroup.Table.Column(
                header: headerCells[index] ?? AttributedString(),
                alignment: column.alignment
            )
        }
        let tableRows = rowOrder.sorted().map { rowIndex in
            let cells = rowCells[rowIndex] ?? [:]
            let orderedCells = (0..<tableColumns.count).map { cells[$0] ?? AttributedString() }
            return BlockGroup.Table.Row(id: rowIndex, cells: orderedCells)
        }
        return BlockGroup.Table(columns: tableColumns, rows: tableRows)
    }
}

private extension Array where Element == PresentationIntent.IntentType {
    /// Returns the component that best represents the block boundary for this intent stack.
    ///
    /// Foundation's components array is innermost-first (leaf at index 0, root at the end).
    /// We walk from first (innermost) and return the most specific structural node so
    /// containers like `listItem`, `tableCell`, `codeBlock`, and `header` form separate
    /// groups rather than collapsing into bare paragraphs.
    func representativeComponent() -> PresentationIntent.IntentType? {
        for component in self {
            switch component.kind {
            case .header, .codeBlock, .thematicBreak, .blockQuote,
                 .listItem, .tableCell, .tableHeaderRow, .tableRow:
                return component
            default:
                break
            }
        }
        return first
    }

    /// Returns `true` when this component stack has an `orderedList` parent for the given `listItem`.
    func isOrderedList(for listItemIdentity: Int) -> Bool {
        // Components are innermost-first, so the parent container is at a higher index.
        guard let listItemIndex = firstIndex(where: { $0.identity == listItemIdentity }) else {
            return false
        }
        let parentIndex = index(after: listItemIndex)
        guard parentIndex < endIndex else { return false }
        if case .orderedList = self[parentIndex].kind { return true }
        return false
    }

    /// Returns the table cell position (table, column, row, header-ness) for this intent stack,
    /// or `nil` when the stack doesn't describe a table cell.
    func tableCellInfo() -> TableCellInfo? {
        guard let cellComponent = first(where: { if case .tableCell = $0.kind { true } else { false } }),
              case .tableCell(let columnIndex) = cellComponent.kind,
              let rowComponent = first(where: {
                  switch $0.kind {
                  case .tableHeaderRow, .tableRow: true
                  default: false
                  }
              }),
              let tableComponent = first(where: { if case .table = $0.kind { true } else { false } }),
              case .table(let columns) = tableComponent.kind
        else {
            return nil
        }

        switch rowComponent.kind {
        case .tableHeaderRow:
            return TableCellInfo(
                tableIdentity: tableComponent.identity,
                columns: columns,
                isHeader: true,
                rowIndex: -1,
                columnIndex: columnIndex
            )
        case .tableRow(let rowIndex):
            return TableCellInfo(
                tableIdentity: tableComponent.identity,
                columns: columns,
                isHeader: false,
                rowIndex: rowIndex,
                columnIndex: columnIndex
            )
        default:
            return nil
        }
    }
}

private extension BlockGroup.Kind {
    init(
        from kind: PresentationIntent.Kind,
        components: [PresentationIntent.IntentType],
        indentationLevel: Int
    ) {
        switch kind {
        case .header(let level):
            self = .heading(level: level)
        case .paragraph:
            self = .paragraph
        case .listItem(let ordinal):
            let representative = components.representativeComponent()
            let ordered = representative.map { components.isOrderedList(for: $0.identity) } ?? false
            self = .listItem(ordinal: ordinal, depth: indentationLevel, ordered: ordered)
        case .codeBlock(let languageHint):
            self = .codeBlock(language: languageHint)
        case .blockQuote:
            self = .blockQuote
        case .thematicBreak:
            self = .thematicBreak
        default:
            self = .paragraph
        }
    }
}
