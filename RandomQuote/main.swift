//
//  RandomQuote
//  main.swift
//
//  Created by Xin Liu on 12/7/20.
//  Copyright @2020 Xin Liu, All rights reserved.
//
//TODO: add notification
import Foundation

let defaultMaxCharDefault = 60
let defaultMaxCharAlternate = 30
let defaultQuoteColor = "#C46243"
let defautlFontSize = 13
let defaultFont = "Courier"

let locationResourcesFile = "file:///Users/xinliu/Dropbox/Bitbar-Plugins/quoteResources/resources.txt"
let locationCongfig = "file:///Users/xinliu/Dropbox/Bitbar-Plugins/quoteResources/config"

if URL(string: locationResourcesFile) == nil {
    exit(1)
}
if URL(string: locationCongfig) == nil {
    exit(1)
}
let locationResourcesFileURL = URL(string: locationResourcesFile)
let locationCongfigURL = URL(string: locationCongfig)

struct configFile {
    var maxCharDefault: Int?
    var maxCharAlternate: Int?
    var quoteColor: String?
    var fontSize: Int?
    var fontKind: String?
    var pinQuote: [Int]?
    var backspaceNumberForwardFrom: Int?
    init(file fileURL: URL) {
        let wholeContentOfConfig = try! String(contentsOf: fileURL, encoding: .utf8)
        let singleLineOfConfig = wholeContentOfConfig.split(separator: "\n")

        let configFactorList = ["maxCharDefault", "maxCharAlternate", "quoteColor", "fontSize", "fontKind", "pinQuote", "backspaceNumberForwardFrom"]
        func toInt(_ s: String) -> Int {
            let indexStart = s.firstIndex(where: {$0.isNumber})
            return Int(s[indexStart!...])!
        }
        for singleConfig in singleLineOfConfig {
            for configFactor in configFactorList {
                if singleConfig.contains(configFactor) {
                    let ConfigFactorAndValue = singleConfig.split(separator: "=")
                    switch configFactor {
                        case configFactorList[0]:
                            self.maxCharDefault = toInt(String(ConfigFactorAndValue[1]))
                        case configFactorList[1]:
                            self.maxCharAlternate = toInt(String(ConfigFactorAndValue[1]))
                        case configFactorList[2]:
                            self.quoteColor = String(ConfigFactorAndValue[1])
                        case configFactorList[3]:
                            self.fontSize = toInt(String(ConfigFactorAndValue[1]))
                        case configFactorList[4]:
                            self.fontKind = String(ConfigFactorAndValue[1])
                        case configFactorList[5]:
                            self.pinQuote = []
                            let ToString = String(ConfigFactorAndValue[1])
                            var temp = ToString.firstIndex(of: "[")
                            let indexStart = ToString.index(temp!, offsetBy: 1)
                            temp = ToString.firstIndex(of: "]")
                            let indexEnd = ToString.index(temp!, offsetBy: -1)
                            let pinSerialArray = ToString[indexStart...indexEnd].split(separator: ",")
                            for i in 0..<pinSerialArray.count {
                                self.pinQuote?.append(Int(String(pinSerialArray[i]))!)
                            }
                        case configFactorList[6]:
                            self.backspaceNumberForwardFrom = toInt(String(ConfigFactorAndValue[1]))
                        default:
                            print("Error")
                    }
                }
            }
        }
    }
    init(maxCharDefault: Int, maxCharAlternate: Int, quoteColor: String, fontSize: Int) {
        self.maxCharDefault = maxCharDefault
        self.maxCharAlternate = maxCharAlternate
        self.quoteColor = quoteColor
        self.fontSize = fontSize
    }
}
var config = configFile.init(file: locationCongfigURL!)
//var config = configFile.init(maxCharDefault: defaultMaxCharDefault, maxCharAlternate: defaultMaxCharAlternate, quoteColor: defaultQuoteColor, fontSize: defautlFontSize)

let bitbarAPI = "| color=\(config.quoteColor!) length=\((config.maxCharDefault ?? defaultMaxCharDefault)+1) size=\(config.fontSize!) font=\(config.fontKind ?? defaultFont)\n"
let bitbarAlternateAPI = "| color=\(config.quoteColor!) length=\((config.maxCharDefault ?? defaultMaxCharAlternate)+1) size=\(config.fontSize!) font=\(config.fontKind ?? defaultFont) alternate=true\n"

