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
        case table(columns: [PresentationIntent.TableColumn])
        case tableHeaderRow
        case tableRow(index: Int)
        case tableCell(column: Int)
        case thematicBreak
    }

    let id: Int
    let kind: Kind
    var content: AttributedString
}

extension AttributedString {
    /// Segments the attributed string into `BlockGroup` values by walking runs and grouping
    /// contiguous text that shares the same representative `PresentationIntent` identity.
    ///
    /// The "representative" component is the most specific structural node — `listItem`,
    /// `tableCell`, `codeBlock`, `header`, etc. — rather than always using the innermost
    /// `paragraph` wrapper that Foundation appends inside block containers.
    func blockGroups() -> [BlockGroup] {
        var groups: [Int: BlockGroup] = [:]
        var order: [Int] = []

        for run in runs {
            guard let intent = run.presentationIntent else { continue }
            let components = intent.components
            guard let representative = components.representativeComponent() else { continue }

            let identity = representative.identity
            let kind = BlockGroup.Kind(
                from: representative.kind,
                components: components,
                indentationLevel: intent.indentationLevel
            )

            let slice = self[run.range]
            if groups[identity] != nil {
                groups[identity]!.content += AttributedString(slice)
            } else {
                groups[identity] = BlockGroup(
                    id: identity,
                    kind: kind,
                    content: AttributedString(slice)
                )
                order.append(identity)
            }
        }

        return order.compactMap { groups[$0] }
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
        case .table(let columns):
            self = .table(columns: columns)
        case .tableHeaderRow:
            self = .tableHeaderRow
        case .tableRow(let rowIndex):
            self = .tableRow(index: rowIndex)
        case .tableCell(let columnIndex):
            self = .tableCell(column: columnIndex)
        case .thematicBreak:
            self = .thematicBreak
        default:
            self = .paragraph
        }
    }
}
