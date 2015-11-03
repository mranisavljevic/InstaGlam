//: Playground - noun: a place where people can play

import UIKit

let sentence = "Beauty is mysterious as well as terrible. God and devil are fighting there, and the battlefield is the heart of man."

func countWords(sentence: String) -> Int {
    var wordCounter = 1
    let sentenceArray = sentence.characters
    if sentenceArray.last == " " {
        wordCounter = 0
    }
    for letter in Array(sentenceArray) {
        if letter == " " {
            wordCounter++
        }
    }
    return wordCounter
}

countWords(sentence)

var nums = [Int]()
for i in (0...600) {
    nums.append(i)
}

nums[600]