struct quoteContent {
    static var quoteContentList: [quoteContent] = []
    static func getRandomQuote() -> (content: quoteContent,serial: Int) {
        let amountOfList = quoteContentList.count
        let randomSerial = Int.random(in: 0..<amountOfList)
        return (quoteContentList[randomSerial], randomSerial)
    }
    static func generateQuoteListFromResourcesFile(file fileURL: URL) {
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
            var i = config.maxCharDefault!, n = config.maxCharDefault!
            while n < lengthOfQuoteSentence {
                let insertIndex = result.index(result.startIndex, offsetBy: i)
                result.insert(contentsOf: bitbarAPI, at: insertIndex)
                i += config.maxCharDefault! + lengthOfBitbarAPI
                n += config.maxCharDefault!
            }
            result.append(bitbarAPI)
            return result
        }
        func AddAPIForParallelQuote(quoteDefault: String, quoteAlternate: String) -> String {
            var result: String = ""
            var copyQuoteDefault = quoteDefault, copyQuoteAlternate = quoteAlternate
            let lengthQuoteDefault = quoteDefault.count
            let lengthQuoteAlternate = quoteAlternate.count
            let linesQuoteDefault = Int( (Double(lengthQuoteDefault) / Double(config.maxCharDefault!)) + 1.0 )
            let linesQuoteAlternate = Int( (Double(lengthQuoteAlternate) / Double(config.maxCharAlternate!)) + 1.0 )
            var i = config.maxCharDefault!, j = config.maxCharAlternate!
            func addToResult(_ i: Int,_ j: Int) {
                let indexDefault = copyQuoteDefault.index(copyQuoteDefault.startIndex, offsetBy: i)
                let lastIndexDefault = copyQuoteDefault.index(indexDefault, offsetBy: -config.maxCharDefault!)
                let indexAlternate = copyQuoteAlternate.index(copyQuoteAlternate.startIndex, offsetBy: j)
                let lastIndexAlternate = copyQuoteAlternate.index(indexAlternate, offsetBy: -config.maxCharAlternate!)
                let tempDefault = copyQuoteDefault[lastIndexDefault...indexDefault]
                let tempAlternate = copyQuoteAlternate[lastIndexAlternate...indexAlternate]
                result.append(contentsOf: tempDefault)
                result.append(bitbarAPI)
                result.append(contentsOf: tempAlternate)
                result.append(bitbarAlternateAPI)
            }
            //add backspace to make two quotes same as the number of lines
            if linesQuoteDefault > linesQuoteAlternate {
                let backspaceNumber = (linesQuoteDefault - linesQuoteAlternate + 1) * config.maxCharAlternate!
                for _ in 0..<backspaceNumber {
                    copyQuoteAlternate.append(" ")
                }
                //add a line for avoiding out of bounds when cutting string
                for _ in 0..<config.maxCharDefault! {
                    copyQuoteDefault.append(" ")
                }
            }else {
                let backspaceNumber = (linesQuoteAlternate - linesQuoteDefault + 1) * config.maxCharDefault!
                for _ in 0..<backspaceNumber {
                    copyQuoteDefault.append(" ")
                }
                //add a line for avoiding out of bounds when cutting string
                for _ in 0..<config.maxCharAlternate! {
                    copyQuoteAlternate.append(" ")
                }
            }
            for _ in 0..<max(linesQuoteDefault, linesQuoteAlternate) {
                addToResult(i, j)
                //Avoid repeating to add the last character of last part.
                i += config.maxCharDefault! + 1
                j += config.maxCharAlternate! + 1
            }
            return result
        }
        print("---")
        if alternateContent != nil {
            print(AddAPIForParallelQuote(quoteDefault: defaultContent, quoteAlternate: alternateContent!), terminator:"")
        }else {
            print(AddAPIForSingleQuote(quote: defaultContent), terminator:"")
        }
        for _ in 0..<(config.backspaceNumberForwardFrom ?? (config.maxCharDefault! - from!.count)) {
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

quoteContent.generateQuoteListFromResourcesFile(file: locationResourcesFileURL!)

print("📖")

print("---\n","Pinned")
if config.pinQuote != nil {
    for i in config.pinQuote! {
        quoteContent.quoteContentList[i].displayContent()
    }
}
print("---\n","Ramdom")
var randomQuote = quoteContent.getRandomQuote()
if config.pinQuote != nil {
    while config.pinQuote!.contains(randomQuote.serial) {
        randomQuote = quoteContent.getRandomQuote()
    }
}
randomQuote.content.displayContent()
print("---\n","open resources| bash='open \(locationResourcesFile)' terminal=true")
print("---\n","reload | refresh=true ")


