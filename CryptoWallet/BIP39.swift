//
//  BIP39.swift
//  CryptoWallet
//
//  Created by Allen Melikian on 1/25/23.
//

import Foundation
import CryptoKit
import Base58Swift
import BIP39
import CryptoSwift

public func getWords() -> [String] {
    let mnemonic = Mnemonic().phrase
    
    print(mnemonic)
    return mnemonic
}

public func getPrivateKey(words: [String]) -> [UInt8] {
    let seed = try! Mnemonic(phrase: words).seed
    
    let privateKey = seed.sha512();
    
    return privateKey
}

public func getPublicKey(privateKey: [UInt8]) -> P256.KeyAgreement.PublicKey {
    let publicKey = try! P256.KeyAgreement.PublicKey(rawRepresentation: privateKey)
    
    return publicKey
}

public func getBTCAddress(publicKey: P256.KeyAgreement.PublicKey) -> String {
    let hash = publicKey.rawRepresentation.sha256().sha256()
    let checksum = hash[0...3]
    let data = Data([0x00] + publicKey.rawRepresentation.sha256().sha256()[0...19]) + checksum
    let address = Base58.encode(data)
    
    return address
}


