//
//  SolanaView.swift
//  CryptoWallet
//
//  Created by Allen Melikian on 4/7/23.
//

import SwiftUI
import Foundation
import SolanaWeb3
import BigInt

public struct SolView: View{
    @State private var isLoading: Bool!
    
    public var body: some View
    {
        ZStack{
            bgColor
                .ignoresSafeArea(.all)
            VStack{
                if (isLoading == true){
                    ProgressView()
                }
                else if (isLoading == false){
                    Text("Balance: " + String(solConnect.solBalNormilized ?? 987654321))
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding()
                        .background(Capsule().foregroundColor(.blue))
                }
                
//                Button("Try Sol")
//                {
//                    try_SOL()
//                }
                
                NavigationLink(destination: SolSend()) {
                    Text("Send Solana")
                }
                .font(.title3)
                .foregroundColor(.white)
//                .background(Color(.systemBlue))
                .padding()
                .background(Capsule().foregroundColor(.gray))
                
                //QR CODE
                Image(uiImage: createQRCode(from: hdwallet.getAddressForCoin(coin: .solana)) ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .padding()
                //QR CODE END
                
                let coinAddress = hdwallet.getAddressForCoin(coin: .solana)
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
            isLoading = true
            do {
//                solConnect.account = try SolanaWeb3.Account(secretKey: hdwallet.getKeyForCoin(coin: .solana).data, publicKey: hdwallet.getKeyForCoin(coin: .solana).getPublicKey(coinType: .solana).data)
//
//                if (solConnect.account.publicKey.base58 == hdwallet.getAddressForCoin(coin: .solana)) {
//                    print("Solana account restored")
//                }
//                solConnect.client.getBalance(publicKey: solConnect.account.publicKey) {result in switch result{
//                case .success(let balance):
//                    solConnect.solBal = balance
//                case .failure(let error):
//                    print(error)
//                }}
//                try await Task.sleep(nanoseconds: 2000000000)
//                checkSOLBalance()
            }
            catch{}
            isLoading = false
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
    
    func try_SOL()
    {
        

    }
}

struct SolSend: View {
    @State private var amount: String = ""
    @State private var recipientAddress: String = ""
    @State private var isShowingConfirmView = false
    
    var body: some View{
        ZStack{
            bgColor
                .ignoresSafeArea(.all)
            VStack{
                Text("Balance: " + String(solConnect.solBalNormilized!))
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding()
                    .background(Rectangle().foregroundColor(.blue))
                
                TextField("Amount", text: $amount)
                .padding()
                .foregroundColor(.blue)
                .background(Color(.white))
                
//                Text("Double var: \((Double(amount) ?? 0) * pow(10, 9))")
//                Text("Double var: \(UInt64((Double(amount) ?? 0) * pow(10, 9)))")
                
                TextField("Recipient Address", text: $recipientAddress)
                .padding()
                .foregroundColor(.blue)
                .background(Color(.white))
                
                Button("Send")
                {
                    sendSolTransaction(toAddress: recipientAddress, Amount: UInt64((Decimal(string: amount)! * Decimal(pow(10,9))).description)!)
                    confirmSol()
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
    func confirmSol()
    {
        isShowingConfirmView = true
    }
}
