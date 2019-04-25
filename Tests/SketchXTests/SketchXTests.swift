import XCTest
import class Foundation.Bundle
import Runner

final class SketchXTests: XCTestCase {
    func testUsage() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

        let fooBinary = productsDirectory.appendingPathComponent("SketchX")
        let runner = Runner(for: fooBinary)
        let result = try runner.sync(arguments: [])
        
        let expected = """
Usage:
    SketchX <document> <path>
    SketchX <document> <pages> <path>

"""
        
        XCTAssertEqual(result.stdout, expected)
    }

    func testExport() throws {
        let fooBinary = productsDirectory.appendingPathComponent("SketchX")
        let runner = Runner(for: fooBinary)
        
        let url = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("../../Example/Example.sketch")
        
        let result = try runner.sync(arguments: [url.path, "exported"])
        let expected = """
Exporting from Example.sketch.

Exporting Assets.xcassets:
- exported AppIcon.appiconset/Icon.
- exported Image.imageset/Image.

Done.


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
}
