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
                        .background(Capsule().foregroundColor(.gray))
                }
//                Button("Try SignBTCTransaction")
//                {
//                    try_BTCTransaction()
//                }
                
                NavigationLink(destination: BtcSend()) {
                    Text("Send Bitcoin")
                }
                .font(.title3)
                .foregroundColor(.white)
//                .background(Color(.systemBlue))
                .padding()
                .background(Capsule().foregroundColor(.blue))
                
                //QR CODE
                Image(uiImage: createQRCode(from: hdwallet.getAddressForCoin(coin: .bitcoin)) ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .padding()
                //QR CODE END
                
                let coinAddress = hdwallet.getAddressForCoin(coin: .bitcoin)
                Button(action: {
                    // Action to perform when the button is tapped
                    // For example, navigate to another view or perform an action
                    UIPasteboard.general.string = coinAddress
                    
                    NotificationCenter.default.post(name: NSNotification.Name("AddressCopied"), object: nil)
                }) {
                    Text(coinAddress)
                        .font(.footnote)
                        .padding(.all)
                        .foregroundColor(.white)
                        .background(RoundedRectangle(cornerSize: CGSize(width: 10, height: 20)).foregroundColor(.gray))
                }
            }
        }
        .task {
            do {
                isLoading = true
//                checkBTCBalance(address: hdwallet.getAddressForCoin(coin: .bitcoin))
////                checkBTCBalance(address: "3GYjC1igp6ySPoUJQTXNri75FR5MrVmuiC")
//                try await Task.sleep(nanoseconds: 2000000000)
                isLoading = false
            }
            catch {}
        }
        .onAppear {
            // Listen for the "AddressCopied" notification
            NotificationCenter.default.addObserver(forName: NSNotification.Name("AddressCopied"), object: nil, queue: nil) { _ in
                // Display a notification that the address was copied to the clipboard
                let notification = UNMutableNotificationContent()
                notification.title = "Address Copied"
                notification.body = "The address was copied to the clipboard"
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                let request = UNNotificationRequest(identifier: "AddressCopied", content: notification, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            }
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
                .background(Color(.white))
                
                TextField("Recipient Address", text: $recipientAddress)
                .padding()
                .foregroundColor(.blue)
                .background(Color(.white))
                
                Button("Send")
                {
                    getLatestTransactionHashForBTCAddress(address: btcConnect.btcAddress) { result in switch result {
                    case .success(let btcData):
                        var dAmount = Decimal(string: amount) ?? 0
                        dAmount = dAmount * 100000000
                        var newDAmount = UInt64(dAmount.description)!
                        let rawBTCtransaction = signBitcoinTransaction(hdwallet: hdwallet, amount: newDAmount, toAddress: recipientAddress, txid: btcData.txId, txindex: btcData.index, txvalue: btcData.value)
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
                .foregroundColor(.white)
                .background(Color(.systemBlue))
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

