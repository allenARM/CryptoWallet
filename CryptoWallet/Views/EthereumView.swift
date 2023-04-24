//
//  EthereumView.swift
//  CryptoWallet
//
//  Created by Allen Melikian on 4/7/23.
//

import Foundation
import SwiftUI
import web3
import BigInt

public struct EthView: View
{
    @State private var isLoading: Bool!
    
    public var body: some View
    {
        NavigationView {
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
//                    Button("Try ETH") { try_ETH() }
//                        .padding()
                    
                    NavigationLink(destination: EthSend()) {
                        Text("Send Ethereum")
                    }
                    
                    //QR CODE
                    Image(uiImage: createQRCode(from: hdwallet.getAddressForCoin(coin: .ethereum)) ?? UIImage())
                        .resizable()
                        .scaledToFit()
                        .padding()
                    //QR CODE END
                    
                    let coinAddress = hdwallet.getAddressForCoin(coin: .ethereum)
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
        }
            .task {
                isLoading = true
                do {
                    ethConnect.blockNum = try await ethConnect.client.eth_blockNumber()
                    ethConnect.ethBal = BigUInt(try await ethConnect.client.eth_getBalance(address: web3.EthereumAddress(stringLiteral: hdwallet.getAddressForCoin(coin: .ethereum)), block: web3.EthereumBlock(rawValue: ethConnect.blockNum)))
                    await checkETHBalance(for: hdwallet.getAddressForCoin(coin: .ethereum))
                    ethConnect.gasPrice = BigUInt(try await ethConnect.client.eth_gasPrice())
                    getEthereumGasPrice()
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
    
    func try_ETH(){
        print("Does nothing ETH is working!")
    }
}

struct EthSend: View {
    @State var ethT = EthTransaction()
    
    @State private var amount: String = ""
    @State private var recipientAddress: String = ""
    @State private var isShowingConfirmView = false
    
    var body: some View{
        ZStack{
            bgColor
                .ignoresSafeArea(.all)
            VStack{
                Text("Balance: " + String(ethConnect.ethBalNormilized!))
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding()
                    .background(Rectangle().foregroundColor(.blue))
                TextField("Amount", text: $amount) {
                    ethT.amount = BigUInt(stringLiteral: amount) * BigUInt(10).power(18)
                }
                .padding()
                .foregroundColor(.blue)
                TextField("Recipient Address", text: $recipientAddress) {
                    ethT.toAddress = recipientAddress
                }
                .padding()
                .foregroundColor(.blue)
                Button("Send")
                {
                    postEthereumTransaction(ethTransaction: ethT)
                    confirmEth()
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
            ethT.gasPrice = ethConnect.gasPrice
            ethT.gasLimit = ethT.gasPrice + 15;
        }
    }
    //maybe create ENUM type for different confirm views
    func confirmEth()
    {
        isShowingConfirmView = true
    }
}
