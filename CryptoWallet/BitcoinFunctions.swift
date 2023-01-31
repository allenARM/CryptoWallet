//
//  BitcoinFunctions.swift
//  CryptoWallet
//
//  Created by Allen Melikian on 1/30/23.
//

import Foundation
import Alamofire

func checkBalance(address: String, completion: @escaping (Double?) -> ()) {
    let url = URL(string: "https://blockchain.info/balance?active=\(address)")!
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            completion(nil)
            return
        }
        
        let balance = Double(String(data: data, encoding: .utf8)!)
        completion(balance)
    }
    task.resume()
}
