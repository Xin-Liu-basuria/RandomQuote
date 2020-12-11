//
//  main.swift
//  RandomQuote
//
//  Created by Xin Liu on 12/7/20.
//

import Foundation

let maxCharDefault = 60
let maxCharAlternate = 30
let quoteColor = "#C46243"
let fontSize = 13
let bitbarAPI = "| color=\(quoteColor) length=\(maxCharDefault) size=\(fontSize)\n"
let bitbarAlternateAPI = "| color=\(quoteColor) length=\(maxCharDefault) size=\(fontSize) alternate=true\n"
let locationResourcesFile = "file:///Users/xinliu/Dropbox/Bitbar-Plugins/quoteResources/resources.txt"

if URL(string: locationResourcesFile) == nil {
    exit(1)
}
var locationResourcesFileURL = URL(string: locationResourcesFile)

struct quoteContent {
    static var quoteContentList: [quoteContent] = []
    static func getRandomQuote() -> quoteContent {
        let amountOfList = quoteContentList.count
        let randomSerial = Int.random(in: 0..<amountOfList)
        return quoteContentList[randomSerial]
    }
    static func generateQuoteFromResourcesFile(file fileURL: URL) {
        func getOnePartOfString(_ s: String) -> (serial: Int, label: Int, content: String, cutString: String, isEnd: Bool) {
            let startIndexOfOnePart = s.firstIndex(of: "#")
            let indexOfSerial = s.index(startIndexOfOnePart!, offsetBy: 1)
            let serial = s[indexOfSerial].wholeNumberValue
            let indexOfQuoteLabel = s.index(startIndexOfOnePart!, offsetBy: 3)
            let label = s[indexOfQuoteLabel].wholeNumberValue
            let nextIndexOfOnePart = s[indexOfQuoteLabel...].firstIndex(of: "#")
            let firtIndexOfContent = s.index(startIndexOfOnePart!, offsetBy: 5)
            var isEnd: Bool
            var lastIndexOfContent: String.Index!
            var cutString: String = ""
            var content: String = ""
            if s[indexOfQuoteLabel...].firstIndex(of: "#") != nil {
                isEnd = false
                lastIndexOfContent = s.index(nextIndexOfOnePart!, offsetBy: -1)
                cutString = String(s[nextIndexOfOnePart!...])
                content = String(s[firtIndexOfContent...lastIndexOfContent])
            }else{
                isEnd = true
                lastIndexOfContent = s.endIndex
                content = String(s[firtIndexOfContent..<lastIndexOfContent])
            }
            content = content.replacingOccurrences(of: "\n", with: " ")
            return (serial!, label!, content, cutString, isEnd)
        }
        func writeDataToInstance(serial: Int, label: Int, content: String) {
            switch label {
            case 0:
                quoteContentList.append(quoteContent.init(defaultContent: content))
            case 1:
                quoteContentList[serial].alternateContent = content
            case 2:
                quoteContentList[serial].from = content
            default:
                print("Error:Wrong txt format at content")
            }
        }
        do {
            let wholeContentOfFile = try String(contentsOf: locationResourcesFileURL!, encoding: .utf8)
            var temp = getOnePartOfString(wholeContentOfFile)
            writeDataToInstance(serial: temp.serial, label: temp.label, content: temp.content)
            while !temp.isEnd  {
                temp = getOnePartOfString(temp.cutString)
                writeDataToInstance(serial: temp.serial, label: temp.label, content: temp.content)
            }
        }catch {
            print("Error:Failed to read resources.txt")
        }
    }
    
    var defaultContent: String
    var alternateContent: String?
    var from: String?

