import Foundation

public struct ParametrizedPath: Pathable {
    public enum Error: Swift.Error, Equatable {
        case paramsCountMismatch
        case paramterNamesMismatch([String])
    }
    
    private let parametrizedPath: String
    private let params: [String: String]
    
    public init(parametrizedPath: String, params: [String: String]) throws {
        let numberOfParameterBrackets = parametrizedPath.reduce(into: 0) { (acc, char) in
            if char == "{" {
                acc += 1
            }
        }
        if params.count != numberOfParameterBrackets {
            throw Error.paramsCountMismatch
        }
        
        let sortedPathParams = parametrizedPath.slices(from: "\\{", to: "\\}")
        let pathParamsSet = Set(sortedPathParams)
        let paramsSet = Set(params.keys.sorted())
        
        let difference = Array(pathParamsSet.symmetricDifference(paramsSet))
        if difference.isEmpty == false {
            throw Error.paramterNamesMismatch(sortedPathParams.filter({ difference.contains($0) }))
        }
        
        self.parametrizedPath = parametrizedPath
        self.params = params
    }
    
    public var path: String {
        var newPath = parametrizedPath
        for param in params.keys {
            newPath = newPath.replacingOccurrences(of: "{\(param)}", with: params[param]!)
        }
        return newPath
    }
}
