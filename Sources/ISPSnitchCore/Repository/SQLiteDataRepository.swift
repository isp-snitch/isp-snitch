import Foundation
@preconcurrency import SQLite

// MARK: - SQLite Data Repository Implementation
public class SQLiteDataRepository: DataRepository {
    private let connection: Connection

    public init(connection: Connection) {
        self.connection = connection
    }
}
