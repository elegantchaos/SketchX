// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Runner

class Exporter {
    let document: String
    let output: String
    let runner = Runner(for: sketchToolURL())

    init(document: String, output: String) {
        self.document = document
        self.output = output
    }

    func export() {
        if let result = try? runner.sync(arguments:["list", "artboards", document]) {
            if result.status == 0 {
                let json = result.stdout
                if let data = json.data(using: .utf8) {
                    if let object = try? JSONSerialization.jsonObject(with: data, options:[]), let dict = object as? [String:Any] {
                        process(dict)
                    }
                }
            }
        }
    }

    class func sketchURL() -> URL {
        return URL(fileURLWithPath:"/Applications/Sketch.app")
    }

    class func sketchToolURL() -> URL {
        return sketchURL().appendingPathComponent("Contents/Resources/sketchtool/bin/sketchtool")
    }

    func process(artboard: [String:Any], catalogue: String) {
        if let name = artboard["name"] as? String, let id = artboard["id"] as? String {
            let catURL = URL(fileURLWithPath: output).appendingPathComponent(catalogue).appendingPathComponent(name)
            try? FileManager.default.createDirectory(at: catURL, withIntermediateDirectories: true, attributes:nil)
            if let result = try? runner.sync(arguments:["export", "artboards", document, "--items=\(id)", "--output=\(catalogue).xcassets"]) {
                print(result.stdout)
                print(result.stderr)
            } else {
                print("failed to export \(name)")
            }
        }
    }

    func process(page: [String:Any]) {
        if let name = page["name"] as? String, let artboards = page["artboards"] as? [[String:Any]] {
            if name != "Symbols" {
                for artboard in artboards {
                    process(artboard: artboard, catalogue: name)
                }
            }
        }
    }

    func process(_ dict: [String:Any]) {
        if let pages = dict["pages"] as? [[String:Any]] {
            for page in pages {
                process(page: page)
            }
        }
    }
}

guard CommandLine.argc > 1 else {
    print("Usage: sketchx MyDoc.sketch path/to/output")
    exit(1)
}

let exporter = Exporter(document: CommandLine.arguments[0], output: CommandLine.arguments[1])
exporter.export()
