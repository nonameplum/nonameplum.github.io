import Foundation

public struct Endpoint<T> {
    public let httpMethod: HTTPMethod
    public let endpointPath: Pathable
    public let map: (Data, HTTPURLResponse) throws -> T
    
    public init(
        httpMethod: HTTPMethod,
        endpointPath: Pathable,
        map: @escaping (Data, HTTPURLResponse) throws -> T
    ) {
        self.httpMethod = httpMethod
        self.endpointPath = endpointPath
        self.map = map
    }
}
