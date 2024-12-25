//
//  UIColor+Etoile.swift
//  etoile
//
//  Created by Juliette Bernheisel on 8/22/24.
//

import Foundation
import UIKit

extension UIColor {
    class func etoileBackground() -> UIColor {
        guard let toReturn = ConfigurationSingleton.shared.backgroundColors.first else {
            return UIColor(red: 0.18, green: 0.15, blue: 0.15, alpha: 1.00)
        }
        return toReturn
    }
    
    class func etoileTextColor() -> UIColor {
        return UIColor(red: 1.00, green: 0.96, blue: 0.89, alpha: 1.00)
    }
    
    class func etoileButtonBackground() -> UIColor {
        return UIColor(red: 0.56, green: 0.26, blue: 0.93, alpha: 1.00)
    }
    
    class func etoileSecondaryTextColor() -> UIColor {
        return UIColor(red: 0.58, green: 0.55, blue: 0.52, alpha: 1.00)
    }
}
