//
//  File.swift
//  
//
//  Created by Mats Mollestad on 01/11/2021.
//

import Foundation
import FluentPostgresDriver
import Fluent

extension AutoMigrator {
    func updateFile(path: URL, sectionName: String, content: String) throws {
        do {
            var exitsFile = try String(contentsOf: path)
            if let lowerBound = exitsFile.range(of: "// MARK: - \(sectionName)")?.lowerBound,
               let upperBound = exitsFile.range(of:"// MARK: - \(sectionName)-END")?.upperBound {
                exitsFile.replaceSubrange(lowerBound...upperBound, with: content)
            } else {
                exitsFile.append(contentsOf: "\n")
                exitsFile.append(contentsOf: content)
            }
            try exitsFile.write(to: path, atomically: true, encoding: .utf8)
        } catch {
            var newFile = migrationFileHeader
            newFile.append(contentsOf: content)
            try newFile.write(to: path, atomically: true, encoding: .utf8)
        }
    }
    
    public func generateMigrations(tables: [Table], outputDir: String) throws {
        
        var state = try currentSchemeState(.psql)
        
        state["_fluent_migrations"] = nil
        
        let migrations = try migrationFiles(from: state, newTables: tables)
        
        let mainUrl = URL(fileURLWithPath: "\(outputDir)/MigrationBatch.swift")
        try updateFile(path: mainUrl, sectionName: migrations.migrationName, content: migrations.combinedMigration)
        
        for file in migrations.subMigrations {
            let url = URL(fileURLWithPath: "\(outputDir)/\(file.key.capitalized+"-Migration").swift")
            try updateFile(path: url, sectionName: file.key + "-batch-" + migrations.batchNumber, content: file.value)
        }
        app.logger.info("\(migrations.migrationName)", metadata: nil)
        app.logger.info("Written to: \(outputDir)", metadata: nil)

    }
}
