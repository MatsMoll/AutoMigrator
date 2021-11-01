//
//  File.swift
//  
//
//  Created by Mats Mollestad on 01/11/2021.
//

import Foundation
import Fluent

public struct Table {
    public let name: String
    public let fields: [AutomaticMigratable]
}

public func generateTable<T: Model>(_ model: T.Type) -> Table {
    
    var fields = [AutomaticMigratable]()
    
    for property in T.init().properties {
        if let migratable = property as? AutomaticMigratable {
            fields.append(migratable)
        }
    }
    
    return Table(name: model.schema, fields: fields)
}

extension AutoMigrator {

    func migration(old: [AutomaticMigratable], new: [AutomaticMigratable]) -> (String, String) {
        let newLine = "\n            "
        var upgradeMigration = ""
        var downgradeMigration = ""
        
        var oldState = old.reduce(into: [:]) { partialResult, field in
            partialResult[field.fieldName] = field
        }
        
        for field in new {
            if oldState[field.fieldName] == nil {
                upgradeMigration += newLine + field.addMigration
                downgradeMigration += newLine + field.removeMigration
            } else {
                oldState[field.fieldName] = nil
            }
        }
        
        for removedField in oldState.values {
            downgradeMigration += newLine + removedField.addMigration
            upgradeMigration += newLine + removedField.removeMigration
        }
        
        return (upgradeMigration, downgradeMigration)
    }
}
