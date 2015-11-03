//: Playground - noun: a place where people can play

import UIKit

var numberArray = [Int]()

for i in 0...100 {
    numberArray.append(i)
}

func returnOddNumbers(numbers: [Int]) -> [Int] {
    var oddNumbers = [Int]()
    for i in numbers {
        if i % 2 != 0 {
            oddNumbers.append(i)
        }
    }
    return oddNumbers
}


print(returnOddNumbers(numberArray))
