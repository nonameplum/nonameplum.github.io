import Foundation
import Plot
import Publish
import ReadTimePublishPlugin

extension Theme where Site == PlumBlog {
    static var blog: Self {
        Theme(
            htmlFactory: BlogHTMLFactory(),
            resourcePaths: Set(styleFiles.map { Path("css/\($0)") })
        )
    }
}

private let styleFiles = ["styles.css", "code.css"]
private let fonts = ["Fira Sans", "Fira Code", "Comfortaa"]

private func googleApisFontsURL() -> String {
    guard var urlComponents = URLComponents(string: "https://fonts.googleapis.com")
    else { fatalError("Can not create the google apis fonts URL") }

    urlComponents.path = "/css2"
    urlComponents.queryItems = fonts.map {
        URLQueryItem(name: "family", value: $0.replacingOccurrences(of: " ", with: "+"))
    }
    return urlComponents.url!.absoluteString
}

private struct BlogHTMLFactory: HTMLFactory {
    private let resourcePaths = styleFiles.map(Path.init)

    func makeIndexHTML(
        for index: Index,
        context: PublishingContext<PlumBlog>
    ) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .blogHead(for: index, on: context.site, stylesheetPaths: resourcePaths),
            .body(
                .header(for: context, selectedSection: nil),
                .wrapper(
                    .h1("Latest content"),
                    .itemList(
                        for: context.allItems(
                            sortedBy: \.date,
                            order: .descending
                        ),
                        on: context.site
                    )
                ),
                .footer(for: context.site)
            )
        )
    }

    func makeSectionHTML(
        for section: Section<PlumBlog>,
        context: PublishingContext<PlumBlog>
    ) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .blogHead(for: section, on: context.site, stylesheetPaths: resourcePaths),
            .body(
                .header(for: context, selectedSection: section.id),
                .wrapper(
                    .h1(.text(section.title)),
                    .itemList(for: section.items, on: context.site)
                ),
                .footer(for: context.site)
            )
        )
    }

    func makeItemHTML(
        for item: Item<PlumBlog>,
        context: PublishingContext<PlumBlog>
    ) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .blogHead(for: item, on: context.site, stylesheetPaths: resourcePaths),
            .body(
                .class("item-page"),
                .header(for: context, selectedSection: item.sectionID),
                .wrapper(
                    .article(
                        .div(
                            .class("content"),
                            .contentBody(item.body)
                        ),
                        .span("Tagged with: "),
                        .tagList(for: item, on: context.site)
                    )
                ),
                .footer(for: context.site)
            )
        )
    }

    func makePageHTML(
        for page: Page,
        context: PublishingContext<PlumBlog>
    ) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .blogHead(for: page, on: context.site, stylesheetPaths: resourcePaths),
            .body(
                .header(for: context, selectedSection: nil),
                .wrapper(.contentBody(page.body)),
                .footer(for: context.site)
            )
        )
    }

    func makeTagListHTML(
        for page: TagListPage,
        context: PublishingContext<PlumBlog>
    ) throws -> HTML? {
        HTML(
            .lang(context.site.language),
            .blogHead(for: page, on: context.site, stylesheetPaths: resourcePaths),
            .body(
                .header(for: context, selectedSection: nil),
                .wrapper(
                    .h1("Browse all tags"),
                    .ul(
                        .class("all-tags"),
                        .forEach(page.tags.sorted()) { tag in
                            .li(
                                .class("tag"),
                                .a(
                                    .href(context.site.path(for: tag)),
                                    .text(tag.string)
                                )
                            )
                        }
                    )
                ),
                .footer(for: context.site)
            )
        )
    }

    func makeTagDetailsHTML(
        for page: TagDetailsPage,
        context: PublishingContext<PlumBlog>
    ) throws -> HTML? {
        HTML(
            .lang(context.site.language),
            .blogHead(for: page, on: context.site, stylesheetPaths: resourcePaths),
            .body(
                .header(for: context, selectedSection: nil),
                .wrapper(
                    .h1(
                        "Tagged with ",
                        .span(.class("tag"), .text(page.tag.string))
                    ),
                    .a(
                        .class("browse-all"),
                        .text("Browse all tags"),
                        .href(context.site.tagListPath)
                    ),
                    .itemList(
                        for: context.items(
                            taggedWith: page.tag,
                            sortedBy: \.date,
                            order: .descending
                        ),
                        on: context.site
                    )
                ),
                .footer(for: context.site)
            )
        )
    }
}

