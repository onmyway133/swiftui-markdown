import Foundation
import Testing
@testable import SwiftUIMarkdown

@Suite("BlockGroup")
struct BlockGroupTests {
    @Test("heading produces correct level")
    func headingLevel() throws {
        let attrStr = try AttributedString(
            markdown: "# Hello",
            options: .init(interpretedSyntax: .full)
        )
        let groups = attrStr.blockGroups()
        let heading = try #require(groups.first)
        guard case .heading(let level) = heading.kind else {
            Issue.record("Expected heading, got \(heading.kind)")
            return
        }
        #expect(level == 1)
    }

    @Test("paragraph is recognized")
    func paragraph() throws {
        let attrStr = try AttributedString(
            markdown: "Hello, world.",
            options: .init(interpretedSyntax: .full)
        )
        let groups = attrStr.blockGroups()
        #expect(groups.first.map { if case .paragraph = $0.kind { true } else { false } } == true)
    }

    @Test("unordered list produces two list items")
    func unorderedList() throws {
        let attrStr = try AttributedString(
            markdown: "- Apple\n- Banana",
            options: .init(interpretedSyntax: .full)
        )
        let groups = attrStr.blockGroups()
        let items = groups.filter {
            if case .listItem = $0.kind { return true }
            return false
        }
        #expect(items.count == 2)
        for item in items {
            guard case .listItem(_, _, let ordered) = item.kind else { continue }
            #expect(ordered == false)
        }
    }

    @Test("ordered list items have correct ordinals")
    func orderedList() throws {
        let attrStr = try AttributedString(
            markdown: "1. First\n2. Second\n3. Third",
            options: .init(interpretedSyntax: .full)
        )
        let groups = attrStr.blockGroups()
        let items = groups.filter {
            if case .listItem = $0.kind { return true }
            return false
        }
        #expect(items.count == 3)
        for item in items {
            guard case .listItem(_, _, let ordered) = item.kind else { continue }
            #expect(ordered == true)
        }
        let ordinals = items.compactMap { group -> Int? in
            guard case .listItem(let o, _, _) = group.kind else { return nil }
            return o
        }
        #expect(ordinals == [1, 2, 3])
    }

    @Test("code block captures language hint")
    func codeBlockLanguage() throws {
        let attrStr = try AttributedString(
            markdown: "```swift\nlet x = 1\n```",
            options: .init(interpretedSyntax: .full)
        )
        let groups = attrStr.blockGroups()
        let codeBlock = groups.first {
            if case .codeBlock = $0.kind { return true }
            return false
        }
        guard let codeBlock else {
            Issue.record("No code block found")
            return
        }
        guard case .codeBlock(let language) = codeBlock.kind else { return }
        #expect(language == "swift")
    }

    @Test("multiple block types in sequence")
    func multipleBlockTypes() throws {
        let attrStr = try AttributedString(
            markdown: "# Title\n\nA paragraph.\n\n- Item",
            options: .init(interpretedSyntax: .full)
        )
        let groups = attrStr.blockGroups()
        let kinds = groups.map(\.kind)
        let hasHeading = kinds.contains { if case .heading = $0 { return true }; return false }
        let hasParagraph = kinds.contains { if case .paragraph = $0 { return true }; return false }
        let hasListItem = kinds.contains { if case .listItem = $0 { return true }; return false }
        #expect(hasHeading)
        #expect(hasParagraph)
        #expect(hasListItem)
    }
}
