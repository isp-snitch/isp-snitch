import XCTest
@testable import ISPSnitchCore
@testable import ISPSnitchCLI
@testable import ISPSnitchWeb

final class ISPSnitchTests: XCTestCase {
    func testCoreVersion() throws {
        XCTAssertEqual(ISPSnitchCore.version, "1.0.0")
    }
    
    func testWebVersion() throws {
        XCTAssertEqual(ISPSnitchWeb.version, "1.0.0")
    }
}
