//
//  CoinFunctions.swift
//  CryptoWallet
//
//  Created by Allen Melikian on 1/30/23.
//

import Foundation
import Alamofire
import CryptoSwift
import WalletCore

func checkBTCBalance(address: String, completion: @escaping (Double?) -> ()) {
    let url = URL(string: "https://blockchain.info/balance?active=\(address)")!
//    let url = URL(string: "https://blockstream.info/testnet/api/address/\(address)")!
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let data = data {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let test = json["chain_stats"] as? [String:Any]
                    let balance = test?["funded_txo_sum"] as? Double
                    if (balance != nil) {
                        let Finalbalance = balance!/100000000
                        completion(Finalbalance)
                    }
                    else {
                        completion(0)
                    }
                }
            }
            catch {
                print("error")
            }
        }
       }.resume()
}

func getLatestTransactionHashForBTCAddress(address: String, completion: @escaping(String, Int) -> ()) {
//    let blockstreamInfoApi = URL(string: "https://blockstream.info/api/address/\(address)/txs")!
    
    let blockstreamInfoApi = URL(string: "https://blockstream.info/testnet/api/address/muGuqWmcHpjmB2rBpdbTnCwD18wnrWCjBB/txs")!
    
    var index = 0
    
    URLSession.shared.dataTask(with: blockstreamInfoApi) { data, response, error in
      if let error = error {
        print("Error: \(error)")
      } else if let data = data {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
//                print(json)
            if let tx = json[0] as? [String: Any] {
                let txid = tx["txid"] as? String
                
                let vouts = tx["vout"] as! [[String:Any]]
                for vout in vouts {
                    let voutAddress = vout["scriptpubkey_address"] as! String
                    if (voutAddress != address) {
                        index += 1
                    }
                    else {
                        break
                    }
                }
                completion(txid!, index)
            }
          }
        } catch {
          print("Error: \(error)")
        }
      }
    }.resume()
}

//func signBitcoinTransaction(hdwallet: HDWallet) -> Bool {
//    let privateKey =
//    return true
//}
