//
//  File.swift
//  
//
//  Created by Mats Mollestad on 31/10/2021.
//

import Foundation
import Fluent
import FluentPostgresDriver

struct TableInformation: Codable {
    let tablename: String
}

struct ColumnInformation: Codable {
    let table_name: String
    let column_name: String
    let is_nullable: String
    let data_type: String
    
    var field: TableField {
        TableField(
            name: column_name,
            dataType: dataType,
            isRequired: is_nullable == "NO"
        )
    }
    
    var dataType: DatabaseSchema.DataType {
        switch data_type {
        case "text": return .string
        case "uuid": return .uuid
        case "double precision": return .double
        case "bigint": return .int
        case "timestamp with time zone", "timestamp without time zone": return .datetime
        default: fatalError("Unsupported Datatype")
        }
    }
}

struct MigrationNumber: Codable {
    let batch: Int
}

extension AutoMigrator {
    
    func batchNumber(_ databaseID: DatabaseID) throws -> MigrationNumber {
        guard let database = app.databases.database(databaseID, logger: app.logger, on: app.databases.eventLoopGroup.next(), history: nil, pageSizeLimit: nil) as? PostgresDatabase else {
            fatalError()
        }
        let tableInfo = database.sql().raw("SELECT MAX(batch) as batch FROM _fluent_migrations")
        
        app.logger.info("Getting schemas: \(tableInfo.query)", metadata: nil)
        do {
            let result = try tableInfo.first(decoding: MigrationNumber.self).wait()
            return result ?? MigrationNumber(batch: 0)
        } catch {
            return MigrationNumber(batch: 0)
        }
    }

    func currentSchemeState(_ databaseID: DatabaseID) throws -> [String: [ColumnInformation]] {
        guard let database = app.databases.database(databaseID, logger: app.logger, on: app.databases.eventLoopGroup.next(), history: nil, pageSizeLimit: nil) as? PostgresDatabase else { return [:] }
        let tableInfo = database.sql().raw("SELECT * FROM information_schema.columns where table_schema='public'")
        
        app.logger.info("Getting schemas: \(tableInfo.query)", metadata: nil)
        let results = try tableInfo.all(decoding: ColumnInformation.self).wait()
        return results.reduce(into: [:]) { partialResult, column in
            partialResult[column.table_name] = (partialResult[column.table_name] ?? []) + [column]
        }
    }
}
