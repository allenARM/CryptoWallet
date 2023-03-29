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

public func checkBTCBalance(address: String, completion: @escaping (Double?) -> ()) {
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

public func checkETHBalance(for address: String, completionHandler: @escaping (Result<Double, Error>) -> Void) {
    // Replace the following variable with your own Infura project ID
    let infuraProjectId = "a30677d78d3d45e19fd10d4a79a591c2"

    // Construct the Infura API endpoint URL
    let urlString = "https://mainnet.infura.io/v3/\(infuraProjectId)"
    let url = URL(string: urlString)!

    // Construct the JSON-RPC request body
    let requestBody = """
    {
        "jsonrpc": "2.0",
        "method": "eth_getBalance",
        "params": ["\(address)", "latest"],
        "id": 1
    }
    """

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = requestBody.data(using: .utf8)

    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        guard let data = data else {
            completionHandler(.failure(error ?? URLError(.badServerResponse)))
            return
        }

        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            guard let result = jsonObject?["result"] as? String else {
                completionHandler(.failure(NSError(domain: "JSON parsing error", code: 0, userInfo: nil)))
                return
            }

            // Convert the balance from hexadecimal to decimal
            let balanceInWei = BigInt(result.dropFirst(2), radix: 16)!
            let balanceInEth = Double(balanceInWei) / pow(10, 18)

            completionHandler(.success(balanceInEth))

        } catch {
            completionHandler(.failure(error))
        }
    }

    task.resume()
}

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

    let output: BitcoinSigningOutput = AnySigner.sign(input: input, coin: .bitcoinCash)

    let hexTransactionScript = output.encoded.hexString
    
    return hexTransactionScript
}

func getEthereumGasPrice(completion: @escaping(Result<[String], Error>) -> Void) {
    // Build the URL for the gas price API endpoint
    let gasPriceURL = URL(string: "https://ethgasstation.info/api/ethgasAPI.json")!

    // Create a URLSession object
    let session = URLSession.shared

    // Create the data task to send the request
    let task = session.dataTask(with: gasPriceURL) { data, response, error in
        // Handle the response
        if let error = error {
            print("Error: \(error.localizedDescription)")
            completion(.failure(URLError(.badURL)))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            print("Invalid response")
            completion(.failure(URLError(.badServerResponse)))
            return
        }
        
        guard let responseData = data else {
            print("No response data")
            completion(.failure(URLError(.badServerResponse)))
            return
        }
        
        // Parse the response data
        guard let jsonObject = try? JSONSerialization.jsonObject(with: responseData, options: []),
                  let json = jsonObject as? [String: Any],
                  let gasPrice = json["average"] as? Int64,
                  let gasPriceLimit = json["fastest"] as? Int64 else {
                print("Unable to parse response data")
            completion(.failure(URLError(.cannotParseResponse)))
            return
        }
        
        // Use the gas price value
//        print("Gas price: \(gasPriceString) wei")
        let retVal = [String(gasPrice, radix: 16), String(gasPriceLimit, radix: 16)]
        completion(.success(retVal))
    }

    // Start the task
    task.resume()
}

func signEthereumTransaction(hdwallet: HDWallet, amount:String, toAddress:String, gasPrice:String, gasLimit:String) -> String {
    let input = EthereumSigningInput.with {
        $0.chainID = Data(hexString: "01")!
//        $0.gasPrice = Data(hexString: gasPrice)!
//        $0.gasLimit = Data(hexString: gasLimit)!
        $0.gasPrice = Data(hex: gasPrice)
        $0.gasLimit = Data(hex: gasLimit)
        $0.toAddress = toAddress
        $0.transaction = EthereumTransaction.with {
           $0.transfer = EthereumTransaction.Transfer.with {
               $0.amount = Data(hex: amount)
           }
        }
        $0.privateKey = hdwallet.getKeyForCoin(coin: .ethereum).data
    }
    let output: EthereumSigningOutput = AnySigner.sign(input: input, coin: .ethereum)
    
//    print(" data:   ", output.encoded.hexString)
    return output.encoded.hexString
}

func signSolanaTransaction(hdwallet: HDWallet, amount:UInt64, toAddress:String) {
    let input = SolanaSigningInput.with {
        $0.transferTransaction.recipient = toAddress;
        $0.transferTransaction.value = amount;
        $0.privateKey = hdwallet.getKeyForCoin(coin: .solana).data
    }
    
    let output: SolanaSigningOutput = AnySigner.sign(input: input, coin: .solana)
    print("data: ", output.encoded)
}

func postBitcoinTransaction(rawTx:String, completion: @escaping(Result<String,Error>) -> Void) {
    let baseURL = "https://blockstream.info/api/"

    // Build the JSON payload
    let payload: [String: Any] = [
        "hex": rawTx
    ]

    let jsonPayload = try? JSONSerialization.data(withJSONObject: payload, options: [])

    guard let url = URL(string: baseURL + "tx") else {
        fatalError("Invalid URL")
    }

    // Create the request object
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = jsonPayload

    // Create a URLSession object
    let session = URLSession.shared

    // Create the data task to send the request
    let task = session.dataTask(with: request) { data, response, error in
        // Handle the response
        if let error = error {
//            print("Error: \(error.localizedDescription)")
            completion(.failure(error ?? URLError(.badURL)))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            completion(.failure(URLError(.badServerResponse)))
            return
        }
        
        guard let responseData = data else {
            completion(.failure(URLError(.cannotParseResponse)))
            return
        }
        
        // Handle the response data
        print(String(data: responseData, encoding: .utf8)!)
        
        completion(.success(String(data: responseData, encoding: .utf8)!))
    }

    // Start the task
    task.resume()
}

func postEthereumTransaction(rawTx:String, completion: @escaping(Result<String,Error>) -> Void) {
    
}

func postSolanaTransaction(rawTx:String, completion: @escaping(Result<String,Error>) -> Void) {
    
}
