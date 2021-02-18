import Foundation

internal let styleFiles = ["styles.css", "code.css"]
internal let fonts = ["Comfortaa"]

internal func googleApisFontsURL() -> String {
    guard var urlComponents = URLComponents(string: "https://fonts.googleapis.com")
    else { fatalError("Can not create the google apis fonts URL") }

    urlComponents.path = "/css2"
    urlComponents.queryItems = fonts.map {
        URLQueryItem(name: "family", value: $0.replacingOccurrences(of: " ", with: "+"))
    }
    return urlComponents.url!.absoluteString
}
