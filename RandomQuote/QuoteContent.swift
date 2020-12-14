//
//  QuoteContent.swift
//  RandomQuote
//
//  Created by Xin Liu on 12/14/20.
//

import Foundation

struct QuoteContent: Codable {
    var defaultContent: String
    var alternateContent: String?
    var from: String?
    
    //preposition: config, configDefault : Config
    //preposition: bitbarAPI
    func displayContent() {
        func AddAPIForSingleQuote(content: String) -> String {
            var result: String = content
            let lengthOfBitbarAPI = bitbarAPI.count
            let lengthOfQuoteSentence = content.count
            var i = config.lengthOfDefaultContent!, n = config.lengthOfDefaultContent!
            while n < lengthOfQuoteSentence {
                let insertIndex = result.index(result.startIndex, offsetBy: i)
                result.insert(contentsOf: bitbarAPI, at: insertIndex)
                i += config.lengthOfDefaultContent! + lengthOfBitbarAPI
                n += config.lengthOfDefaultContent!
            }
            result.append(bitbarAPI)
            return result
        }
        func AddAPIForParallelQuote(quoteDefault: String, quoteAlternate: String) -> String {
            var result: String = ""
            var copyQuoteDefault = quoteDefault, copyQuoteAlternate = quoteAlternate
            let lengthQuoteDefault = quoteDefault.count
            let lengthQuoteAlternate = quoteAlternate.count
            let linesQuoteDefault = Int( (Double(lengthQuoteDefault) / Double(config.lengthOfDefaultContent ?? configDefault.lengthOfDefaultContent!)) + 1.0 )
            let linesQuoteAlternate = Int( (Double(lengthQuoteAlternate) / Double(config.lengthOfAlternateContent ?? configDefault.lengthOfAlternateContent!)) + 1.0 )
            var i = config.lengthOfDefaultContent ?? configDefault.lengthOfDefaultContent!, j = config.lengthOfAlternateContent ?? configDefault.lengthOfAlternateContent!
            func addToResult(_ i: Int,_ j: Int) {
                let indexDefault = copyQuoteDefault.index(copyQuoteDefault.startIndex, offsetBy: i)
                let lastIndexDefault = copyQuoteDefault.index(indexDefault, offsetBy: -(config.lengthOfDefaultContent ?? configDefault.lengthOfDefaultContent!))
                let indexAlternate = copyQuoteAlternate.index(copyQuoteAlternate.startIndex, offsetBy: j)
                let lastIndexAlternate = copyQuoteAlternate.index(indexAlternate, offsetBy: -(config.lengthOfAlternateContent ?? configDefault.lengthOfAlternateContent!))
                let tempDefault = copyQuoteDefault[lastIndexDefault...indexDefault]
                let tempAlternate = copyQuoteAlternate[lastIndexAlternate...indexAlternate]
                result.append(contentsOf: tempDefault)
                result.append(bitbarAPI)
                result.append(contentsOf: tempAlternate)
                result.append(bitbarAlternateAPI)
            }
            //add backspace to make two quotes same as the number of lines
            if linesQuoteDefault > linesQuoteAlternate {
                let backspaceNumber = (linesQuoteDefault - linesQuoteAlternate + 1) * (config.lengthOfAlternateContent ?? configDefault.lengthOfAlternateContent! + 1)
                for _ in 0..<backspaceNumber {
                    copyQuoteAlternate.append(" ")
                }
                //add a line for avoiding out of bounds when cutting string
                for _ in 0...(config.lengthOfDefaultContent ?? configDefault.lengthOfDefaultContent! + max(linesQuoteDefault, linesQuoteAlternate) ) {
                    copyQuoteDefault.append(" ")
                }
            }else if linesQuoteDefault < linesQuoteAlternate {
                let backspaceNumber = (linesQuoteAlternate - linesQuoteDefault + 1) * (config.lengthOfDefaultContent ?? configDefault.lengthOfDefaultContent! + 1)
                for _ in 0..<backspaceNumber {
                    copyQuoteDefault.append(" ")
                }
                //add a line for avoiding out of bounds when cutting string
                for _ in 0...(config.lengthOfAlternateContent ?? configDefault.lengthOfAlternateContent! + max(linesQuoteDefault, linesQuoteAlternate) ) {
                    copyQuoteAlternate.append(" ")
                }
            }else {
                for _ in 0...(config.lengthOfDefaultContent ?? configDefault.lengthOfDefaultContent! + max(linesQuoteDefault, linesQuoteAlternate) ) {
                    copyQuoteDefault.append(" ")
                }
                for _ in 0...(config.lengthOfAlternateContent ?? configDefault.lengthOfAlternateContent! + max(linesQuoteDefault, linesQuoteAlternate) ) {
                    copyQuoteAlternate.append(" ")
                }
            }
            for _ in 0..<max(linesQuoteDefault, linesQuoteAlternate) {
                addToResult(i, j)
                //Avoid repeating to add the last character of last part.
                i += config.lengthOfDefaultContent ?? configDefault.lengthOfDefaultContent! + 1
                j += config.lengthOfAlternateContent ?? configDefault.lengthOfAlternateContent! + 1
            }
            return result
        }
        print("---")
        if alternateContent != nil {
            print(AddAPIForParallelQuote(quoteDefault: defaultContent, quoteAlternate: alternateContent!), terminator:"")
        }else {
            print(AddAPIForSingleQuote(content: defaultContent), terminator:"")
        }
        if from != nil {
            for _ in 0..<(config.backspaceNumberForwardFrom ?? (config.lengthOfDefaultContent ?? configDefault.lengthOfDefaultContent! - from!.count)) {
                print(" ", terminator:"")
            }
            print("--",from!,"| trim=false")
        }
    }
    
