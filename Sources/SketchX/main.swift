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
        let docName = URL(fileURLWithPath: document).lastPathComponent
        print("Exporting from \(docName).")
        if let result = try? runner.sync(arguments:["list", "artboards", document]) {
            if result.status == 0 {
                let json = result.stdout
                if let data = json.data(using: .utf8) {
                    if let object = try? JSONSerialization.jsonObject(with: data, options:[]), let dict = object as? [String:Any] {
                        process(dict)
                    }
                }
            } else {
                print("Failed to run sketchtool.")
            }
        }
    }

    class func sketchURL() -> URL {
        let url = URL(fileURLWithPath:"/Applications/Sketch.app")
        return url
    }

    class func sketchToolURL() -> URL {
        let url = sketchURL().appendingPathComponent("Contents/Resources/sketchtool/bin/sketchtool")
        return url
    }

    func process(artboard: [String:Any], catalogue: String) {
        if let name = artboard["name"] as? String, let id = artboard["id"] as? String {
            let catURL = URL(fileURLWithPath: output).appendingPathComponent(catalogue).appendingPathComponent(name)
            try? FileManager.default.createDirectory(at: catURL, withIntermediateDirectories: true, attributes:nil)
        if let _ = try? runner.sync(arguments:["export", "artboards", document, "--items=\(id)", "--output=\(output)/\(catalogue).xcassets"]) {
                print("- exported \(name).")
            } else {
                print("- failed to export \(name).")
            }
        }
    }

    func process(page: [String:Any]) {
        if let name = page["name"] as? String, let artboards = page["artboards"] as? [[String:Any]] {
            if name != "Symbols" {
                print("\nExporting catalogue \(name):")
                for artboard in artboards {
                    process(artboard: artboard, catalogue: name)
                }
            } else {
                print("Skipping symbols.")
            }
        }
    }

    func process(_ dict: [String:Any]) {
        if let pages = dict["pages"] as? [[String:Any]] {
            for page in pages {
                process(page: page)
            }
            print("\nDone.")
        } else {
            print("\nPage data is missing.")
        }
    }
}

guard CommandLine.argc == 3 else {
    print("Usage: sketchx MyDoc.sketch path/to/output")
    exit(1)
}

let exporter = Exporter(document: CommandLine.arguments[1], output: CommandLine.arguments[2])
exporter.export()
