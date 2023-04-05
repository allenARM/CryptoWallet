//
//  HomeView.swift
//  CryptoWallet
//
//  Created by Ashot Alajanyan on 3/26/23.
//

import SwiftUI
import WalletCore
import Foundation
import BIP39
import CryptoSwift
import Base58Swift
//import Crypto
import CryptoKit
import web3
import BigInt

struct HomeView: View {
    var body: some View {
        NavigationView{
            ZStack{
                bgColor
                    .ignoresSafeArea(.all)
                
                VStack{
                    NavigationLink(destination: EthView())
                    {
                        Text("Testing Ethereum View")
                    }
                    .padding()
                    
                    NavigationLink(destination: SolView())
                    {
                        Text("Testing Solana View")
                    }
                        .padding()
                    
                    NavigationLink(destination: BtcView())
                    {
                        Text("Testing Bitcoin View")
                    }
                        .padding()
                }
            }
        }
    }
}

struct EthView: View
{
    @State private var isShowingConfirmView = false
    
    var body: some View
    {
            ZStack{
                bgColor
                    .ignoresSafeArea(.all)
                VStack
                {
                    Button("Try ETH") { try_ETH() }
                        .padding()
                    
                   
                        Button("Send")
                    {
                        confirmEth()
                    }
                    .padding()
                    
                }
            }
            .fullScreenCover(isPresented: $isShowingConfirmView){
                ConfirmView(isPresented: $isShowingConfirmView)
            }
    }
    
    
    //maybe create ENUM type for different confirm views
    func confirmEth()
    {
        isShowingConfirmView = true
    }
    
    func try_ETH(){
        checkETHBalance(for: "0x388C818CA8B9251b393131C08a736A67ccB19297") { result in
            switch result {
            case .success(let balance):
                print("Balance: \(balance) ETH")
            case .failure(let error):
                print("Error: \(error)")
            }
        }
        getEthereumGasPrice()
        print(ethConnect.gasPriceinGwei)
        
        let words = getWords()
        hdwallet = HDWallet(mnemonic: words.joined(separator: " "), passphrase: "")
        print("------------------------------------------")
        print(hdwallet.getKeyForCoin(coin: .ethereum).data.hashValue)
        ethConnect.ethAddress = EthereumAddress(stringLiteral: hdwallet.getAddressForCoin(coin: .ethereum))
        do{
            //GO TO SPECIFIC VIEW FOR ASYNC CALL OF ETH TRANSACTION
//                postEthereumTransaction(amount: <#T##BigUInt#>, toAddress: <#T##String#>, gasPrice: <#T##BigUInt#>, gasLimit: <#T##BigUInt#>)
            let pkData = hdwallet.getKeyForCoin(coin: .ethereum)
            try ethConnect.ethKeyLocalStorage.storePrivateKey(key: pkData.data)
            print(try ethConnect.ethKeyLocalStorage.loadPrivateKey().hashValue)
        }
        catch{
            print("it didn't work")
        }
        print("------------------------------------------")
//            var gasPrice1 = ""
//            var gasPriceLimit1 = ""
//            getEthereumGasPrice() { result in
//                switch result {
//                case .success(let gasPrice):
//                    print("Gas Price: \(gasPrice[0])")
//                    print("Gas Price Limit: \(gasPrice[1])")
//
//                    hdwallet = HDWallet(mnemonic: (Mnemonic().phrase).joined(separator: " "), passphrase: "")
//                    signEthereumTransaction(hdwallet: hdwallet, amount: String(100, radix: 16), toAddress: "0x388C818CA8B9251b393131C08a736A67ccB19297", gasPrice: gasPrice[0], gasLimit: gasPrice[1])
//                case .failure(let error):
//                    print("Error: \(error)")
//                }
//            }
    }
}

struct ConfirmView: View{
    @Binding var isPresented: Bool
    var body: some View{
        ZStack{
            bgColor
                .ignoresSafeArea(.all)
            VStack{
                Button("Done")
                {
                    isPresented = false
                }
            }
        }
        // run asynchronous code here

    }
}


struct SolView: View{
    
    var body: some View
    {
        ZStack{
            bgColor
                .ignoresSafeArea(.all)
            VStack{
                Button("Try Sol")
                {
                    try_SOL()
                }
            }
        }
        
    }
    
    func try_SOL()
    {
        checkSOLBalance(for: "aoyuUEidmY4gqkw42UAs8N3QpJpD4KLXnSWYhPSE8bB") { result in
            switch result {
            case .success(let balance):
                print("Balance: \(balance) SOL")
            case .failure(let error):
                print("Error: \(error)")
            }
        }
//            let words = getWords()
//            hdwallet = HDWallet(mnemonic: words.joined(separator: " "), passphrase: "")
        print(hdwallet.getKeyForCoin(coin: .solana).data.hashValue)
        
//            let sol = Solana(network: .main)
//            print(signSolanaTransaction(hdwallet: hdwallet, amount: 50, toAddress: "StringaoyuUEidmY4gqkw42UAs8N3QpJpD4KLXnSWYhPSE8bB"))
                    
//
        
    }
}

struct BtcView: View{
    
    var body: some View{
        
        ZStack{
            bgColor
                .ignoresSafeArea()
            
            VStack{
                Button("Try SignBTCTransaction")
                {
                    try_BTCTransaction()
                    
                }
            }
        }
    }
    
    func try_BTCTransaction()
    {
//            hdwallet = HDWallet(mnemonic: (Mnemonic().phrase).joined(separator: " "), passphrase: "")
        let rawBTCtransaction = signBitcoinTransaction(hdwallet: hdwallet, amount: 10000, toAddress: "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh", txid: "56115860cd3f7910e5c6b7a4e33fd47d19d839bfb0c1b51b6c9141af18cd9201", txindex: 10, txvalue: 5054968)
        postBitcoinTransaction(rawTx: rawBTCtransaction) { result in
            switch result {
            case .success(let transactionID):
                print("Transaction accepted by server: \(transactionID)")
            case .failure(let error):
                print("Error: \(error)")
            }

        }
    }
}



struct HomeView_Previews: PreviewProvider{
    static var previews: some View{
        HomeView()
    }
}
