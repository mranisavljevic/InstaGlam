//: Playground - noun: a place where people can play

import UIKit

func testForPalindrome(word: String) -> Bool {
    let stringArray = Array(word.lowercaseString.characters)
    for i in 0..<stringArray.count {
        if stringArray[i] != stringArray[stringArray.count - 1 - i] {
            return false
        }
    }
    return true
}

let wordToTest = "tacocat"

let answer = testForPalindrome(wordToTest)

let anotherWord = "palindrome"

let anotherAnswer = testForPalindrome(anotherWord)
