//
//  BIP39.swift
//  CryptoWallet
//
//  Created by Allen Melikian on 1/25/23.
//

import Foundation
import BIP39
import CryptoSwift
import Base58Swift
import Crypto

public func getWords() -> [String] {
    let mnemonic = Mnemonic().phrase
    
    return mnemonic
}

public func getSeed(words: [String]) -> [UInt8] {
    let seed = Mnemonic().seed
    
    return seed
}

public func getBTCAddress(seed: [UInt8]) -> String {
    let privateKey = seed.sha512()
    
    let publicKey = try! P256.KeyAgreement.PublicKey(rawRepresentation: privateKey.sha512())

    let hash = publicKey.rawRepresentation.sha256().sha256()
    let checksum = hash[0...3]
    let data = Data([0x00] + publicKey.rawRepresentation.sha256().sha256()[0...19]) + checksum
    let address = Base58.encode(data)
    
    return address
}
