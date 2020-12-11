import Foundation

let maxCharDefault = 60
let maxCharAlternate = 35
let quoteColor = "#C46243"
let fontSize = 13
let bitbarAPI = "| color=\(quoteColor) length=\(maxCharDefault) size=\(fontSize)\n"
let bitbarAlternateAPI = "| color=\(quoteColor) length=\(maxCharDefault) size=\(fontSize) alternate=true\n"

struct quoteContent {
    static var quoteContentList: [quoteContent] = []
    static func getRandomQuote() -> quoteContent {
        let amountOfList = quoteContentList.count
        let randomSerial = Int.random(in: 0..<amountOfList)
        return quoteContentList[randomSerial]
    }
    
    var defaultContent: String
    var alternateContent: String?
    var from: String

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
        for _ in 0..<(maxCharDefault - from.count) {
            print(" ", terminator:"")
        }
        print("--",from,"| trim=false")
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

