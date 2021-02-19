import Combine
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

func createMarkdownFilesAndGetAvatarURL() -> URL {
    var disposeBag = Set<AnyCancellable>()
    var avatarURL: URL!
    let semaphore = DispatchSemaphore(value: 0)

    userLoader.loadUserPublisher().zip(issuesCountLoader.loadIssuesCount())
        .flatMap { (avatarURL, issuesCount) -> AnyPublisher<(URL, [GitHubIssuePagesLoader.Issue]), Error> in
            let maxPageCount: Int = max(Int(Double(issuesCount / perPage).rounded(.up)), 1)

            let pagesPublishers = (1...maxPageCount).map {
                pagesLoader.loadPages(forPage: $0)
            }

            return Publishers.MergeMany(pagesPublishers)
                .collect()
                .map { items in
                    items.flatMap { $0 }
                }
                .map { allIssues in
                    return (avatarURL, allIssues)
                }
                .eraseToAnyPublisher()
        }
        .sink(
            receiveValue: { result in
                defer { semaphore.signal() }

                let (receivedAvatarURL, issues) = result
                avatarURL = receivedAvatarURL
                issues.createMarkdownFiles()
            }
        )
        .store(in: &disposeBag)

    semaphore.wait()

    return avatarURL
}
