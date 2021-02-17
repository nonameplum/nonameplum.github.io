import Foundation
import Files
import Publish

extension File {
    func resolveSwiftPackageFolder() throws -> Folder {
        var nextFolder = parent

        while let currentFolder = nextFolder {
            if currentFolder.containsFile(named: "Package.swift") {
                return currentFolder
            }

            nextFolder = currentFolder.parent
        }

        throw PublishingError(
            path: Path(path),
            infoMessage: "Could not resolve Swift package folder"
        )
    }
}
