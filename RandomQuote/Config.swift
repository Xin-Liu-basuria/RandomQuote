//
//  Config.swift
//  RandomQuote
//
//  Created by Xin Liu on 12/14/20.
//

import Foundation

struct Config: Codable {
    //those are must and have an default config inside code even you don't set
    var lengthOfDefaultContent: Int?
    var lengthOfAlternateContent: Int?
    var fontColor: String?
    var fontSize: Int?
    var fontKind: String?
    var backspaceNumberForwardFrom: Int?
    var markdownIsPrior = true
    //those are optional and don't have an default config
    var pinQuote: [Int]?
    var notificationHourList: [Int]?
    var notificationContent: String?
    
    //for custom config
    init(from jsonURL: URL) {
        do {
            let jsonString = try String(contentsOf: jsonURL, encoding: .utf8)
            let jsonData = Data(jsonString.utf8)
            let decoder = JSONDecoder()
            self = try decoder.decode(Config.self, from: jsonData)
        }catch {
            print(error.localizedDescription)
        }
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

//bitbarapi struct
let bitbarAPI = "| color=\(config.fontColor ?? configDefault.fontColor!) length=\((config.lengthOfDefaultContent ?? configDefault.lengthOfDefaultContent!)+1) size=\(config.fontSize ?? configDefault.fontSize!) font=\(config.fontKind ?? configDefault.fontKind!)\n"
let bitbarAlternateAPI = "| color=\(config.fontColor ?? configDefault.fontColor!) length=\((config.lengthOfDefaultContent ?? configDefault.lengthOfDefaultContent!)+1) size=\(config.fontSize ?? configDefault.fontSize!) font=\(config.fontKind ?? configDefault.fontKind!) alternate=true\n"
