import Foundation

struct GitHubIssuePagesLoader {
    // MARK: - Types
    typealias Result = Swift.Result<[Issue], Error>
    struct Issue: Decodable {
        struct Label: Decodable {
            let name: String
            let color: String
        }

        let id: Int
        let title: String
        let createdAt: Date
        let body: String
        let labels: [Label]?

        enum CodingKeys: String, CodingKey {
            case id
            case title
            case createdAt = "created_at"
            case body
            case labels
        }
    }

    // MARK: - Properties
    private let loader: EndpointLoader
    private let perPage: Int

    // MARK: - Initialization
    init(loader: EndpointLoader, perPage: Int = 100) {
        self.loader = loader
        self.perPage = perPage
    }

    // MARK: Private
    private func makeEndpoint(forPage page: Int) -> Endpoint<[Issue]> {
        return Endpoint(
            httpMethod: .get,
            endpointPath: QueryPath(
                path: "repos/nonameplum/blog/issues",
                queryItems: [
                    .init(name: "page", value: "\(page)"),
                    .init(name: "per_page", value: "\(self.perPage)"),
                ]
            ),
            map: { (data, response) -> [Issue] in
                return try Self.mapToPagesResponse(data, response: response)
            }
        )
    }

    private static func mapToPagesResponse(
        _ jsonData: Data,
        response: HTTPURLResponse
    ) throws -> [Issue] {
        guard response.statusCode == 200
        else { throw RemoteLoaderError.invalidData }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let model = try decoder.decode([Issue].self, from: jsonData)
            return model
        } catch {
            Console.print("\(error)")
            throw RemoteLoaderError.invalidData
        }
    }
}

extension GitHubIssuePagesLoader {
    private struct FakeCancellable: Cancellable {
        func cancel() {}
    }

    @discardableResult
    public func loadIssues(
        forPage page: Int,
        completion: @escaping (Result) -> Void
    ) -> Cancellable {
        let endpoint = self.makeEndpoint(forPage: page)

        return self.loader.load(
            endpoint: endpoint,
            completion: { (result) in
                completion(result)
            }
        )
    }
}
