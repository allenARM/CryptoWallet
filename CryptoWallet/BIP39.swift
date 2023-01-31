//
//  BIP39.swift
//  CryptoWallet
//
//  Created by Allen Melikian on 1/25/23.
//

import Foundation
import Bip39

public func getWords() -> [String] {
    let mnemonic = try! Mnemonic()
    
    let phrase = mnemonic.mnemonic()
    return phrase
}
