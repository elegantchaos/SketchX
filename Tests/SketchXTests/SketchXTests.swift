import XCTest
import class Foundation.Bundle
import Runner

final class SketchXTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

        // Some of the APIs that we use below are available in macOS 10.13 and above.
        guard #available(macOS 10.13, *) else {
            return
        }

        let fooBinary = productsDirectory.appendingPathComponent("SketchX")
        let runner = Runner(for: fooBinary)
        let result = try! runner.sync(arguments: [])
        
        let expected = """
Usage:
    SketchX <document> <path>
    SketchX <document> <page> <path>

"""
        
        XCTAssertEqual(result.stdout, expected)
    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
