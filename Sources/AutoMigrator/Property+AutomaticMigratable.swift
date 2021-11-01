//
//  File.swift
//
//
//  Created by Mats Mollestad on 01/11/2021.
//

import Foundation
import Fluent

func dataType<T>(from type: T.Type) -> DatabaseSchema.DataType {
    let reflection = String(describing: T.self)
    
    switch reflection {
    case "String": return .string
    case "UUID": return .uuid
    case "Double": return .double
    case "Int": return .int
    case "Date": return .datetime
    default: fatalError("Unsupported Datatype")
    }
}

extension FieldProperty: AutomaticMigratable {
    var addMigration: String { ".field(\"\(fieldName)\", .\(dataType(from: Value.self)), .required)" }
    var fieldName: String { key.description }
}

extension OptionalFieldProperty: AutomaticMigratable {
    var addMigration: String { ".field(\"\(fieldName)\", .\(dataType(from: WrappedValue.self)))" }
    var fieldName: String { key.description }
}

extension IDProperty: AutomaticMigratable {
    var addMigration: String { ".field(\"\(fieldName)\", .\(dataType(from: Value.self)), .identifier(auto: false))" }
    var fieldName: String { key.description }
}

extension TimestampProperty: AutomaticMigratable {
    var addMigration: String { ".field(\"\(fieldName)\", .datetime)" }
    var fieldName: String { $timestamp.key.description }
}

extension ParentProperty: AutomaticMigratable {
    var addMigration: String { ".field(\"\(fieldName)\", .\(dataType(from: To.IDValue.self)), .required, .references(\"\(To.schema)\", .id, onDelete: .cascade, onUpdate: .cascade))" }
    var fieldName: String { $id.key.description }
}

extension OptionalParentProperty: AutomaticMigratable {
    var addMigration: String { ".field(\"\(fieldName)\", .\(dataType(from: To.IDValue.self)), .references(\"\(To.schema)\", .id, onDelete: .cascade, onUpdate: .cascade))" }
    var fieldName: String { $id.key.description }
}
