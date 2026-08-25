import Foundation
import Testing
@testable import SwiftUIMarkdown

@Suite("ImageBlock")
struct ImageBlockTests {
    @Test("standalone image produces an image block with url and alt text")
    func standaloneImage() throws {
        let attrStr = try AttributedString(
            markdown: "![A cat](https://example.com/cat.png)",
            options: .init(interpretedSyntax: .full)
        )
        let groups = attrStr.blockGroups()
        let image = try #require(groups.first)
        guard case .image(let url, let altText) = image.kind else {
            Issue.record("Expected image, got \(image.kind)")
            return
        }
        #expect(url == URL(string: "https://example.com/cat.png"))
        #expect(altText == "A cat")
    }

    @Test("image title is dropped, only alt text and url survive")
    func imageTitleDropped() throws {
        let attrStr = try AttributedString(
            markdown: #"![A cat](https://example.com/cat.png "A cute cat")"#,
            options: .init(interpretedSyntax: .full)
        )
        let groups = attrStr.blockGroups()
        let image = try #require(groups.first)
        guard case .image(let url, let altText) = image.kind else {
            Issue.record("Expected image, got \(image.kind)")
            return
        }
        #expect(url == URL(string: "https://example.com/cat.png"))
        #expect(altText == "A cat")
    }

    @Test("image with empty alt text still produces an image block")
    func emptyAltText() throws {
        let attrStr = try AttributedString(
            markdown: "![](https://example.com/cat.png)",
            options: .init(interpretedSyntax: .full)
        )
        let groups = attrStr.blockGroups()
        let image = try #require(groups.first)
        guard case .image(let url, let altText) = image.kind else {
            Issue.record("Expected image, got \(image.kind)")
            return
        }
        #expect(url == URL(string: "https://example.com/cat.png"))
        #expect(altText.isEmpty)
    }

    @Test("reference-style image resolves to the referenced url")
    func referenceStyleImage() throws {
        let attrStr = try AttributedString(
            markdown: "![A cat][cat-ref]\n\n[cat-ref]: https://example.com/cat.png",
            options: .init(interpretedSyntax: .full)
        )
        let groups = attrStr.blockGroups()
        let image = try #require(groups.first {
            if case .image = $0.kind { return true }
            return false
        })
        guard case .image(let url, let altText) = image.kind else {
            Issue.record("Expected image, got \(image.kind)")
            return
        }
        #expect(url == URL(string: "https://example.com/cat.png"))
        #expect(altText == "A cat")
    }

    @Test("shorthand reference-style image resolves to the referenced url")
    func shorthandReferenceStyleImage() throws {
        let attrStr = try AttributedString(
            markdown: "![cat-ref]\n\n[cat-ref]: https://example.com/cat.png",
            options: .init(interpretedSyntax: .full)
        )
        let groups = attrStr.blockGroups()
        let image = try #require(groups.first {
            if case .image = $0.kind { return true }
            return false
        })
        guard case .image(let url, _) = image.kind else {
            Issue.record("Expected image, got \(image.kind)")
            return
        }
        #expect(url == URL(string: "https://example.com/cat.png"))
    }

    @Test("image inline mid-paragraph is demoted back to a paragraph")
    func inlineImageDemotedToParagraph() throws {
        let attrStr = try AttributedString(
            markdown: "Look at this ![cat](https://example.com/cat.png) it is cute.",
            options: .init(interpretedSyntax: .full)
        )
        let groups = attrStr.blockGroups()
        #expect(groups.count == 1)
        guard case .paragraph = groups[0].kind else {
            Issue.record("Expected paragraph, got \(groups[0].kind)")
            return
        }
    }

    @Test("image nested in a list item does not produce a standalone image block")
    func imageInsideListItem() throws {
        let attrStr = try AttributedString(
            markdown: "- ![cat](https://example.com/cat.png)",
            options: .init(interpretedSyntax: .full)
        )
        let groups = attrStr.blockGroups()
        let listItem = try #require(groups.first)
        guard case .listItem = listItem.kind else {
            Issue.record("Expected listItem, got \(listItem.kind)")
            return
        }
    }

    @Test("image nested in a block quote does not produce a standalone image block")
    func imageInsideBlockQuote() throws {
        let attrStr = try AttributedString(
            markdown: "> ![cat](https://example.com/cat.png)",
            options: .init(interpretedSyntax: .full)
        )
        let groups = attrStr.blockGroups()
        let quote = try #require(groups.first)
        guard case .blockQuote = quote.kind else {
            Issue.record("Expected blockQuote, got \(quote.kind)")
            return
        }
    }

    @Test("image nested in a table cell does not produce a standalone image block")
    func imageInsideTableCell() throws {
        let attrStr = try AttributedString(
            markdown: "| A |\n| --- |\n| ![cat](https://example.com/cat.png) |",
            options: .init(interpretedSyntax: .full)
        )
        let groups = attrStr.blockGroups()
        let table = try #require(groups.first {
            if case .table = $0.kind { return true }
            return false
        })
        guard case .table = table.kind else {
            Issue.record("Expected table, got \(table.kind)")
            return
        }
        let hasStandaloneImage = groups.contains {
            if case .image = $0.kind { return true }
            return false
        }
        #expect(!hasStandaloneImage)
    }

    @Test("malformed image syntax does not crash and is not treated as an image")
    func malformedImageSyntax() throws {
        let attrStr = try AttributedString(
            markdown: "![cat](not a valid url",
            options: .init(interpretedSyntax: .full)
        )
        let groups = attrStr.blockGroups()
        let hasImage = groups.contains {
            if case .image = $0.kind { return true }
            return false
        }
        #expect(!hasImage)
    }

    @Test("ImageBlockView can be constructed without crashing")
    func imageBlockViewConstruction() throws {
        let view = ImageBlockView(url: URL(string: "https://example.com/cat.png")!, altText: "A cat")
        _ = view.body
    }
}
