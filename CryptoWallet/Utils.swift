//
//  Utils.swift
//  CryptoWallet
//
//  Created by Allen Melikian on 2/1/23.
//

import Foundation
import UIKit

public func noMissingWords(twelveWords: [UITextField]) -> Bool {
    
    for word in twelveWords {
        if(word.text == "") {
            return false;
        }
    }
    return true;
}
