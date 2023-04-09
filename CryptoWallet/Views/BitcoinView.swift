//
//  BitcoinView.swift
//  CryptoWallet
//
//  Created by Allen Melikian on 4/7/23.
//

import Foundation
import SwiftUI

public struct BtcView: View{
    @State private var isLoading: Bool!
    
    public var body: some View{
        
        ZStack{
            bgColor
                .ignoresSafeArea()
            
            VStack{
                if (isLoading == true){
                    ProgressView()
                }
                else if (isLoading == false) {
                    Text("Balance: " + String(btcConnect.btcBal))
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding()
                        .background(Capsule().foregroundColor(.blue))
                }
                Button("Try SignBTCTransaction")
                {
                    try_BTCTransaction()
                }
                
                NavigationLink(destination: BtcSend()) {
                    Text("Send Bitcoin")
                }
                
                let coinAddress = hdwallet.getAddressForCoin(coin: .bitcoin)
                Text(coinAddress)
                    .font(.footnote)
                    .padding(.all)
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerSize: CGSize(width: 10, height: 20)).foregroundColor(.gray))
                    .disabled(false)
                Button("Copy") {
                    UIPasteboard.general.string = coinAddress
                }
            }
        }
        .task {
            do {
                isLoading = true
                checkBTCBalance(address: hdwallet.getAddressForCoin(coin: .bitcoin))
//                checkBTCBalance(address: "3GYjC1igp6ySPoUJQTXNri75FR5MrVmuiC")
                try await Task.sleep(nanoseconds: 2000000000)
                isLoading = false
            }
            catch {}
        }
    }
    
    func try_BTCTransaction()
    {
        print("Nothing to try, everything is moved to the functions")
//        let rawBTCtransaction = signBitcoinTransaction(hdwallet: hdwallet, amount: 10000, toAddress: "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh", txid: "56115860cd3f7910e5c6b7a4e33fd47d19d839bfb0c1b51b6c9141af18cd9201", txindex: 10, txvalue: 5054968)
//        postBitcoinTransaction(rawTx: rawBTCtransaction) { result in
//            switch result {
//            case .success(let transactionID):
//                print("Transaction accepted by server: \(transactionID)")
//            case .failure(let error):
//                print("Error: \(error)")
//            }
//        }
    }
}

struct BtcSend: View {
    @State private var amount: String = ""
    @State private var recipientAddress: String = ""
    @State private var isShowingConfirmView = false
    
    var body: some View{
        ZStack{
            bgColor
                .ignoresSafeArea(.all)
            VStack{
                Text("Balance: " + String(btcConnect.btcBal))
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding()
                    .background(Rectangle().foregroundColor(.blue))
                
                TextField("Amount", text: $amount)
                .padding()
                .foregroundColor(.blue)
                
                TextField("Recipient Address", text: $recipientAddress)
                .padding()
                .foregroundColor(.blue)
                Button("Send")
                {
                    getLatestTransactionHashForBTCAddress(address: btcConnect.btcAddress) { result in switch result {
                    case .success(let btcData):
                        
                        let rawBTCtransaction = signBitcoinTransaction(hdwallet: hdwallet, amount: (UInt64(amount)! * 100000000), toAddress: recipientAddress, txid: btcData.txId, txindex: btcData.index, txvalue: btcData.value)
                        postBitcoinTransaction(rawTx: rawBTCtransaction) { result1 in
                            switch result1 {
                            case .success(let transactionID):
                                print("Transaction accepted by server: \(transactionID)")
                            case .failure(let error):
                                print("Error: \(error)")
                            }
                        }
                    case .failure(let error):
                        print(error)
                    }}
                    confirmBtc()
                }
                .padding()
                .foregroundColor(.blue)
            }
        }
        .fullScreenCover(isPresented: $isShowingConfirmView){
            ConfirmView(isPresented: $isShowingConfirmView)
        }
        // run asynchronous code here
        .task {
            
        }
    }
    //maybe create ENUM type for different confirm views
    func confirmBtc()
    {
        isShowingConfirmView = true
    }
}

