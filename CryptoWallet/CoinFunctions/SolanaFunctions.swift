//
//  SolanaFunctions.swift
//  CryptoWallet
//
//  Created by Allen Melikian on 3/29/23.
//

import Foundation
import CryptoSwift
import WalletCore
import BigInt
import SolanaWeb3

public struct SolanaConnect {
    var client = Connection(cluster: .mainnetBeta)
    var blockNum: UInt64!
    var solBal: UInt64!
    var solBalNormilized: Double!
    var feePrice: UInt64!
    var solAddress: String!
    var account: SolanaWeb3.Account!
}

public var solConnect = SolanaConnect()

public func checkSOLBalance() {
    solConnect.solBalNormilized = Double(solConnect.solBal)/pow(10.0, 9.0)
}

func sendSolTransaction(toAddress: String, Amount: UInt64) {
    struct TransactionInformation{
        var recentBlockHash: SolanaWeb3.Blockhash!
        var nonceInformation: SolanaWeb3.NonceInformation!
        var feePayer: SolanaWeb3.PublicKey!
        var signatures: [SolanaWeb3.SignaturePubkeyPair]!
    }
    
    var txInfo = TransactionInformation()
    
    do {
        let instructions = try SolanaWeb3.SystemProgram.transfer(fromPublicKey: solConnect.account.publicKey, toPublicKey: SolanaWeb3.PublicKey(toAddress), lamports: Amount)
        
        solConnect.client.getLatestBlockhash() {result in switch result {
        case .success(let blockHash):
            txInfo.recentBlockHash = blockHash.blockhash
        case .failure(let error):
            print(error)
        }}
        txInfo.feePayer = solConnect.account.publicKey
        var txToSend = SolanaWeb3.Transaction(recentBlockhash: txInfo.recentBlockHash)
        txToSend.instructions.append(instructions)
        solConnect.client.sendTransaction(transaction: txToSend, signers: [solConnect.account]) {result in switch result {
        case .success(let retVal):
            print(retVal)
        case .failure(let error):
            print(error)
        }}
    }
    catch{}
}
