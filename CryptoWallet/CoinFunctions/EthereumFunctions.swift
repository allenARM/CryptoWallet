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

public struct EthereumConnect {
//    let client = EthereumHttpClient(url: URL(string: "https://mainnet.infura.io/v3/a30677d78d3d45e19fd10d4a79a591c2")!)
    let client = EthereumHttpClient(url: URL(string: "https://goerli.infura.io/v3/a30677d78d3d45e19fd10d4a79a591c2")!)
    var blockNum: Int!
    var ethBal: BigUInt!
    var ethBalNormilized: Double!
    var gasPrice: BigUInt!
    var gasPriceinGwei: Int!
    var ethAddress: EthereumAddress!
    var ethKeyLocalStorage = EthereumKeyLocalStorage()
}

public var ethConnect = EthereumConnect()

public struct EthTransaction {
    var amount: BigUInt!
    var toAddress: String!
    var gasPrice: BigUInt!
    var gasLimit: BigUInt!
}

public var ethT = EthTransaction()

public func checkETHBalance(for address: String) async {
    let doubleBal = Double(ethConnect.ethBal)/pow(10.0, 18.0)
    ethConnect.ethBalNormilized = doubleBal
}

func getEthereumGasPrice() {
    let divisor = BigUInt(10).power(9)
    ethConnect.gasPriceinGwei = Int(ethConnect.gasPrice/divisor) + 1
}

func prepareTransaction(amount:BigUInt, toAddress:String) -> EthTransaction {
    var ethT = EthTransaction()
    ethT.gasPrice = ethConnect.gasPrice
    ethT.gasLimit = 25000
    ethT.amount = amount * BigUInt(10).power(18)
    ethT.toAddress = toAddress
    return ethT
}

func postEthereumTransaction(toAddress: String, amount: BigUInt) {
    do{
        let account = try web3.EthereumAccount(keyStorage: ethConnect.ethKeyLocalStorage)
        
        ethT.toAddress = toAddress
        ethT.amount = amount
        ethT.gasLimit = 25000
        print("-----------------------")
        print(ethT.toAddress!)
        print(ethT.amount!)
        print(ethT.gasPrice!)
        print(ethT.gasLimit!)
        print(account.address.asString())
        print("-----------------------")
                
        let testTransaction = web3.EthereumTransaction(from: ethConnect.ethAddress, to: web3.EthereumAddress(stringLiteral: ethT.toAddress), value: ethT.amount!, data: try ethConnect.ethKeyLocalStorage.loadPrivateKey(), gasPrice: ethT.gasPrice!, gasLimit: ethT.gasLimit!)
        
        ethConnect.client.eth_sendRawTransaction(testTransaction, withAccount: account) { result in switch result {
        case .success(let respond):
            print(respond)
        case .failure(let error):
            print(error)
            }
        }
    }
    catch{}
}



