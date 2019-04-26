// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 25/04/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import CommandShell
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
    
    func export() throws -> Result {
        let docName = URL(fileURLWithPath: document).lastPathComponent
        print("Exporting from \(docName).")
        let result = try runner.sync(arguments:["list", "artboards", document])
        if result.status == 0 {
            let json = result.stdout
            guard let data = json.data(using: .utf8), let object = try? JSONSerialization.jsonObject(with: data, options:[]), let dict = object as? [String:Any] else {
                return .couldntDecodeResults
            }
            
            process(dict)
            return .ok
        } else {
            return Result.exportFailed.adding(supplementary: result.stderr)
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
            print("")
        } else {
            print("\nPage data is missing.")
        }
    }
}

extension Result {
    static let exportFailed = Result(100, "Exporting failed.")
    static let couldntDecodeResults = Result(100, "Couldn't decode the results from sketchtool.")
}

class ExportCommand: Command {
    override var description: Command.Description {
        return Description(
            name: "",
            help: "",
            usage: [
                "<document> <path>",
                "<document> <pages> <path>"
            ],
            arguments: [
                "<document>" : "The sketch document to export from",
                "<pages>" : "The name of one or more pages to export from (comma separated).",
                "<path>" : "The path to export to"
            ]
        )
    }
    
    override func run(shell: Shell) throws -> Result {
        let args = shell.arguments
        let document = args.argument("document")
        let pages = args.argument("page")
        let output = args.argument("path")
        let exporter = Exporter(document: document, pages: pages.isEmpty ? nil : pages, output: output)
        
        do {
            return try exporter.export()
        } catch {
            return Result.exportFailed.adding(supplementary: String(describing: error))
        }
    }
}
