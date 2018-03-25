//
//  AdvancedString.swift
//  Mpl.
//
//  Created by Darius Martin on 31/12/2017.
//  Copyright © 2017 Darius MARTIN. All rights reserved.
//

import Foundation
import WebKit

extension String {
    
    func toASCII() -> String {
        return self.folding(options: .diacriticInsensitive, locale: NSLocale.current)
    }
    
    init?(htmlEncodedString: String) {
        
        guard let data = htmlEncodedString.data(using: .utf8) else {
            return nil
        }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            NSAttributedString.DocumentReadingOptionKey(rawValue: NSAttributedString.DocumentAttributeKey.documentType.rawValue): NSAttributedString.DocumentType.html,
            NSAttributedString.DocumentReadingOptionKey(rawValue: NSAttributedString.DocumentAttributeKey.characterEncoding.rawValue): String.Encoding.utf8.rawValue
        ]
        
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return nil
        }
        
        self.init(attributedString.string)
    }
    
}
