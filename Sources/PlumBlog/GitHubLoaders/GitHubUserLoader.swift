import Foundation

struct GitHubUserLoader {
    // MARK: - Types
    public typealias Result = Swift.Result<URL, Error>

    // MARK: - Properties
    private let loader: EndpointLoader

    // MARK: - Initialization
    init(loader: EndpointLoader) {
        self.loader = loader
    }

    // MARK: Private
    private struct GitHubUserResponse: Decodable {
        let avatarURL: URL

        enum CodingKeys: String, CodingKey {
            case avatarURL = "avatar_url"
        }
    }

    private static func mapToUserResponse(
        _ jsonData: Data,
        response: HTTPURLResponse
    ) throws -> GitHubUserResponse {
        guard
            response.statusCode == 200,
            let model = try? JSONDecoder().decode(GitHubUserResponse.self, from: jsonData)
        else {
            throw RemoteLoaderError.invalidData
        }

        return model
    }
}

extension GitHubUserLoader {
    private struct FakeCancellable: Cancellable {
        func cancel() {}
    }

    @discardableResult
    public func loadUser(completion: @escaping (Result) -> Void) -> Cancellable {
        let endpoint = Endpoint(
            httpMethod: .get,
            endpointPath: RawPath("users/nonameplum"),
            map: { (data, response) in
                return try Self.mapToUserResponse(data, response: response).avatarURL
            }
        )

        return loader.load(
            endpoint: endpoint,
            completion: { (result) in
                completion(result)
            }
        )
    }
}
