//
//  File.swift
//  
//
//  Created by Mats Mollestad on 01/11/2021.
//

import Foundation
import PostgresKit
import Fluent

extension AutoMigrator {
    
    public func generateMigrations(newTables: [Table], outputDir: String) throws {
        
        var state = try currentSchemeState(.psql)

        state["_fluent_migrations"] = nil

        let migrations = try migrationFiles(from: state, newTables: newTables)

        let workingDir = app.directory.workingDirectory
        let mainUrl = URL(fileURLWithPath: "\(outputDir)/\(migrations.migrationName).swift")
        try! migrations.combinedMigration.write(to: mainUrl, atomically: true, encoding: .utf8)

        for file in migrations.subMigrations {
            let url = URL(fileURLWithPath: "\(outputDir)/\(migrations.migrationName)+\(file.key).swift")
            try! file.value.write(to: url, atomically: true, encoding: .utf8)
        }

        app.logger.info("\(migrations.migrationName)", metadata: nil)
        app.logger.info("Written to: \(workingDir)", metadata: nil)

    }
}
