import Foundation

extension String {
    func ranges(of string: String, options: CompareOptions = .literal) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range)
            start = range.lowerBound < range.upperBound ?
                range.upperBound :
                index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }

    func slices(from: String, to: String) -> [String] {
        let pattern = "(?<=" + from + ").*?(?=" + to + ")"
        return ranges(of: pattern, options: .regularExpression)
            .map{ String(self[$0]) }
    }
}

extension String {
    var lines: [SubSequence] { split(whereSeparator: \.isNewline) }

    func convertToUnixNewLine() -> String {
        return self.replacingOccurrences(of: "\r\n", with: "\n")
    }
}
