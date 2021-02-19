import Combine
import Foundation

extension GitHupIssuesCountLoader {
    func loadIssuesCount() -> AnyPublisher<Int, Error> {
        var task: Cancellable?
        return Deferred {
            Future { completion in
                task = self.loadIssuesCount(completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}

extension GitHubIssuePagesLoader {
    func loadPages(forPage page: Int) -> AnyPublisher<[Issue], Error> {
        var task: Cancellable?
        return Deferred {
            Future { completion in
                task = self.loadIssues(forPage: page, completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}

extension GitHubUserLoader {
    func loadUserPublisher() -> AnyPublisher<URL, Error> {
        var task: Cancellable?
        return Deferred {
            Future { completion in
                task = self.loadUser(completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher {
    public func sink(receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
        return sink(receiveCompletion: { _ in }, receiveValue: receiveValue)
    }
}
