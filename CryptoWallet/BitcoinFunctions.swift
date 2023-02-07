//
//  BitcoinFunctions.swift
//  CryptoWallet
//
//  Created by Allen Melikian on 1/30/23.
//

import Foundation
import Alamofire
import CryptoSwift

func checkBalance(address: String, completion: @escaping (Double?) -> ()) {
//    let url = URL(string: "https://blockchain.info/balance?active=\(address)")!
    let url = URL(string: "https://blockstream.info/testnet/api/address/\(address)")!
        
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let data = data {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // try to read out a string array
                    let test = json["chain_stats"] as? [String:Any]
                    let balance = test?["funded_txo_sum"] as? Double
                    let BTCbalance = balance!/100000000
                    print(BTCbalance)
                }
            }
            catch {
                print("error")
            }
        }
       }.resume()
}

func getLatestTransactionHashForAddress(address: String) {
//    let blockstreamInfoApi = "https://blockstream.info/api/address/\(address)/txs?limit=1"
    
    let blockstreamInfoApi = URL(string: "https://blockstream.info/testnet/api/address/\(address)/txs")!

    URLSession.shared.dataTask(with: blockstreamInfoApi) { data, response, error in
      if let error = error {
        print("Error: \(error)")
      } else if let data = data {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print(json)
//            if let transactions = json["txid"] as? [[String: Any]] {
//              if let latestTransaction = transactions.first {
//                  print(latestTransaction)
//              }
//            }
          }
        } catch {
          print("Error: \(error)")
        }
      }
    }.resume()
}

//Returns true on success
//func makeTransaction(address: String, privateKey: [UInt8]) -> Bool {
//    
//}
