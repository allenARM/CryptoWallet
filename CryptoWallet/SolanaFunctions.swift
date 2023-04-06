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
    var solBalNormilized: Int64!
    var feePrice: UInt64!
    var solAddress: String!
    var account: SolanaWeb3.Account!
}

public var solConnect = SolanaConnect()


public func checkSOLBalance(for address: String, completionHandler: @escaping (Result<Double, Error>) -> Void) {
    let url = URL(string: "https://api.mainnet-beta.solana.com")!

    let rpcRequest = [
        "jsonrpc": "2.0",
        "id": 1,
        "method": "getBalance",
        "params": [
            "\(address)" // Replace with the wallet address you want to check
        ]
    ] as [String: Any]

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try? JSONSerialization.data(withJSONObject: rpcRequest, options: [])

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard error == nil else {
            print("Error: \(error!.localizedDescription)")
            return
        }

        guard let data = data else {
            print("No data returned from server")
            return
        }

        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            print("Unable to parse response data as JSON")
            return
        }

        if let error = json["error"] as? [String: Any] {
            print("JSON RPC error: \(error)")
            return
        }

        let result = json["result"] as? [String:Any]
//        let context = json["context"] as? [String:Any]
        guard let value = result?["value"] as? Int64 else {
            print("Error")
//            completionHandler(.failure(Error as! Error))
            return
        }
//        let value = json["value"] as? Int64
        
        let friendlyValue = Double(value)/pow(10, 9)
        completionHandler(.success(Double(friendlyValue)))
    }

    task.resume()
}

func signSolanaTransaction(hdwallet: HDWallet, amount:UInt64, toAddress:String) -> String {
    let input = SolanaSigningInput.with {
        $0.transferTransaction.recipient = toAddress;
        $0.transferTransaction.value = amount;
        $0.privateKey = hdwallet.getKeyForCoin(coin: .solana).data
    }
    let output: SolanaSigningOutput = AnySigner.sign(input: input, coin: .solana)
//    print("data: ", output.encoded)
    return output.encoded
}

func postSolanaTransaction(rawTx:String, completion: @escaping(Result<String,Error>) -> Void) {
    
}
