//
//  RandomQuote
//  main.swift
//
//  Created by Xin Liu on 12/7/20.
//  Copyright @2020 Xin Liu, All rights reserved.
//
import Foundation


//set the config file path,please replace it with your file path!!!
let markdownIsPrior = true
let locationMarkdown = "file:///Users/xinliu/Dropbox/Bitbar-Plugins/quoteResources/resources.md"
let locationJson = "file:///Users/xinliu/Dropbox/Bitbar-Plugins/quoteResources/resources.json"
let locationCongfig = "file:///Users/xinliu/Dropbox/Bitbar-Plugins/quoteResources/config.json"

//divider

//Initialize the config
if URL(string: locationCongfig) == nil {
    print("File path is ircorrect")
    exit(1)
}
var config = Config.init(from: URL(string: locationCongfig)!)
var configDefault = Config.init(lengthOfDefaultContent: 60, lengthOfAlternateContent: 60, fontColor: "#C46243", fontSize: 13, fontKind: "Courier", backspaceNumberForwardFrom: 60)

//bitbarapi struct
let bitbarAPI = "| color=\(config.fontColor ?? configDefault.fontColor!) length=\((config.lengthOfDefaultContent ?? configDefault.lengthOfDefaultContent!)+1) size=\(config.fontSize ?? configDefault.fontSize!) font=\(config.fontKind ?? configDefault.fontKind!)\n"
let bitbarAlternateAPI = "| color=\(config.fontColor ?? configDefault.fontColor!) length=\((config.lengthOfDefaultContent ?? configDefault.lengthOfDefaultContent!)+1) size=\(config.fontSize ?? configDefault.fontSize!) font=\(config.fontKind ?? configDefault.fontKind!) alternate=true\n"

//divider

//Initialize the quote list
if URL(string: locationMarkdown) == nil && URL(string: locationJson) == nil {
    print("NO resources")
    exit(1)
}else if URL(string: locationMarkdown) != nil && URL(string: locationJson) == nil{
    QuoteContent.generateQuoteListFromMarkDownFile(from: URL(string: locationMarkdown)!)
}else if URL(string: locationMarkdown) == nil && URL(string: locationJson) != nil{
    QuoteContent.generateQuoteListFromJSON(from: URL(string: locationJson)!)
}else {
    if markdownIsPrior {
        QuoteContent.generateQuoteListFromMarkDownFile(from: URL(string: locationMarkdown)!)
    }else {
        QuoteContent.generateQuoteListFromJSON(from: URL(string: locationJson)!)
    }
}

//divider

//Send notification at specific time use Apple script
let osascript = Process()
osascript.launchPath = "/usr/bin/osascript"
osascript.arguments = ["-e display notification \"\(config.notificationContent ?? "")\" with title \"RandomQuote\" sound name \"Frog\""]
//get the current time to judge if send notification
//PS:To make the function working normally,please run the script once per hour
let currentDate = Date()
let calendar = Calendar.current
let currentHours = calendar.component(.hour, from: currentDate)

//set the config file path,please replace it with your file path!!!
let locationResourcesFile = "file:///Users/xinliu/Dropbox/Bitbar-Plugins/quoteResources/resources.txt"
let locationCongfig = "file:///Users/xinliu/Dropbox/Bitbar-Plugins/quoteResources/config"

//make sure the file path is right
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
    var notificationHourList: [Int]?
    init(file fileURL: URL) {
        let wholeContentOfConfig = try! String(contentsOf: fileURL, encoding: .utf8)
        let singleLineOfConfig = wholeContentOfConfig.split(separator: "\n")

        let configFactorList = ["maxCharDefault",
                                "maxCharAlternate",
                                "quoteColor",
                                "fontSize",
                                "fontKind",
                                "pinQuote",
                                "backspaceNumberForwardFrom",
                                "notificationHourList",]
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
                            
                        case configFactorList[7]:
                            self.notificationHourList = []
                            let ToString = String(ConfigFactorAndValue[1])
                            var temp = ToString.firstIndex(of: "[")
                            let indexStart = ToString.index(temp!, offsetBy: 1)
                            temp = ToString.firstIndex(of: "]")
                            let indexEnd = ToString.index(temp!, offsetBy: -1)
                            let notificationHourListString = ToString[indexStart...indexEnd].split(separator: ",")
                            for i in 0..<notificationHourListString.count {
                                self.notificationHourList?.append(Int(String(notificationHourListString[i]))!)
                            }
                        default:
                            print("Error")
                    }
                }
            }
        }
    }
}
var config = configFile.init(file: locationCongfigURL!)
//var config = configFile.init(maxCharDefault: defaultMaxCharDefault, maxCharAlternate: defaultMaxCharAlternate, quoteColor: defaultQuoteColor, fontSize: defautlFontSize)

let bitbarAPI = "| color=\(config.quoteColor ?? defaultQuoteColor) length=\((config.maxCharDefault ?? defaultMaxCharDefault)+1) size=\(config.fontSize ?? defautlFontSize) font=\(config.fontKind ?? defaultFont)\n"
let bitbarAlternateAPI = "| color=\(config.quoteColor ?? defaultQuoteColor) length=\((config.maxCharDefault ?? defaultMaxCharAlternate)+1) size=\(config.fontSize ?? defautlFontSize) font=\(config.fontKind ?? defaultFont) alternate=true\n"

//Send notification at specific time use Apple script
let task = Process()
task.launchPath = "/usr/bin/osascript"
task.arguments = ["-e display notification \"Bible Time.\" with title \"RandomQuote\" sound name \"Frog\""]

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

//divider

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
    let pinQuote = config.pinQuote?.map{ $0 - 1 }
    while pinQuote!.contains(randomQuote.serial) {
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

print("---\n","open file| bash='open \(locationMarkdown)' terminal=true")
print("---\n","reload | refresh=true ")

