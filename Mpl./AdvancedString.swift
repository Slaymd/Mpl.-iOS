//
//  AdvancedString.swift
//  Mpl.
//
//  Created by Darius Martin on 31/12/2017.
//  Copyright © 2017 Darius MARTIN. All rights reserved.
//

import Foundation

extension String {
    
    func toASCII() -> String {
        return self.folding(options: .diacriticInsensitive, locale: NSLocale.current)
    }
    
}