    init(defaultContent: String) {
        self.defaultContent = defaultContent
    }
    init(defaultContent: String,from: String) {
        self.defaultContent = defaultContent
        self.from = from
    }
    init(defaultContent: String, alternateContent: String) {
        self.defaultContent = defaultContent
        self.alternateContent = alternateContent
    }
    init(defaultContent: String, alternateContent: String, from: String) {
        self.defaultContent = defaultContent
        self.alternateContent = alternateContent
        self.from = from
    }
    
    static var quoteContentList: [QuoteContent] = []
    static func getRandomQuote() -> (content: QuoteContent,serial: Int) {
        let amountOfList = quoteContentList.count
        let randomSerial = Int.random(in: 0..<amountOfList)
        return (quoteContentList[randomSerial], randomSerial)
    }
    static func generateQuoteListFromMarkDownFile(from mdURL: URL) {
        func generateQuote(_ content: [String.SubSequence]) {
            var copyOfContent = content
            var temp: QuoteContent
            switch content.count {
                case 2:
                    copyOfContent[1].removeAll(where: { $0 == "\n" })
                    temp = QuoteContent.init(defaultContent: String(copyOfContent[1]))
                    QuoteContent.quoteContentList.append(temp)
                case 3:
                    copyOfContent[1].removeAll(where: { $0 == "\n" })
                    copyOfContent[2].removeAll(where: { $0 == "_" || $0 == "\n" })
                    if content[2].contains("__") {
                        temp = QuoteContent.init(defaultContent: String(copyOfContent[1]), from: String(copyOfContent[2]))
                    }else {
                        temp = QuoteContent.init(defaultContent: String(copyOfContent[1]), alternateContent: String(copyOfContent[2]))
                    }
                    QuoteContent.quoteContentList.append(temp)
                case 4:
                    copyOfContent[1].removeAll(where: { $0 == "\n" })
                    copyOfContent[2].removeAll(where: { $0 == "_" || $0 == "\n" })
                    copyOfContent[3].removeAll(where: { $0 == "_" || $0 == "\n" })
                    temp = QuoteContent.init(defaultContent: String(copyOfContent[1]), alternateContent: String(copyOfContent[2]), from: String(copyOfContent[3]))
                    QuoteContent.quoteContentList.append(temp)
                default:
                    var _ = "doNothing"
            }
        }
        do {
            let wholeContentOfFile = try String(contentsOf: mdURL, encoding: .utf8)
            let splitWholeContentOfFile = wholeContentOfFile.components(separatedBy: "\n\n")
            for oneQuoteContent in splitWholeContentOfFile {
                let partOfOneQuoteContent = oneQuoteContent.split(separator: "*")
                generateQuote(partOfOneQuoteContent)
            }
        }catch {
            print("Error:Failed to read resources.txt")
        }
    }
    static func generateQuoteListFromJSON(from jsonURL: URL) {
        do {
            let jsonString = try String(contentsOf: jsonURL, encoding: .utf8)
            let jsonData = Data(jsonString.utf8)
            let decoder = JSONDecoder()
            self.quoteContentList = try decoder.decode([QuoteContent].self, from: jsonData)
        }catch {
            print(error.localizedDescription)
        }
    }
}
