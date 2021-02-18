import Combine
import Files
import Foundation
import Plot
import Publish
import SplashPublishPlugin

struct PlumBlog: Website {
    enum SectionID: String, WebsiteSectionID {
        case posts
    }

    struct ItemMetadata: WebsiteItemMetadata {
        struct TagColor: Decodable, Hashable {
            let tag: String
            let color: String
        }
        let tagColors: [TagColor]?

        init(from decoder: Decoder) throws {
            if let string = try decoder.decodeIfPresent("tagColors", as: String.self) {
                var _tagColors: [TagColor] = []
                string.split(separator: ",").forEach { substring in
                    let keyValue = String(substring).split(separator: "=")
                    _tagColors.append(.init(tag: String(keyValue[0]), color: String(keyValue[1])))
                }
                self.tagColors = _tagColors
            } else {
                self.tagColors = nil
            }
        }
    }

    var url = URL(string: "https://nonameplum.github.io")!
    var name = "Łukasz Śliwiński"
    var description = "Software Developer Blog"
    var language: Language { .english }
    var imagePath: Path? { nil }
    var avatarURL: URL? = nil
}

downloadGitHubIssues()
let avatarURL = getAvatarURL()

try PlumBlog(avatarURL: avatarURL)
    .publish(
        withTheme: .blog,
        deployedUsing: .gitHub("nonameplum/nonameplum.github.io"),
        plugins: [
            .splash(withClassPrefix: "")
        ]
    )
