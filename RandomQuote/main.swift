//
//  RandomQuote
//  main.swift
//
//  Created by Xin Liu on 12/7/20.
//  Copyright @2020 Xin Liu, All rights reserved.
//
import Foundation


//set the config file path,please replace it with your file path!!!
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
    if config.markdownIsPrior {
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
    let pinQuote = config.pinQuote?.map{ $0 - 1 }
    for i in pinQuote! {
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

