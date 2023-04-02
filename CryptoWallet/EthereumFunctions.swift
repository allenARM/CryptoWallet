//
//  EthereumFunctions.swift
//  CryptoWallet
//
//  Created by Allen Melikian on 3/29/23.
//

import Foundation
import CryptoSwift
import WalletCore
import BigInt
import web3

//// Replace the following variable with your own Infura project ID
//let infuraProjectId = "a30677d78d3d45e19fd10d4a79a591c2"
//
//// Construct the Infura API endpoint URL
//let urlString = "https://mainnet.infura.io/v3/\(infuraProjectId)"
//public let url = URL(string: urlString)!

//    guard let clientUrl = URL(string: "https://an-infura-or-similar-url.com/123") else { return }
//public let client = EthereumHttpClient(url: url)
//public var blockNum = 0
//public var ethBal:BigUInt!

public struct EthereumConnect {
    let client = EthereumHttpClient(url: URL(string: "https://mainnet.infura.io/v3/a30677d78d3d45e19fd10d4a79a591c2")!)
    var blockNum: Int!
    var ethBal: BigUInt!
    var ethBalNormilized: Double!
    var gasPrice: BigUInt!
    var gasPriceinGwei: Int!
    var ethKeyLocalStorage = EthereumKeyLocalStorage()
}

public var ethConnect = EthereumConnect()

public func checkETHBalance(for address: String, completionHandler: @escaping (Result<Double, Error>) -> Void) {
//    // Replace the following variable with your own Infura project ID
//    let infuraProjectId = "a30677d78d3d45e19fd10d4a79a591c2"
//
//    // Construct the Infura API endpoint URL
//    let urlString = "https://mainnet.infura.io/v3/\(infuraProjectId)"
//    let url = URL(string: urlString)!
//
////    guard let clientUrl = URL(string: "https://an-infura-or-similar-url.com/123") else { return }
//    let client = EthereumHttpClient(url: url)

    let divisor = BigUInt(10).power(13)
    let finalEthBal = (ethConnect.ethBal)/divisor
    var floatValue:Double!
    if (finalEthBal.description.count < 6)
    {
        floatValue = Double("0." + finalEthBal.description)
    }
    else
    {
        floatValue = Double(finalEthBal.description)!/pow(10.0, 5.0)
    }
    if (floatValue > 0){
        completionHandler(.success(floatValue));
        ethConnect.ethBalNormilized = floatValue
    }
    else{
        completionHandler(.success(0));
        ethConnect.ethBalNormilized = floatValue
    }
//    print("ETH balance: \(String(finalEthBal))");
//
//    // Construct the JSON-RPC request body
//    let requestBody = """
//    {
//        "jsonrpc": "2.0",
//        "method": "eth_getBalance",
//        "params": ["\(address)", "latest"],
//        "id": 1
//    }
//    """
//
//    var request = URLRequest(url: url)
//    request.httpMethod = "POST"
//    request.httpBody = requestBody.data(using: .utf8)
//
//    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
//        guard let data = data else {
//            completionHandler(.failure(error ?? URLError(.badServerResponse)))
//            return
//        }
//
//        do {
//            let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//            guard let result = jsonObject?["result"] as? String else {
//                completionHandler(.failure(NSError(domain: "JSON parsing error", code: 0, userInfo: nil)))
//                return
//            }
//
//            // Convert the balance from hexadecimal to decimal
//            let balanceInWei = BigInt(result.dropFirst(2), radix: 16)!
//            let balanceInEth = Double(balanceInWei) / pow(10, 18)
//
//            completionHandler(.success(balanceInEth))
//
//        } catch {
//            completionHandler(.failure(error))
//        }
//    }
//
//    task.resume()
}

func getEthereumGasPrice() {
    let divisor = BigUInt(10).power(9)
    ethConnect.gasPriceinGwei = Int(ethConnect.gasPrice/divisor) + 1
//    // Build the URL for the gas price API endpoint
//    let gasPriceURL = URL(string: "https://ethgasstation.info/api/ethgasAPI.json")!
//
//    // Create a URLSession object
//    let session = URLSession.shared
//
//    // Create the data task to send the request
//    let task = session.dataTask(with: gasPriceURL) { data, response, error in
//        // Handle the response
//        if let error = error {
//            print("Error: \(error.localizedDescription)")
//            completion(.failure(URLError(.badURL)))
//            return
//        }
//
//        guard let httpResponse = response as? HTTPURLResponse,
//              (200...299).contains(httpResponse.statusCode) else {
//            print("Invalid response")
//            completion(.failure(URLError(.badServerResponse)))
//            return
//        }
//
//        guard let responseData = data else {
//            print("No response data")
//            completion(.failure(URLError(.badServerResponse)))
//            return
//        }
//
//        // Parse the response data
//        guard let jsonObject = try? JSONSerialization.jsonObject(with: responseData, options: []),
//                  let json = jsonObject as? [String: Any],
//                  let gasPrice = json["average"] as? Int64,
//                  let gasPriceLimit = json["fastest"] as? Int64 else {
//                print("Unable to parse response data")
//            completion(.failure(URLError(.cannotParseResponse)))
//            return
//        }
//
//        // Use the gas price value
////        print("Gas price: \(gasPriceString) wei")
//        let retVal = [String(gasPrice, radix: 16), String(gasPriceLimit, radix: 16)]
//        completion(.success(retVal))
//    }
//
//    // Start the task
//    task.resume()
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



func postEthereumTransaction(rawTx:String) {
    let pkData = hdwallet.getKeyForCoin(coin: .ethereum)
    
    do{
        try ethConnect.ethKeyLocalStorage.storePrivateKey(key: pkData.data)
        let account = try EthereumAccount(keyStorage: ethConnect.ethKeyLocalStorage)
    }
    catch{}

    
//    let pk = EthereumSingleKeyStorageProtocol().storePrivateKey(key: pkData)
}
