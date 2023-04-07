//
//  Utils.swift
//  CryptoWallet
//
//  Created by Ashot Alajanyan on 3/26/23.
//

import Foundation
import SwiftUI

public func noMissingWords(twelveWords: [String]) -> Bool {
    
    for word in twelveWords {
        if(word == "") {
            return false;
        }
    }
    return true;
}
