import Files
import Foundation

let perPage = 100
let endpointLoader = HTTPEndpointLoader(
    baseURL: URL(string: "https://api.github.com")!,
    client: URLSessionHTTPClient(session: URLSession.shared)
)

let issuesCountLoader = GitHupIssuesCountLoader(loader: endpointLoader)
let pagesLoader = GitHubIssuePagesLoader(loader: endpointLoader, perPage: perPage)
let userLoader = GitHubUserLoader(loader: endpointLoader)

func downloadGitHubIssues() {
    let group = DispatchGroup()
    group.enter()

    var issues: [GitHubIssuePagesLoader.Issue] = []

    issuesCountLoader.loadIssuesCount(completion: { result in
        switch result {
        case .success(let value):
            guard value > 0
            else { return }

            //            let pagesCount = Double(value / perPage).rounded(.up)

            pagesLoader.loadIssues(
                forPage: 1,
                completion: { pagesResult in
                    switch pagesResult {
                    case .success(let body):
                        issues.append(contentsOf: body)
                        group.leave()

                    case .failure:
                        break
                    }
                }
            )

        case .failure(let error):
            Console.print("Error: \(error)")
        }
    })

    group.wait()

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    dateFormatter.timeZone = .current

    do {
        let postsFolder = try File(path: #file)
            .resolveSwiftPackageFolder()
            .createSubfolder(named: "Content")
            .createSubfolder(named: "posts")

        for issue in issues {
            let body = """
                ---
                date: \(dateFormatter.string(from: issue.createdAt))
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

extension GitHubIssuePagesLoader.Issue {
    private var filteredLabels: [Label]? {
        return self.labels?.filter({ $0.name != "blog" })
    }

    var tagColorsString: String {
        return self.filteredLabels?.reduce(into: String(), { result, label in
            var value = ",\(label.name)=\(label.color)"
            if result.isEmpty {
                value.remove(at: value.startIndex)
            }
            result = "\(result)\(value)"
        }) ?? ""
    }

    var tagsString: String {
        return self.filteredLabels?.map { $0.name }.joined(separator: ",") ?? ""
    }
}

func getAvatarURL() -> URL? {
    let dispatchGroup = DispatchGroup()
    dispatchGroup.enter()

    var result: URL?
    userLoader.loadUser(completion: { user in
        result = try? user.get()
        dispatchGroup.leave()
    })

    dispatchGroup.wait()

    return result
}

extension String {
    var lines: [SubSequence] { split(whereSeparator: \.isNewline) }

    func convertToUnixNewLine() -> String {
        return self.replacingOccurrences(of: "\r\n", with: "\n")
    }
}
