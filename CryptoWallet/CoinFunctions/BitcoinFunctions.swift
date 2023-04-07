//
//  CoinFunctions.swift
//  CryptoWallet
//
//  Created by Ashot Alajanyan on 3/26/23.
//

import Foundation
import CryptoSwift
import WalletCore
import BigInt

public struct BitcoinConnect{
    var btcBal: Double!
    var btcAddress: String!
}

public var btcConnect = BitcoinConnect()

public func checkBTCBalance(address: String) {
    let url = URL(string: "https://blockstream.info/api/address/\(address)")!
//    let url = URL(string: "https://blockstream.info/testnet/api/address/muGuqWmcHpjmB2rBpdbTnCwD18wnrWCjBB")!
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let data = data {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let test = json["chain_stats"] as? [String:Any]
                    let balance = (test?["funded_txo_sum"] as! Double) - (test?["spent_txo_sum"] as! Double)
                    if (balance != nil) {
                        let Finalbalance = balance/100000000
                        btcConnect.btcBal = Finalbalance
                        if (balance == 0){
                            btcConnect.btcBal = 0.0
                        }
                    }
                    else {
                        print("error")
                    }
                }
            }
            catch {
                print("error")
            }
        }
       }.resume()
}



public func getLatestTransactionHashForBTCAddress(address: String, completion: @escaping(String, Int, Int) -> ()) {
    let blockstreamInfoApi = URL(string: "https://blockstream.info/api/address/\(address)/txs")!
//    let blockstreamInfoApi = URL(string: "https://blockstream.info/testnet/api/address/muGuqWmcHpjmB2rBpdbTnCwD18wnrWCjBB/txs")!
    
    var index = 0
    
    URLSession.shared.dataTask(with: blockstreamInfoApi) { data, response, error in
      if let error = error {
        print("Error: \(error)")
      } else if let data = data {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
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
                    let value = vouts[index]["value"] as! Int
                    completion(txid!, index, value)
                }
              }
            } catch {
              print("Error: NO JSON")
            }
          }
        }.resume()
}

func signBitcoinTransaction(hdwallet: HDWallet, amount:Int, toAddress:String, txid:String, txindex:Int, txvalue:Int64) -> String{
    
    let utxoTxId = Data(hexString: txid)! // latest utxo for sender, "txid" field from blockbook utxo api: https://github.com/trezor/blockbook/blob/master/docs/api.md#get-utxo
    let privateKey = hdwallet.getKeyForCoin(coin: .bitcoin)
    let address = CoinType.bitcoin.deriveAddress(privateKey: privateKey)

    let utxo = BitcoinUnspentTransaction.with {
        $0.outPoint.hash = Data(utxoTxId.reversed()) // reverse of UTXO tx id, Bitcoin internal expects network byte order
        $0.outPoint.index = UInt32(txindex)                        // outpoint index of this this UTXO, "vout" field from blockbook utxo api
        $0.outPoint.sequence = UINT32_MAX
        $0.amount = txvalue                             // value of this UTXO, "value" field from blockbook utxo api
        $0.script = BitcoinScript.lockScriptForAddress(address: address, coin: .bitcoin).data // Build lock script from address or public key hash
    }

    let input = BitcoinSigningInput.with {
        $0.hashType = BitcoinScript.hashTypeForCoin(coinType: .bitcoin)
        $0.amount = Int64(amount)
        $0.byteFee = 1
        $0.toAddress = toAddress
        $0.changeAddress = hdwallet.getAddressForCoin(coin: .bitcoin) // can be same sender address
        $0.utxo = [utxo]
        $0.privateKey = [privateKey.data]
    }

    let output: BitcoinSigningOutput = AnySigner.sign(input: input, coin: .bitcoin)

    let hexTransactionScript = output.encoded.hexString
    
    return hexTransactionScript
}

func postBitcoinTransaction(rawTx:String, completion: @escaping(Result<String,Error>) -> Void) {
    let url = URL(string: "https://blockchain.info/pushtx")!

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    let postData = "tx=\(rawTx)"
    request.httpBody = postData.data(using: .utf8)

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error.localizedDescription)")
            completion(.failure(URLError(.badURL)))
            return
        }
        
        guard let data = data else {
            print("No data returned from server.")
            completion(.failure(URLError(.badServerResponse)))
            return
        }
        
        let responseString = String(data: data, encoding: .utf8)!
        completion(.success(responseString))
    }

    task.resume()
}
