//
//  File.swift
//
//
//  Created by Mats Mollestad on 31/10/2021.
//

import Foundation
import Fluent

public protocol AutomaticMigratable {
    var addMigration: String { get }
    var removeMigration: String { get }
                
    var fieldName: String { get }
}

extension AutomaticMigratable {
    public var removeMigration: String { ".deleteField(\"\(fieldName)\")" }
}

struct TableField: AutomaticMigratable {
    let name: String
    let dataType: DatabaseSchema.DataType
    let isRequired: Bool
    
    var removeMigration: String { "" }
    var fieldName: String { name }
    
    var addMigration: String {
        var migration = ""
        migration += ".field(\"\(name)\", .\(dataType)"
        if isRequired {
            migration += ", .required)"
        } else {
            migration += ")"
        }
        return migration
    }
}
