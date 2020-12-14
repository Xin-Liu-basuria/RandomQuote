//
//  RandomQuote
//  main.swift
//
//  Created by Xin Liu on 12/7/20.
//  Copyright @2020 Xin Liu, All rights reserved.
//
import Foundation

//set the config file path,please replace it with your file path!!!
let locationResourcesFile = "file:///Users/xinliu/Dropbox/Bitbar-Plugins/quoteResources/resources.txt"
let locationCongfig = "file:///Users/xinliu/Dropbox/Bitbar-Plugins/quoteResources/config.json"
//make sure the file path is right
if URL(string: locationResourcesFile) == nil {
    print("File path is ircorrect")
    exit(1)
}
if URL(string: locationCongfig) == nil {
    print("File path is ircorrect")
    exit(1)
}
let locationResourcesFileURL = URL(string: locationResourcesFile)
let locationCongfigURL = URL(string: locationCongfig)

struct Config: Codable {
    //those are must and have an default config inside code even you don't set
    var lengthOfDefaultContent: Int?
    var lengthOfAlternateContent: Int?
    var fontColor: String?
    var fontSize: Int?
    var fontKind: String?
    var backspaceNumberForwardFrom: Int?
    //those are optional and don't have an default config
    var pinQuote: [Int]?
    var notificationHourList: [Int]?
    var notificationContent: String?
    
    //for custom config
    init(from jsonURL: URL) {
        let jsonString = try! String(contentsOf: jsonURL, encoding: .utf8)
        let jsonData = Data(jsonString.utf8)
        let decoder = JSONDecoder()
        self = try! decoder.decode(Config.self, from: jsonData)
    }
    //for default config
    init(lengthOfDefaultContent: Int, lengthOfAlternateContent: Int, fontColor: String, fontSize: Int, fontKind: String, backspaceNumberForwardFrom: Int) {
        self.lengthOfDefaultContent = lengthOfDefaultContent
        self.lengthOfAlternateContent = lengthOfAlternateContent
        self.fontColor = fontColor
        self.fontSize = fontSize
        self.fontKind = fontKind
        self.backspaceNumberForwardFrom = backspaceNumberForwardFrom
    }
}
var config = Config.init(from: locationCongfigURL!)
var configDefault = Config.init(lengthOfDefaultContent: 60, lengthOfAlternateContent: 60, fontColor: "#C46243", fontSize: 13, fontKind: "Courier", backspaceNumberForwardFrom: 60)

let bitbarAPI = "| color=\(config.fontColor ?? configDefault.fontColor!) length=\((config.lengthOfDefaultContent ?? configDefault.lengthOfDefaultContent!)+1) size=\(config.fontSize ?? configDefault.fontSize!) font=\(config.fontKind ?? configDefault.fontKind!)\n"
let bitbarAlternateAPI = "| color=\(config.fontColor ?? configDefault.fontColor!) length=\((config.lengthOfDefaultContent ?? configDefault.lengthOfDefaultContent!)+1) size=\(config.fontSize ?? configDefault.fontSize!) font=\(config.fontKind ?? configDefault.fontKind!) alternate=true\n"

struct QuoteContent {
    var defaultContent: String
    var alternateContent: String?
    var from: String?
    
