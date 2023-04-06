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
import SolanaWeb3

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
        .task {
            do {
                //Create account
                let words = getWords()
                hdwallet = HDWallet(mnemonic: words.joined(separator: " "), passphrase: "")
                print("HDWALLET CREATED")
                
                //Check BTC balance
                checkBTCBalance(address: hdwallet.getAddressForCoin(coin: .bitcoin))

               
            }
            catch{
                print("Error in homeview")
            }
        }
    }
}

struct EthView: View
{
    @State private var isLoading: Bool!
    @State private var isShowingConfirmView = false
    
    var body: some View
    {
        ZStack{
            bgColor
                .ignoresSafeArea(.all)
                VStack
                {
                    if (isLoading == true) {
                        ProgressView()
                    }
                    else if (isLoading == false) {
                        Text("Balance: " + String(ethConnect.ethBalNormilized!))
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding()
                            .background(Capsule().foregroundColor(.blue))
                    }
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
            .task {
                isLoading = true
                do {
                    ethConnect.blockNum = try await ethConnect.client.eth_blockNumber()
                    ethConnect.ethBal = BigUInt(try await ethConnect.client.eth_getBalance(address: web3.EthereumAddress(stringLiteral: "0xFe496d439E96354a5f787f95Fba1A449d1b41280"), block: web3.EthereumBlock(rawValue: ethConnect.blockNum)))
                    await checkETHBalance(for: hdwallet.getAddressForCoin(coin: .ethereum))
                    ethConnect.gasPrice = BigUInt(try await ethConnect.client.eth_gasPrice())
                }
                catch{}
                isLoading = false
            }
    }
    
    
    //maybe create ENUM type for different confirm views
    func confirmEth()
    {
        isShowingConfirmView = true
    }
    
    func try_ETH(){
        getEthereumGasPrice()
        print("Current gas price" + String(ethConnect.gasPriceinGwei))
        
        print("------------------------------------------")
        print(hdwallet.getKeyForCoin(coin: .ethereum).data.hashValue)
        ethConnect.ethAddress = web3.EthereumAddress(stringLiteral: hdwallet.getAddressForCoin(coin: .ethereum))
        do{
            //GO TO SPECIFIC VIEW FOR ASYNC CALL OF ETH TRANSACTION
//                postEthereumTransaction(amount: <#T##BigUInt#>, toAddress: <#T##String#>, gasPrice: <#T##BigUInt#>, gasLimit: <#T##BigUInt#>)
            let pkData = hdwallet.getKeyForCoin(coin: .ethereum)
            try ethConnect.ethKeyLocalStorage.storePrivateKey(key: pkData.data)
            print(try ethConnect.ethKeyLocalStorage.loadPrivateKey().hashValue)
            print("ETH Account Restored")
        }
        catch{
            print("it didn't work")
        }
        print("------------------------------------------")
        var ethT = EthTransaction()
        ethT.gasPrice = ethConnect.gasPrice
        ethT.amount = 1;
        ethT.toAddress = "0x388C818CA8B9251b393131C08a736A67ccB19297"
        ethT.gasLimit = ethT.gasPrice + 15;
        postEthereumTransaction(ethTransaction: ethT)
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
        .task {
            
        }
    }
}


struct SolView: View{
    @State private var isLoading: Bool!
    
    var body: some View
    {
        ZStack{
            bgColor
                .ignoresSafeArea(.all)
            VStack{
                if (isLoading == true){
                    ProgressView()
                }
                else if (isLoading == false){
                    Text("Balance: " + String(solConnect.solBal))
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding()
                        .background(Capsule().foregroundColor(.blue))
                }
                Button("Try Sol")
                {
                    try_SOL()
                }
            }
        }
        .task {
            isLoading = true
            do {
                solConnect.account = try SolanaWeb3.Account(secretKey: hdwallet.getKeyForCoin(coin: .solana).data, publicKey: hdwallet.getKeyForCoin(coin: .solana).getPublicKey(coinType: .solana).data)

                if (solConnect.account.publicKey.base58 == hdwallet.getAddressForCoin(coin: .solana)) {
                    print("Solana account restored")
                }
                solConnect.client.getBalance(publicKey: solConnect.account.publicKey) {result in switch result{
                case .success(let balance):
                    solConnect.solBal = balance
                    print(solConnect.solBal!)
                case .failure(let error):
                    print(error)
                }}
                try await Task.sleep(nanoseconds: 2000000000)
            }
            catch{}
            isLoading = false
        }
        
    }
    
    func try_SOL()
    {
//        checkSOLBalance(for: "aoyuUEidmY4gqkw42UAs8N3QpJpD4KLXnSWYhPSE8bB") { result in
//            switch result {
//            case .success(let balance):
//                print("Balance: \(balance) SOL")
//            case .failure(let error):
//                print("Error: \(error)")
//            }
//        }
//        SolanaWeb3.Transaction(data: <#T##Data#>)
//        solConnect.client.sendTransaction(transaction: <#T##Transaction#>, signers: <#T##[Signer]#>) { result in switch result{
//        case .success(let tx):
//            print("success")
//        case .failure(let error):
//            print(error)
//        }}
    }
}

struct BtcView: View{
    
    var body: some View{
        
        ZStack{
            bgColor
                .ignoresSafeArea()
            
            VStack{
                
                Text("Balance: " + String(btcConnect.btcBal))
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding()
                    .background(Capsule().foregroundColor(.blue))
                Button("Try SignBTCTransaction")
                {
                    try_BTCTransaction()
                    
                }
            }
        }
        .task {
            checkBTCBalance(address: hdwallet.getAddressForCoin(coin: .bitcoin))
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
