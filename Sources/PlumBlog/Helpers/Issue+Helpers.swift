import Files
import Foundation

extension Array where Element == GitHubIssuePagesLoader.Issue {
    func createMarkdownFiles() {
        do {
            let postsFolder = try File(path: #file)
                .resolveSwiftPackageFolder()
                .createSubfolder(named: "Content")
                .createSubfolder(named: "posts")

            for issue in self {
                let body = """
                    ---
                    date: \(Self.dateFormatter.string(from: issue.createdAt))
                    description: \(issue.title)
                    tags: \(issue.tagsString)
                    tagColors: \(issue.tagColorsString)
                    ---
                    \(issue.body)
                    """
                    .convertToUnixNewLine()

                try postsFolder.createFile(at: "\(issue.title).md", contents: body.data(using: .utf8))
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.timeZone = .current
        return dateFormatter
    }()
}

extension GitHubIssuePagesLoader.Issue {
    var tagColorsString: String {
        return self.filteredLabels?.reduce(
            into: String(),
            { result, label in
                var value = ",\(label.name)=\(label.color)"
                if result.isEmpty {
                    value.remove(at: value.startIndex)
                }
                result = "\(result)\(value)"
            }
        ) ?? ""
    }

    var tagsString: String {
        return self.filteredLabels?.map { $0.name }.joined(separator: ",") ?? ""
    }

    private var filteredLabels: [Label]? {
        return self.labels?.filter({ $0.name != "blog" })
    }
}
