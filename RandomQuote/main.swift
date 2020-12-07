//
//  main.swift
//  RandomQuote
//
//  Created by Xin Liu on 12/7/20.
//

import Foundation

var quoteList: [String] = []
let maxChar = 30
let quoteColor = "#C46243"
let fontSize = 13
let bitbarAPI = "| color=\(quoteColor) length=\(maxChar) size=\(fontSize)\n"

func initializationQuoteList() {
    quoteList.append("你们要逃避淫行。人所犯的,无论什么罪,都身子以外,惟有行淫的,是得罪自己的身子.")
    quoteList.append("只是我告诉你们,凡看见妇女就动淫念的,这人心里已经与她犯奸淫了。若是你的右眼叫你跌倒,就剜出来丢掉,宁可失去百体中的一体,不叫全身丢在地狱里。若是右手叫你跌倒,就砍下来丢掉,宁可失去百体中的一体,不叫全身下入地狱。")
}

func processQuoteToSeveralLine(quoteSentence: String) -> String {
    var result: String = quoteSentence
    let lengthOfBitbarAPI = bitbarAPI.count
    let lengthOfQuoteSentence = quoteSentence.count
    var i = maxChar, n = maxChar
    while n < lengthOfQuoteSentence {
        let insertIndex = result.index(result.startIndex, offsetBy: i)
        result.insert(contentsOf: bitbarAPI, at: insertIndex)
        i += maxChar + lengthOfBitbarAPI
        n += maxChar
    }
    result.append(bitbarAPI)
    return result
}

func displayQuote(Serial: Int) {
    print("---")
    print(processQuoteToSeveralLine(quoteSentence: quoteList[Serial]))
}

initializationQuoteList()
print("📖")
displayQuote(Serial: 0)
displayQuote(Serial: 1)
print("---\n","Ramdom | size=10 color=#006284")
let amountOfQuoteList = quoteList.count
let ramdomSerial = Int.random(in: 0..<amountOfQuoteList)
displayQuote(Serial: ramdomSerial)
