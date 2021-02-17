import Foundation

public struct QueryPath: Pathable {
    private let subPath: String
    private let queryItems: [URLQueryItem]
    
    public init(path: String = "", queryItems: [URLQueryItem]) {
        self.subPath = path
        self.queryItems = queryItems
    }
    
    public var path: String {
        var components = URLComponents(string: subPath)!
        if queryItems.isEmpty == false {
            components.queryItems = queryItems
        }
        return components.url!.absoluteString
    }
}
