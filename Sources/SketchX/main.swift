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
    let aliases: [String:String]
    let runner = Runner(for: sketchToolURL())

    init(document: String, pages pageList: String?, output: String) {

        var aliases = [String:String]()
        var pages = [String]()
        if let pageList = pageList {
            for page in pageList.split(separator: ",") {
                let split = page.split(separator: "=")
                if split.count > 1 {
                    let name = String(split[0])
                    pages.append(name)
                    aliases[name] = String(split[1])
                } else {
                    pages.append(String(page))
                }
            }
        }

        self.document = document
        self.output = output
        self.pages = pages
        self.aliases = aliases
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
            if let _ = try? runner.sync(arguments:["export", "artboards", document, "--items=\(id)", "--output=\(catURL.path)"]) {
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
                let alias = aliases[name] ?? name
                if alias != name {
                    print("\nExporting \(name) as \(alias).xcassets:")
                } else {
                    print("\nExporting \(name).xcassets:")
                }

                for artboard in artboards {
                    process(artboard: artboard, catalogue: alias)
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
