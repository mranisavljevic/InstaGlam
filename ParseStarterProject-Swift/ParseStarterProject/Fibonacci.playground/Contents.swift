//: Playground - noun: a place where people can play

import UIKit

func fibonacci(first: Double, second: Double) -> [Double] {
    var sequence = [Double]()
    sequence.append(first)
    sequence.append(second)
    print(sequence.count)
    while sequence.count < 100 {
        let next = sequence[sequence.count - 1] + sequence[sequence.count - 2]
        sequence.append(next)
        print(next)
    }
    return sequence
}

fibonacci(1, second: 1)


func fibonacciAlternate(first: Double, second: Double) -> (Double, Double) {
    var newDouble = 0.0
    var sequenceSegment = (first, second)
    for _ in 1...98 {
            newDouble = sequenceSegment.0 + sequenceSegment.1
            sequenceSegment.0 = sequenceSegment.1
            sequenceSegment.1 = newDouble
    }
    return sequenceSegment
}

fibonacciAlternate(1, second: 1)
