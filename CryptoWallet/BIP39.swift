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
import CryptoKit
import WalletCore

public func getWords() -> [String] {
    let mnemonic = Mnemonic().phrase
    
    return mnemonic
}

public func getWallet(words: [String]) -> HDWallet {
    let togetherWords = words.joined(separator: " ")
    let hdwallet = HDWallet(strength: 128, passphrase: togetherWords)!
    
    return hdwallet
}

//public func getSeed(words: [String]) -> [Uint8] {
//    //COMMENT LATER
////    let words = ["fence", "notable", "junior", "squeeze", "scatter", "obey", "fantasy", "blossom", "labor", "fire", "sign", "sure"];
////    let seed = try! Mnemonic(phrase: words).seed
//
////    return seed
//}
//
//public func getBTCAddress(seed: [UInt8]) -> String {
//    let seed1 = seed.toHexString().data(using: .utf8)!.sha256()
//    let privateKey = try! P256.KeyAgreement.PrivateKey(rawRepresentation: seed1)
//    
//    let publicKey = privateKey.publicKey
//    //1) Hash the public key using a one-way cryptographic hash function such as SHA-256.
//    let data = publicKey.rawRepresentation.sha256()
//    
//    //2) Perform a Ripemd-160 hash on the result of the SHA-256 hash.
//    let data1 = data.sha1()
//    
//    //3) Add a version byte in front of the Ripemd-160 hash
//    var versionedRipemd160Hash = Data(capacity: data1.count + 1)
//    //mainnet byte
////    versionedRipemd160Hash.append(0x00)
//    //testnet byte
//    versionedRipemd160Hash.append(0x6F)
//    versionedRipemd160Hash.append(data1)
//    
//    //4) Perform a double SHA-256 hash on the result of step 3.
//    let doubleSHA = versionedRipemd160Hash.sha256().sha256()
//    
//    //5) Take the first 4 bytes of the result of step 4 and append them to the result of step 3.
//    let checksumBytes = doubleSHA.prefix(4)
//    // Connect together
//    let finalData = Data(versionedRipemd160Hash + checksumBytes)
//    
//    //6) Convert the result of step 5 to base58Check encoding.
//    let address = Base58.encode(finalData)
//        
//    return address
//}
