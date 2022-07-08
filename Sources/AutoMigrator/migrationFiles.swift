//
//  File.swift
//  
//
//  Created by Mats Mollestad on 01/11/2021.
//

import Foundation

struct MigrationFiles {
    var subMigrations: [String: String]
    var combinedMigration: String
    let migrationName: String
    let batchNumber: String
}

extension AutoMigrator {
    var migrationFileHeader: String {
        return """
    import Foundation
    import Fluent
    
    // Automatic generated migrations\n
    
    """
    }
    
    func migrationFile(name: String, batch: Int, tableName: String, upgrade: String, downgrade: String) -> String {
    """
    // MARK: - \(name)-batch-\(batch)
    extension MigrationBatch\(batch) {
        struct \(name) {}
    }

    extension MigrationBatch\(batch).\(name): AsyncMigration {
        func prepare(on database: Database) async throws {
            try await database.schema("\(tableName)")\(upgrade)
        }

        func revert(on database: Database) async throws {
            try await database.schema("\(tableName)")\(downgrade)
        }
    }
    // MARK: - \(name)-batch-\(batch)-END
    
    """
    }

    func migrationFile(name: String, upgrade: String, downgrade: String) -> String {
    """
    // MARK: - \(name)
    struct \(name): AsyncMigration {
        func prepare(on database: Database) async throws {
            \(upgrade)
        }

        func revert(on database: Database) async throws {
            \(downgrade)
        }
    }
    // MARK: - \(name)-END
    
    """
    }
    
    func migrationFiles(from currentState: [String: [ColumnInformation]], newTables: [Table]) throws -> MigrationFiles {
        var state = currentState
        var migrationFiles = [String: String]()
        let currentBatchNumber = (try batchNumber(.psql).batch) + 1

        for table in newTables {
            
            let migrationName = table.name
            
            if let old = state[table.name] {
                // change table
                let migrations = migration(old: old.map(\.field), new: table.fields)
                app.logger.info("Changes for \(table.name)", metadata: nil)
                state[table.name] = nil
                
                if migrations.0.isEmpty {
                    continue
                }
                migrationFiles[migrationName] = migrationFile(
                    name: migrationName,
                    batch: currentBatchNumber,
                    tableName: table.name,
                    upgrade: "\(migrations.0)\n            .update()",
                    downgrade: "\(migrations.1)\n            .update()"
                )
            } else {
                // Add table
                let migrations = migration(old: [], new: table.fields)
                app.logger.info("Add \(table.name)", metadata: nil)
                
                migrationFiles[migrationName] = migrationFile(
                    name: migrationName,
                    batch: currentBatchNumber,
                    tableName: table.name,
                    upgrade: "\(migrations.0)\n            .create()",
                    downgrade: "\n            .delete()"
                )
            }
        }

        for removeTable in state {
            app.logger.info("Remove \(removeTable.key)", metadata: nil)
            
            let migrationName = removeTable.key
            
            let migrations = migration(old: removeTable.value.map(\.field), new: [])
            migrationFiles[migrationName] = migrationFile(
                name: migrationName,
                batch: currentBatchNumber,
                tableName: removeTable.key,
                upgrade: "\n            .delete()",
                downgrade: "\(migrations.1)\n            .create()"
            )
        }

        var versionUpgrade = ""
        var versionDowngrade = ""

        for file in migrationFiles {
            versionUpgrade += """

                try await \(file.key)().prepare(on: database)
        """
            versionDowngrade += """

                try await \(file.key)().revert(on: database)
        """
        }

        let totalMigration = "MigrationBatch\(currentBatchNumber)"
        let totalFile = migrationFile(name: totalMigration, upgrade: versionUpgrade, downgrade: versionDowngrade)
        
        return MigrationFiles(
            subMigrations: migrationFiles,
            combinedMigration: totalFile,
            migrationName: totalMigration,
            batchNumber: String(currentBatchNumber)
        )
    }

}
