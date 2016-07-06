//
//  Swift+Base.swift
//  CustomList
//
//  Created by Valentin Radu on 08/03/16.
//  Copyright © 2016 Valentin Radu. All rights reserved.
//

import Foundation
import CoreGraphics

protocol Addable {
    func + (lhs: Self, rhs: Self) -> Self
}

protocol Substractable {
    func - (lhs: Self, rhs: Self) -> Self
}

protocol Divideable {
    func / (lhs: Self, rhs: Self) -> Self
}

protocol Multipliable {
    func * (lhs: Self, rhs: Self) -> Self
}

protocol IntegerConvertible {
    init(_ value: UInt8)
    init(_ value: Int8)
    init(_ value: UInt16)
    init(_ value: Int16)
    init(_ value: UInt32)
    init(_ value: Int32)
    init(_ value: UInt64)
    init(_ value: Int64)
    init(_ value: UInt)
    init(_ value: Int)
}

protocol FloatingPointConvertible{
    init(_ value: Float)
    init(_ value: Double)
}

protocol Arithmeticable:Addable, Substractable, Divideable, Multipliable {}

extension CGFloat   : Arithmeticable, IntegerConvertible, FloatingPointConvertible {}
extension Float     : Arithmeticable, IntegerConvertible, FloatingPointConvertible {}
extension Double    : Arithmeticable, IntegerConvertible, FloatingPointConvertible {}
extension String    : Addable {}

protocol Randomable {
    static func random (lower: Self , upper: Self) -> Self
}

extension Randomable where Self:Comparable, Self:Arithmeticable, Self:IntegerConvertible, Self:FloatingPointType {
    static func random(lower: Self, upper: Self) -> Self {
        assert(lower < upper)
        let r = Self(arc4random_uniform(UInt32.max)) / Self((UInt32.max))
        let s = upper - lower
        return lower + r * s
    }
}

extension CGFloat:Randomable {}
extension Double:Randomable {}
extension Float:Randomable {}

extension Comparable {
    func clamp(lower: Self, upper: Self) -> Self {
        return min(max(self, lower), upper)
    }
}

extension CollectionType {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}