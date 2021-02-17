import Foundation

public struct RawPath: Pathable {
    public let path: String
    
    public init(_ path: String) {
        self.path = path
    }
}
