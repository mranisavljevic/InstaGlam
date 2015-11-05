//: Playground - noun: a place where people can play

import UIKit

//This would compute the first 100 numbers correctly, but trying an error is thrown if
//the array goes above 92 items, maybe because the numbers go above maxInt?

func fibonacci(first: Int, second: Int) -> [Int] {
    var sequence = [Int]()
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

//fibonacci(1, second: 1)


//Here's an alternate version that returns only the last two numbers, which are all
//that are needed to continue calculating the sequence.  Still fails after the same
//number of iterations.  maxInt?

func fibonacciAlternate(first: Int, second: Int) -> (Int, Int) {
    var newInt = 0
    var sequenceSegment = (first, second)
    for _ in 1...98 {
        if sequenceSegment.0 + sequenceSegment.1 < Int.max {
            newInt = sequenceSegment.0 + sequenceSegment.1
            sequenceSegment.0 = sequenceSegment.1
            sequenceSegment.1 = newInt
        }
    }
    return sequenceSegment
}

//fibonacciAlternate(1, second: 1)
