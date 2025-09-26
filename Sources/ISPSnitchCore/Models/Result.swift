import Foundation

// MARK: - Result Extensions for Clean Error Handling
public extension Result {
    /// Maps the success value using the provided closure
    func map<NewSuccess>(_ transform: (Success) -> NewSuccess) -> Result<NewSuccess, Failure> {
        switch self {
        case .success(let value):
            return .success(transform(value))
        case .failure(let error):
            return .failure(error)
        }
    }

    /// Maps the failure value using the provided closure
    func mapError<NewFailure>(_ transform: (Failure) -> NewFailure) -> Result<Success, NewFailure> {
        switch self {
        case .success(let value):
            return .success(value)
        case .failure(let error):
            return .failure(transform(error))
        }
    }

    /// Returns the success value or throws the failure
    func get() throws -> Success {
        switch self {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
}

// MARK: - Async Result Builder
@resultBuilder
public struct AsyncResultBuilder {
    public static func buildBlock<T>(_ components: Result<T, Error>...) -> [Result<T, Error>] {
        return components
    }

    public static func buildExpression<T>(_ expression: Result<T, Error>) -> Result<T, Error> {
        return expression
    }
}

// MARK: - Result Utilities
public struct ResultUtils {
    /// Combines multiple results into a single result
    public static func combine<T, E: Error>(_ results: Result<T, E>...) -> Result<[T], E> {
        var values: [T] = []
        for result in results {
            switch result {
            case .success(let value):
                values.append(value)
            case .failure(let error):
                return .failure(error)
            }
        }
        return .success(values)
    }

    /// Executes multiple async operations and combines their results
    public static func combine<T>(_ operations: [() async throws -> T]) async -> Result<[T], Error> {
        do {
            let results = try await withThrowingTaskGroup(of: T.self) { group in
                for operation in operations {
                    group.addTask {
                        try await operation()
                    }
                }

                var results: [T] = []
                for try await result in group {
                    results.append(result)
                }
                return results
            }
            return .success(results)
        } catch {
            return .failure(error)
        }
    }
}
