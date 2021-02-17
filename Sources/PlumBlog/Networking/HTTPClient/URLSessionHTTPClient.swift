import Foundation

public class URLSessionHTTPClient {
    // MARK: - Types
    private struct UnexpectedValuesRepresentation: Error {}

    // MARK: - Properties
    private let session: URLSession

    // MARK: - Initialization
    public init(session: URLSession = .shared) {
        self.session = session
    }
}

// MARK: - HTTPClient -

extension URLSessionHTTPClient: HTTPClient {

    private struct URLSessionTaskWrapper: Cancellable {
        let wrapped: URLSessionTask

        func cancel() {
            wrapped.cancel()
        }
    }

    public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) -> Cancellable {
        let task = session.dataTask(
            with: url,
            completionHandler: { data, response, error in
                if let error = error {
                    completion(.failure(error))
                } else if let data = data, let response = response as? HTTPURLResponse {
                    completion(.success(response, data))
                } else {
                    completion(.failure(UnexpectedValuesRepresentation()))
                }
            }
        )

        task.resume()

        return URLSessionTaskWrapper(wrapped: task)
    }
}
