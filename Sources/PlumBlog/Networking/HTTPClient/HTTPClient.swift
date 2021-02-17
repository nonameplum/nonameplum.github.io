import Foundation

public enum HTTPClientResult {
    case success(HTTPURLResponse, Data)
    case failure(Error)
}

public protocol Cancellable {
    func cancel()
}

public protocol HTTPClient {
    @discardableResult
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) -> Cancellable
}