extension Node where Context == HTML.BodyContext {
    fileprivate static func wrapper(_ nodes: Node...) -> Node {
        .div(.class("wrapper"), .group(nodes))
    }

    fileprivate static func header(
        for context: PublishingContext<PlumBlog>,
        selectedSection: PlumBlog.SectionID?
    ) -> Node {
        let sectionIDs = PlumBlog.SectionID.allCases

        return .header(
            .wrapper(
                .div(
                    .class("title"),
                    .a(.class("site-name"), .href("/"), .text("Łukasz Śliwiński")),
                    .a(.class("site-subname"), .href("/"), .text("Software Developer Blog"))
                ),
                .div(
                    .class("logo"),
                    .text("🖥📱💻")
                ),
                .div(
                    .class("avatar-wrapper"),
                    .unwrap(
                        context.site.avatarURL,
                        {
                            .img(
                                .src($0),
                                .class("avatar")
                            )
                        }
                    )
                ),
                .if(
                    sectionIDs.count > 1,
                    .nav(
                        .ul(
                            .forEach(sectionIDs) { section in
                                .li(
                                    .a(
                                        .class(section == selectedSection ? "selected" : ""),
                                        .href(context.sections[section].path),
                                        .text(context.sections[section].title)
                                    )
                                )
                            }
                        )
                    )
                )
            )
        )
    }

    fileprivate static func itemList(for items: [Item<PlumBlog>], on site: PlumBlog) -> Node {
        return .ul(
            .class("item-list"),
            .forEach(items) { item in
                .li(
                    .article(
                        .h1(
                            .a(
                                .href(item.path),
                                .text(item.title)
                            )
                        ),
                        .tagList(for: item, on: site),
                        .p(.text(item.description))
                    )
                )
            }
        )
    }

    fileprivate static func tagList(for item: Item<PlumBlog>, on site: PlumBlog) -> Node {
        return .ul(
            .class("tag-list"),
            .forEach(item.tags) { tag in
                let styleNode: Node? = item.metadata.tagColors?
                    .first(where: { $0.tag == tag.string })
                    .map { .style("background-color: #\($0.color);") }

                return styleNode.map({
                    .li(
                        $0,
                        .a(
                            .href(site.path(for: tag)),
                            .text(tag.string)
                        )
                    )
                })
                    ?? .li(
                        .style("background-color: red;"),
                        .a(
                            .href(site.path(for: tag)),
                            .text(tag.string)
                        )
                    )
            }
        )
    }

    fileprivate static func footer<T: Website>(for site: T) -> Node {
        return .footer(
            .p(
                .text("Generated using "),
                .a(
                    .text("Publish"),
                    .href("https://github.com/johnsundell/publish")
                )
            ),
            .p(
                .a(
                    .text("RSS feed"),
                    .href("/feed.rss")
                )
            )
        )
    }
}

extension Node where Context == HTML.DocumentContext {
    public static func blogHead<T: Website>(
        for location: Location,
        on site: T,
        titleSeparator: String = " | ",
        stylesheetPaths: [Path] = ["/styles.css"],
        rssFeedPath: Path? = .defaultForRSSFeed,
        rssFeedTitle: String? = nil
    ) -> Node {
        var title = location.title

        if title.isEmpty {
            title = site.name
        } else {
            title.append(titleSeparator + site.name)
        }

        var description = location.description

        if description.isEmpty {
            description = site.description
        }

        return .head(
            .encoding(.utf8),
            .siteName(site.name),
            .url(site.url(for: location)),
            .title(title),
            .description(description),
            .twitterCardType(location.imagePath == nil ? .summary : .summaryLargeImage),
            .forEach(stylesheetPaths, { .stylesheet($0) }),
            .link(
                .rel(.preconnect),
                .href("https://fonts.gstatic.com")
            ),
            .link(
                .rel(.stylesheet),
                .href(googleApisFontsURL())
            ),
            .viewport(.accordingToDevice),
            .unwrap(site.favicon, { .favicon($0) }),
            .unwrap(
                rssFeedPath,
                { path in
                    let title = rssFeedTitle ?? "Subscribe to \(site.name)"
                    return .rssFeedLink(path.absoluteString, title: title)
                }
            ),
            .unwrap(
                location.imagePath ?? site.imagePath,
                { path in
                    let url = site.url(for: path)
                    return .socialImageLink(url)
                }
            )
        )
    }
}
