import Foundation

public struct ParametrizedQueryPath: Pathable {
    private let parametrizedPath: ParametrizedPath
    private let queryPath: QueryPath?
    
    public init(parametrizedPath: ParametrizedPath, queryPath: QueryPath?) {
        self.parametrizedPath = parametrizedPath
        self.queryPath = queryPath
    }
    
    public var path: String {
        if let queryPath = queryPath  {
            return parametrizedPath.path + queryPath.path
        }
        return parametrizedPath.path
    }
}
