import Foundation

public protocol EndpointLoader {
    @discardableResult
    func load<T>(endpoint: Endpoint<T>, completion: @escaping (Result<T, Error>) -> Void) -> Cancellable
}

public class HTTPEndpointLoader: EndpointLoader {
    
    private let baseURL: URL
    private let client: HTTPClient
    
    public init(baseURL: URL, client: HTTPClient) {
        self.baseURL = baseURL
        self.client = client
    }

    @discardableResult
    public func load<T>(endpoint: Endpoint<T>, completion: @escaping (Result<T, Error>) -> Void) -> Cancellable {
        guard let url = URL(string: "\(self.baseURL)/\(endpoint.endpointPath.path)")
        else { fatalError("Cannot create URL components with base url: \(self.baseURL)/\(endpoint.endpointPath.path)") }

        return client.get(from: url) { (result) in
            switch result {
            case let .success(response, data):
                completion(Result(catching: {
                    do {
                        return try endpoint.map(data, response)
                    } catch {
                        Console.print(
                            """
                            url: \(url.absoluteString)
                            response: \(response.debugDescription)
                            data: \(String.init(data: data, encoding: .utf8) ?? "")
                            error: \(error)
                            """)
                        throw error
                    }
                }))
            case .failure:
                completion(.failure(RemoteLoaderError.connectivity))
            }
        }
    }
}
