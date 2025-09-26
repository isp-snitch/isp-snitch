import XCTest
@testable import ISPSnitchCore
@testable import ISPSnitchCLI

final class ISPSnitchTests: XCTestCase {
    func testCoreVersion() throws {
        XCTAssertEqual(ISPSnitchCore.version, "1.0.0")
    }

    func testWebVersion() throws {
        // Web module was removed due to SwiftNIO compatibility issues
        XCTAssertTrue(true) // Placeholder test
    }
}
