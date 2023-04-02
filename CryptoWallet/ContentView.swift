//
//  ContentView.swift
//  CryptoWallet
//
//  Created by Ashot Alajanyan on 3/5/23.
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

public var hdwallet:HDWallet!

struct ContentView: View {
    
    var body: some View {
        NavigationView{
            VStack {
                Image(systemName: "person.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .padding()
                
                
                NavigationLink(destination: LoginView()){
                    Text("Login to existing wallet")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                        .padding(.horizontal, 25)
                }
                NavigationLink(destination: CreateWalletView()) {
                    Text("Create a new wallet")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(8)
                        .padding(.horizontal, 25)
                }
            }
            .task {
                do {
                    ethConnect.blockNum = try await ethConnect.client.eth_blockNumber()
                    ethConnect.ethBal = BigUInt(try await ethConnect.client.eth_getBalance(address: EthereumAddress(stringLiteral: "0xFe496d439E96354a5f787f95Fba1A449d1b41280"), block: EthereumBlock(rawValue: ethConnect.blockNum)))
                    ethConnect.gasPrice = BigUInt(try await ethConnect.client.eth_gasPrice())
                        
                }
                catch{}
            }
        }
    }

    
    
    struct LoginView: View {
        @State private var TextField12Words = ""
        @State private var words: [String] = []
        @State private var isShowingHomeView = false
        
        @State private var accountSecretKey: Data?

        
        var body: some View {
            VStack{
                TextField("12 Words", text: $TextField12Words)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                if(words.count < 11)
                {
                    Button("Add word") {
                        words.append(TextField12Words)
                        TextField12Words = ""
                    }
                } else{
                    Button("Login")
                    {
                        words.append(TextField12Words)
                        TextField12Words = ""
                        login()
                        self.isShowingHomeView = true
                    }
                }
                
                Button("Try ETH") { try_ETH() }
                
                Button("Try SOL") {
                    try_SOL()
                }
                
                Button("Try SignBTCTransaction") {try_BTCTransaction()}
            }
            .fullScreenCover(isPresented: $isShowingHomeView){
                HomeView()
            }
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
            let words = getWords()
            hdwallet = HDWallet(mnemonic: words.joined(separator: " "), passphrase: "")
            print(hdwallet.getKeyForCoin(coin: .solana).data.hashValue)
            
//            let sol = Solana(network: .main)
//            print(signSolanaTransaction(hdwallet: hdwallet, amount: 50, toAddress: "StringaoyuUEidmY4gqkw42UAs8N3QpJpD4KLXnSWYhPSE8bB"))
                        
//
            
        }
        
        func try_BTCTransaction()
        {
            hdwallet = HDWallet(mnemonic: (Mnemonic().phrase).joined(separator: " "), passphrase: "")
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
            
        
        func login()
        {
            
            if (noMissingWords(twelveWords: words) == false) {
                print("INCORRECT WORDS")
            }
            
            hdwallet = getWallet(words: words)
            HomeView()

//            let btcAddress = hdwallet.getAddressForCoin(coin: .bitcoin)
//            print("BTC: " + btcAddress)
            let ethAddress = hdwallet.getAddressForCoin(coin: .ethereum)
            print("ETH: " + ethAddress)
//            let solAddress = hdwallet.getAddressForCoin(coin: .solana)
//            print("SOL: " + solAddress)
//
//            checkBTCBalance(address: btcAddress) { balance in
//                print("BTC Balance: \(balance ?? 0)")
//            }
//
//            getLatestTransactionHashForBTCAddress(address: btcAddress) {
//                txid, index, value in
//                print("TXID: \(txid)")
//                print("ID: \(index)")
//                print("Value: \(value)")
//            }
        }
}
    
    struct CreateWalletView: View {
//        @State private var words: [String] = []

        var body: some View {
            let words = getWords()
            HStack {
                VStack {
                    Text("This is your secret key.")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: CGFloat(20)).foregroundColor(.gray))
                    Text("Please write it down and save it in safe place. You will need it to loging to your account")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: CGFloat(20)).foregroundColor(.blue))
                    Text("Never share your secret key with anyone.")
                        .font(.title3)
                        .foregroundColor(.red)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: CGFloat(20)).foregroundColor(.white))
                }
            }
            HStack {
                VStack {
                    Text("1: " + words[0])
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding()
                        .background(Capsule().foregroundColor(.blue))
                    Text("2: " + words[1])
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding()
                        .background(Capsule().foregroundColor(.blue))
                    Text("3: " + words[2])
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding()
                        .background(Capsule().foregroundColor(.blue))
                    Text("4: " + words[3])
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding()
                        .background(Capsule().foregroundColor(.blue))
                    Text("5: " + words[4])
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding()
                        .background(Capsule().foregroundColor(.blue))
                    Text("6: " + words[5])
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding()
                        .background(Capsule().foregroundColor(.blue))
                }
                VStack {
                    Text("7: " + words[6])
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding()
                        .background(Capsule().foregroundColor(.blue))
                    Text("8: " + words[7])
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding()
                        .background(Capsule().foregroundColor(.blue))
                    Text("9: " + words[8])
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding()
                        .background(Capsule().foregroundColor(.blue))
                    Text("10: " + words[9])
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding()
                        .background(Capsule().foregroundColor(.blue))
                    Text("11: " + words[10])
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding()
                        .background(Capsule().foregroundColor(.blue))
                    Text("12: " + words[11])
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding()
                        .background(Capsule().foregroundColor(.blue))
                }
            }
        }
        
        func createWalletButtonTapped() {
            // Split the input into individual words and display them
//            words = getWords()
//            for word in words {
//                print(word)
//            }
        }
    }
}

struct ContentView_Previews: PreviewProvider{
    static var previews: some View{
        ContentView()
    }
}
