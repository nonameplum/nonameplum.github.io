import Foundation

internal enum Console {
    static internal  func print(_ string: String) {
        let output = "☢️ \(string)\n"
        fputs(output, stdout)
    }
}
