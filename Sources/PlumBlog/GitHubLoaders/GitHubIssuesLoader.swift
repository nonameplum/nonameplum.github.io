import Foundation

struct GitHupIssuesCountLoader {
    // MARK: - Types
    public typealias Result = Swift.Result<Int, Error>

    // MARK: - Properties
    private let loader: EndpointLoader

    // MARK: - Initialization
    init(loader: EndpointLoader) {
        self.loader = loader
    }

    // MARK: Private
    private func makeIssuesEndpoint() -> Endpoint<Int> {
        return Endpoint<Int>(
            httpMethod: .get,
            endpointPath: RawPath("repos/nonameplum/blog"),
            map: { (data, response) -> Int in
                return try Self.mapToReposResponse(data, response: response).openIssues
            }
        )
    }

    private struct GitHubRepoResponse: Decodable {
        let openIssues: Int

        enum CodingKeys: String, CodingKey {
            case openIssues = "open_issues"
        }
    }

    private static func mapToReposResponse(
        _ jsonData: Data,
        response: HTTPURLResponse
    ) throws -> GitHubRepoResponse {
        guard
            response.statusCode == 200,
            let model = try? JSONDecoder().decode(GitHubRepoResponse.self, from: jsonData)
        else {
            throw RemoteLoaderError.invalidData
        }

        return model
    }
}

extension GitHupIssuesCountLoader {
    private struct FakeCancellable: Cancellable {
        func cancel() {}
    }

    @discardableResult
    public func loadIssuesCount(completion: @escaping (Result) -> Void) -> Cancellable {
        let endpoint = makeIssuesEndpoint()

        return loader.load(
            endpoint: endpoint,
            completion: { (result) in
                completion(result)
            }
        )
    }
}