    mutating func displayContent() {
        func AddAPIForSingleQuote(quote: String) -> String {
            var result: String = quote
            let lengthOfBitbarAPI = bitbarAPI.count
            let lengthOfQuoteSentence = quote.count
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
            let linesQuoteDefault = Int( (Double(lengthQuoteDefault) / Double(config.lengthOfDefaultContent!)) + 1.0 )
            let linesQuoteAlternate = Int( (Double(lengthQuoteAlternate) / Double(config.lengthOfAlternateContent!)) + 1.0 )
            var i = config.lengthOfDefaultContent!, j = config.lengthOfAlternateContent!
            func addToResult(_ i: Int,_ j: Int) {
                let indexDefault = copyQuoteDefault.index(copyQuoteDefault.startIndex, offsetBy: i)
                let lastIndexDefault = copyQuoteDefault.index(indexDefault, offsetBy: -config.lengthOfDefaultContent!)
                let indexAlternate = copyQuoteAlternate.index(copyQuoteAlternate.startIndex, offsetBy: j)
                let lastIndexAlternate = copyQuoteAlternate.index(indexAlternate, offsetBy: -config.lengthOfAlternateContent!)
                let tempDefault = copyQuoteDefault[lastIndexDefault...indexDefault]
                let tempAlternate = copyQuoteAlternate[lastIndexAlternate...indexAlternate]
                result.append(contentsOf: tempDefault)
                result.append(bitbarAPI)
                result.append(contentsOf: tempAlternate)
                result.append(bitbarAlternateAPI)
            }
            //add backspace to make two quotes same as the number of lines
            if linesQuoteDefault > linesQuoteAlternate {
                let backspaceNumber = (linesQuoteDefault - linesQuoteAlternate + 1) * (config.lengthOfAlternateContent! + 1)
                for _ in 0..<backspaceNumber {
                    copyQuoteAlternate.append(" ")
                }
                //add a line for avoiding out of bounds when cutting string
                for _ in 0...(config.lengthOfDefaultContent! + max(linesQuoteDefault, linesQuoteAlternate) ) {
                    copyQuoteDefault.append(" ")
                }
            }else if linesQuoteDefault < linesQuoteAlternate {
                let backspaceNumber = (linesQuoteAlternate - linesQuoteDefault + 1) * (config.lengthOfDefaultContent! + 1)
                for _ in 0..<backspaceNumber {
                    copyQuoteDefault.append(" ")
                }
                //add a line for avoiding out of bounds when cutting string
                for _ in 0...(config.lengthOfAlternateContent! + max(linesQuoteDefault, linesQuoteAlternate) ) {
                    copyQuoteAlternate.append(" ")
                }
            }else {
                for _ in 0...(config.lengthOfDefaultContent! + max(linesQuoteDefault, linesQuoteAlternate) ) {
                    copyQuoteDefault.append(" ")
                }
                for _ in 0...(config.lengthOfAlternateContent! + max(linesQuoteDefault, linesQuoteAlternate) ) {
                    copyQuoteAlternate.append(" ")
                }
            }
            for _ in 0..<max(linesQuoteDefault, linesQuoteAlternate) {
                addToResult(i, j)
                //Avoid repeating to add the last character of last part.
                i += config.lengthOfDefaultContent! + 1
                j += config.lengthOfAlternateContent! + 1
            }
            return result
        }
        print("---")
        if alternateContent != nil {
            print(AddAPIForParallelQuote(quoteDefault: defaultContent, quoteAlternate: alternateContent!), terminator:"")
        }else {
            print(AddAPIForSingleQuote(quote: defaultContent), terminator:"")
        }
        for _ in 0..<(config.backspaceNumberForwardFrom ?? (config.lengthOfDefaultContent! - from!.count)) {
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
    static var quoteContentList: [QuoteContent] = []
    static func getRandomQuote() -> (content: QuoteContent,serial: Int) {
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
                quoteContentList.append(QuoteContent.init(defaultContent: content))
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
    static func generateQuoteListFromJSON(from jsonURL: URL) {
        
    }
}



//Initialize the quote list
QuoteContent.generateQuoteListFromResourcesFile(file: locationResourcesFileURL!)

//Send notification at specific time use Apple script
let osascript = Process()
osascript.launchPath = "/usr/bin/osascript"
osascript.arguments = ["-e display notification \"\(config.notificationContent ?? "")\" with title \"RandomQuote\" sound name \"Frog\""]
//get the current time to judge if send notification
//PS:To make the function working normally,please run the script once per hour
let currentDate = Date()
let calendar = Calendar.current
let currentHours = calendar.component(.hour, from: currentDate)

var whetherNotification: Bool = false
if config.notificationHourList != nil {
    for hour in config.notificationHourList! {
        if currentHours == hour {
            whetherNotification = true
        }
    }
}
if whetherNotification {
    osascript.launch()
}

print("📖")

if config.pinQuote != nil {
    print("---\n","Pinned")
    for i in config.pinQuote! {
        QuoteContent.quoteContentList[i].displayContent()
    }
}

//get the random quote which doesn't display
var randomQuote = QuoteContent.getRandomQuote()
if config.pinQuote != nil {
    var tryTimes = 0
    while config.pinQuote!.contains(randomQuote.serial) {
        randomQuote = QuoteContent.getRandomQuote()
        //Avoid being dead circle
        tryTimes += 1
        if tryTimes > 10 {
            break
        }
    }
}
print("---\n","Ramdom")
randomQuote.content.displayContent()

print("---\n","open file| bash='open \(locationResourcesFile)' terminal=true")
print("---\n","reload | refresh=true ")

