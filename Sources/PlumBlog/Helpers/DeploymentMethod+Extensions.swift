import Publish
import ShellOut
import Files
import Foundation

extension DeploymentMethod {
    /// Deploy a website to a given remote using Git.
    /// - parameter remote: The full address of the remote to deploy to.
    static func git(_ remote: String, branchName: String) -> Self {
        return DeploymentMethod(name: "Git (\(remote))") { context in
            let folder: Folder
            do {
                folder = try context.createDeploymentFolder(withPrefix: "Git") { folder in
                    if !folder.containsSubfolder(named: ".git") {
                        try shellOut(to: .gitInit(), at: folder.path)

                        try shellOut(
                            to: "git remote add origin \(remote)",
                            at: folder.path
                        )
                    }

                    try shellOut(to: "git fetch origin", at: folder.path)

                    try shellOut(to: "git switch \(branchName)", at: folder.path)

                    try shellOut(to: "git pull origin \(branchName)", at: folder.path)

                    try folder.empty()
                }
            } catch {
                throw PublishingError(infoMessage: error.localizedDescription)
            }

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString = dateFormatter.string(from: Date())

            do {
                try shellOut(
                    to: """
                    git add . && git commit -a -m \"Publish deploy \(dateString)\" --allow-empty
                    """,
                    at: folder.path
                )

                try shellOut(to: "git branch", at: folder.path)

                try shellOut(to: "git push origin \(branchName)", at: folder.path)

            } catch let error as ShellOutError {
                throw PublishingError(infoMessage: error.message)
            } catch {
                throw error
            }
        }
    }

    static func gitHub(_ repository: String, useSSH: Bool = true, branchName: String) -> Self {
        let prefix = useSSH ? "git@github.com:" : "https://github.com/"
        return git("\(prefix)\(repository).git", branchName: branchName)
    }
}
