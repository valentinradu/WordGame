//
//  UIColor+Random.swift
//  WPDash
//
//  Created by Valentin Radu on 09/06/16.
//  Copyright © 2016 Valentin Radu. All rights reserved.
//

import UIKit

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red:   .random(0.0, upper:1.0),
                       green: .random(0.0, upper:1.0),
                       blue:  .random(0.0, upper:1.0),
                       alpha: 1.0)
    }
}