    mutating func displayContent() {
        func AddAPIForSingleQuote(quote: String) -> String {
                var result: String = quote
                let lengthOfBitbarAPI = bitbarAPI.count
                let lengthOfQuoteSentence = quote.count
                var i = maxCharDefault, n = maxCharDefault
                while n < lengthOfQuoteSentence {
                    let insertIndex = result.index(result.startIndex, offsetBy: i)
                    result.insert(contentsOf: bitbarAPI, at: insertIndex)
                    i += maxCharDefault + lengthOfBitbarAPI
                    n += maxCharDefault
                }
                result.append(bitbarAPI)
                return result
            }
        func AddAPIForParallelQuote(quoteDefault: String, quoteAlternate: String) -> String {
            var result: String = ""
            var copyQuoteDefault = quoteDefault, copyQuoteAlternate = quoteAlternate
            let lengthQuoteDefault = quoteDefault.count
            let lengthQuoteAlternate = quoteAlternate.count
            let linesQuoteDefault = Int(Double(lengthQuoteDefault / maxCharDefault) + 0.5)
            let linesQuoteAlternate = Int(Double(lengthQuoteAlternate / maxCharAlternate) + 0.5)
            var i = maxCharDefault, j = maxCharAlternate
            func addToResult(_ i: Int,_ j: Int) {
                let indexDefault = copyQuoteDefault.index(copyQuoteDefault.startIndex, offsetBy: i)
                let lastIndexDefault = copyQuoteDefault.index(indexDefault, offsetBy: -maxCharDefault)
                let indexAlternate = copyQuoteAlternate.index(copyQuoteAlternate.startIndex, offsetBy: j)
                let lastIndexAlternate = copyQuoteAlternate.index(indexAlternate, offsetBy: -maxCharAlternate)
                let tempDefault = copyQuoteDefault[lastIndexDefault...indexDefault]
                let tempAlternate = copyQuoteAlternate[lastIndexAlternate...indexAlternate]
                result.append(contentsOf: tempDefault)
                result.append(bitbarAPI)
                result.append(contentsOf: tempAlternate)
                result.append(bitbarAlternateAPI)
            }
            //add backspace to make two quotes same as the number of lines
            if linesQuoteDefault > linesQuoteAlternate {
                let backspaceNumber = (linesQuoteDefault - linesQuoteAlternate) * maxCharAlternate
                for _ in 0..<backspaceNumber {
                    copyQuoteAlternate.append(" ")
                }
            }else {
                let backspaceNumber = (linesQuoteAlternate - linesQuoteDefault) * maxCharDefault
                for _ in 0..<backspaceNumber {
                    copyQuoteDefault.append(" ")
                }
            }
            for _ in 0..<max(linesQuoteDefault, linesQuoteAlternate) {
                addToResult(i, j)
                i += maxCharDefault
                j += maxCharAlternate
            }
            return result
        }
        print("---")
        if alternateContent != nil {
            print(AddAPIForParallelQuote(quoteDefault: defaultContent, quoteAlternate: alternateContent!), terminator:"")
        }else {
            print(AddAPIForSingleQuote(quote: defaultContent), terminator:"")
        }
        let backspaceNumberForwardFrom = maxCharDefault - from!.count
        for _ in 0..<backspaceNumberForwardFrom {
            print(" ", terminator:"")
        }
        print("--",from!,"| trim=false")
    }
    init(defaultContent: String) {
        self.defaultContent = defaultContent
    }
    init(defaultContent: String,from: String) {
        self.defaultContent = defaultContent
        self.from = from
    }
    init(defaultContent: String, alternateContent: String, from: String) {
        self.defaultContent = defaultContent
        self.alternateContent = alternateContent
        self.from = from
    }
}

quoteContent.generateQuoteFromResourcesFile(file: locationResourcesFileURL!)

print("📖")

print("---\n","Pinned")
quoteContent.quoteContentList[0].displayContent()
print("---\n","Ramdom")
var randomQuote = quoteContent.getRandomQuote()
randomQuote.displayContent()
print("---\n","open resources| bash='open \(locationResourcesFile)' terminal=true")
print("---\n","reload | refresh=true ")
