//
//  ColorManager.swift
//  Mpl.
//
//  Created by Darius Martin on 05/04/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit
import Foundation

extension UIColor {
    static let concreteGray = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 255/255)
}

class ColorManager {
    
    static public func getColor(color: UIColor, dark: Bool) -> UIColor {
        if !dark { return color }
        return getDarkColor(of: color)
    }
    
    static public func getDarkColor(of color: UIColor) -> UIColor {
        let components = color.cgColor.components
        
        print("coucou get dark color")
        print(components!)
        if components == nil || components?.count != 4 { return UIColor.clear }
        let red = 1-components![0]
        let green = 1-components![1]
        let blue = 1-components![2]
        let alpha = components![3]
        
        print(red, green, blue, alpha)
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
}
