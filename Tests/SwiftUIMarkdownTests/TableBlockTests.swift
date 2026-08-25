import Foundation
import Testing
@testable import SwiftUIMarkdown

@Suite("TableBlock")
struct TableBlockTests {
    @Test("basic table produces correct columns and rows")
    func basicTable() throws {
        let attrStr = try AttributedString(
            markdown: "| A | B |\n| --- | --- |\n| 1 | 2 |\n| 3 | 4 |",
            options: .init(interpretedSyntax: .full)
        )
        let groups = attrStr.blockGroups()
        let group = try #require(groups.first)
        guard case .table(let table) = group.kind else {
            Issue.record("Expected table, got \(group.kind)")
            return
        }
        #expect(table.columns.count == 2)
        #expect(String(table.columns[0].header.characters) == "A")
        #expect(String(table.columns[1].header.characters) == "B")
        #expect(table.rows.count == 2)
        #expect(String(table.rows[0].cells[0].characters) == "1")
        #expect(String(table.rows[0].cells[1].characters) == "2")
        #expect(String(table.rows[1].cells[0].characters) == "3")
        #expect(String(table.rows[1].cells[1].characters) == "4")
    }

    @Test("left alignment marker produces left alignment")
    func leftAlignment() throws {
        let attrStr = try AttributedString(
            markdown: "| A |\n| :--- |\n| 1 |",
            options: .init(interpretedSyntax: .full)
        )
        let groups = attrStr.blockGroups()
        guard case .table(let table) = try #require(groups.first).kind else {
            Issue.record("Expected table")
            return
        }
        #expect(table.columns[0].alignment == .left)
    }

    @Test("center alignment marker produces center alignment")
    func centerAlignment() throws {
        let attrStr = try AttributedString(
            markdown: "| A |\n| :---: |\n| 1 |",
            options: .init(interpretedSyntax: .full)
        )
        let groups = attrStr.blockGroups()
        guard case .table(let table) = try #require(groups.first).kind else {
            Issue.record("Expected table")
            return
        }
        #expect(table.columns[0].alignment == .center)
    }

    @Test("right alignment marker produces right alignment")
    func rightAlignment() throws {
        let attrStr = try AttributedString(
            markdown: "| A |\n| ---: |\n| 1 |",
            options: .init(interpretedSyntax: .full)
        )
        let groups = attrStr.blockGroups()
        guard case .table(let table) = try #require(groups.first).kind else {
            Issue.record("Expected table")
            return
        }
        #expect(table.columns[0].alignment == .right)
    }

    @Test("unmarked alignment defaults to left")
    func unmarkedAlignmentDefaultsToLeft() throws {
        let attrStr = try AttributedString(
            markdown: "| A |\n| --- |\n| 1 |",
            options: .init(interpretedSyntax: .full)
        )
        let groups = attrStr.blockGroups()
        guard case .table(let table) = try #require(groups.first).kind else {
            Issue.record("Expected table")
            return
        }
        #expect(table.columns[0].alignment == .left)
    }

    @Test("single column table parses correctly")
    func singleColumnTable() throws {
        let attrStr = try AttributedString(
            markdown: "| A |\n| --- |\n| 1 |\n| 2 |",
            options: .init(interpretedSyntax: .full)
        )
        let groups = attrStr.blockGroups()
        guard case .table(let table) = try #require(groups.first).kind else {
            Issue.record("Expected table")
            return
        }
        #expect(table.columns.count == 1)
        #expect(table.rows.count == 2)
    }

    @Test("empty table body still produces a table with columns and no rows")
    func emptyTableBody() throws {
        let attrStr = try AttributedString(
            markdown: "| A | B |\n| --- | --- |\n",
            options: .init(interpretedSyntax: .full)
        )
        let groups = attrStr.blockGroups()
        guard case .table(let table) = try #require(groups.first).kind else {
            Issue.record("Expected table")
            return
        }
        #expect(table.columns.count == 2)
        #expect(table.rows.isEmpty)
    }

    @Test("ragged row with fewer cells is padded with empty cells")
    func raggedRowFewerCells() throws {
        let attrStr = try AttributedString(
            markdown: "| A | B | C |\n| --- | --- | --- |\n| 1 |",
            options: .init(interpretedSyntax: .full)
        )
        let groups = attrStr.blockGroups()
        guard case .table(let table) = try #require(groups.first).kind else {
            Issue.record("Expected table")
            return
        }
        #expect(table.columns.count == 3)
        let row = try #require(table.rows.first)
        #expect(row.cells.count == 3)
        #expect(String(row.cells[0].characters) == "1")
        #expect(String(row.cells[1].characters).isEmpty)
        #expect(String(row.cells[2].characters).isEmpty)
    }

    @Test("ragged row with more cells than declared columns ignores the excess")
    func raggedRowMoreCells() throws {
        let attrStr = try AttributedString(
            markdown: "| A |\n| --- |\n| 1 | 2 | 3 |",
            options: .init(interpretedSyntax: .full)
        )
        let groups = attrStr.blockGroups()
        guard case .table(let table) = try #require(groups.first).kind else {
            Issue.record("Expected table")
            return
        }
        #expect(table.columns.count == 1)
        let row = try #require(table.rows.first)
        #expect(row.cells.count == 1)
        #expect(String(row.cells[0].characters) == "1")
    }

    @Test("multi-run cell content is concatenated into a single cell")
    func multiRunCellConcatenation() throws {
        let attrStr = try AttributedString(
            markdown: "| A |\n| --- |\n| **bold** plain |",
            options: .init(interpretedSyntax: .full)
        )
        let groups = attrStr.blockGroups()
        guard case .table(let table) = try #require(groups.first).kind else {
            Issue.record("Expected table")
            return
        }
        let cell = try #require(table.rows.first?.cells.first)
        #expect(String(cell.characters) == "bold plain")
    }

    @Test("multiple tables in one document remain separate")
    func multipleTablesInOneDocument() throws {
        let attrStr = try AttributedString(
            markdown: "| A |\n| --- |\n| 1 |\n\nSome text.\n\n| B |\n| --- |\n| 2 |",
            options: .init(interpretedSyntax: .full)
        )
        let groups = attrStr.blockGroups()
        let tables = groups.compactMap { group -> BlockGroup.Table? in
            guard case .table(let table) = group.kind else { return nil }
            return table
        }
        #expect(tables.count == 2)
        #expect(String(tables[0].columns[0].header.characters) == "A")
        #expect(String(tables[1].columns[0].header.characters) == "B")
    }

    @Test("TableBlockView can be constructed and rendered without crashing")
    func tableBlockViewConstruction() throws {
        let attrStr = try AttributedString(
            markdown: "| A | B |\n| --- | :---: |\n| 1 | 2 |",
            options: .init(interpretedSyntax: .full)
        )
        let groups = attrStr.blockGroups()
        guard case .table(let table) = try #require(groups.first).kind else {
            Issue.record("Expected table")
            return
        }
        let view = TableBlockView(table: table)
        _ = view.body
    }

    @Test("TableBlockView with an empty table renders without crashing")
    func emptyTableBlockViewConstruction() throws {
        let table = BlockGroup.Table(columns: [], rows: [])
        let view = TableBlockView(table: table)
        _ = view.body
    }
}
