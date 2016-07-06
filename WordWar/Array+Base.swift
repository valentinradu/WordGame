//
//  Array+Base.swift
//  CoreDataWebService
//
//  Created by Valentin Radu on 13/10/15.
//  Copyright © 2015 Valentin Radu. All rights reserved.
//

import Foundation

extension Array {
    func objectAtIndex(index:Int) -> Element? {
        return 0 <= index && index < count ? self[index] : nil
    }
    
    public func nullify() -> Array? {
        if self.count == self.startIndex.distanceTo(self.startIndex) {
            return nil
        }
        else {
            return self
        }
    }
}