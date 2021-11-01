# AutoMigrator

A package that generates version based migrations from `Fluent.Model` types.

The project will check your database scheme and understand when you have added, changed or deleted a table.

```swift
.package(url: "https://github.com/MatsMoll/AutoMigrator", from: "0.1.0")
```

All that is required is to add a new target in your product, with a `main.swift` file and add the following code

```swift
@testable import YourApp
import Vapor
import AutoMigrator

var env = try Environment.detect()
let app = Application(env)

// Setup your database connection
try configure(app)

try AutoMigrator(app: app).generateMigrations(
    tables: [
        generateTable(SomeModel.self),
        generateTable(SomeOtherModel.self),
        ...
    ],
    outputDir: app.directory.workingDirectory
)
```

Example output could be something like:

```swift
extension MigrationBatch2.User: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("User")
            .field("email", .string, .required)
            .field("siwaID", .string)
            .update()
    }

    func revert(on database: Database) async throws {
        try await database.schema("User")
            .deleteField("email")
            .deleteField("siwaID")
            .update()
    }
}

extension MigrationBatch2.OtherModel: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("WorkoutSummary")
            .field("workoutID", .uuid, .references("Workout", .id, onDelete: .cascade, onUpdate: .cascade))
            .field("id", .uuid, .identifier(auto: false))
            .field("averagePower", .int64)
            .field("normalizedPower", .int64)
            .field("maxPower", .int64)
            .field("averageHeartRate", .int64)
            .field("averageHeartRate", .int64)
            .field("startedAt", .datetime, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("WorkoutSummary")
            .delete()
    }
}
```
