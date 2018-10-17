// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Runner

class Exporter {
    let document: String
    let output: String
    let pages: [String]
    let runner = Runner(for: sketchToolURL())
    var files: [String] = []

    init(document: String, pages: String?, output: String) {
        self.document = document
        self.output = output
        if let pages = pages {
            self.pages = pages.split(separator: ",").map { String($0) }
        } else {
            self.pages = []
        }
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
                print(result.stderr)
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
            let catURL = URL(fileURLWithPath: output).appendingPathComponent(catalogue).appendingPathExtension("xcassets")
            let boardURL = catURL.appendingPathComponent(name)
            try? FileManager.default.createDirectory(at: boardURL, withIntermediateDirectories: true, attributes:nil)
            if let _ = try? runner.sync(arguments:["export", "artboards", document, "--items=\(id)", "--output=\(catURL.path)"]) {
                files.append(boardURL.path)
                print("- exported \(name).")
            } else {
                print("- failed to export \(name).")
            }
        }
    }

    func shouldExport(page name: String) -> Bool {
        if pages.count == 0 {
            return name != "Symbols"
        } else {
            return pages.contains(name)
        }
    }

    func process(page: [String:Any]) {
        if let name = page["name"] as? String, let artboards = page["artboards"] as? [[String:Any]] {
            if shouldExport(page: name) {
                print("\nExporting catalogue \(name):")
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
            print("\nDone.")
        } else {
            print("\nPage data is missing.")
        }
    }
}

let output: String
let pages: String?

switch CommandLine.argc {
case 3:
    output = CommandLine.arguments[2]
    pages = nil
case 4:
    output = CommandLine.arguments[3]
    pages = CommandLine.arguments[2]
    break

default:
    print("Usage: sketchx MyDoc.sketch Path/To/Export/To")
    print("Usage: sketchx MyDoc.sketch PageToExport Path/To/Export/To")
    exit(1)
}

let document = CommandLine.arguments[1]
let exporter = Exporter(document: document, pages: pages, output: output)
exporter.export()
