import XCTest
@testable import AutoMigrator
import Fluent

final class AutoMigratorTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.        
    }
    
    func testDataType() {
        let string = dataType(from: String.self)
        let uuid = dataType(from: UUID.self)
        let double = dataType(from: Double.self)
        let int = dataType(from: Int.self)
        let datetime = dataType(from: Date.self)
        let bool = dataType(from: Bool.self)
        
        let arrayString = dataType(from: [String].self)
        let arrayInt = dataType(from: [Int].self)
        
        print(arrayString, arrayInt)
        
        XCTAssertEqual(string, .string)
        XCTAssertEqual(uuid, .uuid)
        XCTAssertEqual(double, .double)
        XCTAssertEqual(int, .int)
        XCTAssertEqual(datetime, .datetime)
        XCTAssertEqual(bool, .bool)
        XCTAssertEqual(arrayString, .array(of: .string))
        XCTAssertEqual(arrayInt, .array(of: .int64))
    }
}

extension DatabaseSchema.DataType: Equatable {
    public static func == (lhs: DatabaseSchema.DataType, rhs: DatabaseSchema.DataType) -> Bool {
        switch (lhs, rhs) {
        case (.string, .string), (.uuid, .uuid): return true
        case (.double, .double), (.int64, .int64): return true
        case (.datetime, .datetime), (.bool, .bool): return true
        case (let .array(of: lhsType), let .array(of: rhsType)): return lhsType == rhsType
        default: return false
        }
    }
}
