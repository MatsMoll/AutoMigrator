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
    public var addMigration: String { ".field(\"\(fieldName)\", .\(dataType(from: Value.self)), .required)" }
    public var fieldName: String { key.description }
}

extension OptionalFieldProperty: AutomaticMigratable {
    public var addMigration: String { ".field(\"\(fieldName)\", .\(dataType(from: WrappedValue.self)))" }
    public var fieldName: String { key.description }
}

extension IDProperty: AutomaticMigratable {
    public var addMigration: String { ".field(\"\(fieldName)\", .\(dataType(from: Value.self)), .identifier(auto: false))" }
    public var fieldName: String { key.description }
}

extension TimestampProperty: AutomaticMigratable {
    public var addMigration: String { ".field(\"\(fieldName)\", .datetime)" }
    public var fieldName: String { $timestamp.key.description }
}

extension ParentProperty: AutomaticMigratable {
    public var addMigration: String { ".field(\"\(fieldName)\", .\(dataType(from: To.IDValue.self)), .required, .references(\"\(To.schema)\", .id, onDelete: .cascade, onUpdate: .cascade))" }
    public var fieldName: String { $id.key.description }
}

extension OptionalParentProperty: AutomaticMigratable {
    public var addMigration: String { ".field(\"\(fieldName)\", .\(dataType(from: To.IDValue.self)), .references(\"\(To.schema)\", .id, onDelete: .cascade, onUpdate: .cascade))" }
    public var fieldName: String { $id.key.description }
}
