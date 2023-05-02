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
                    .font(.title3)
                    .foregroundColor(.white)
//                    .background(Color(.systemBlue))
                    .padding()
                    .background(Capsule().foregroundColor(.gray))
                    
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
//                    ethConnect.blockNum = try await ethConnect.client.eth_blockNumber()
//                    ethConnect.ethBal = BigUInt(try await ethConnect.client.eth_getBalance(address: web3.EthereumAddress(stringLiteral: hdwallet.getAddressForCoin(coin: .ethereum)), block: web3.EthereumBlock(rawValue: ethConnect.blockNum)))
//                    await checkETHBalance(for: hdwallet.getAddressForCoin(coin: .ethereum))
//                    ethConnect.gasPrice = BigUInt(try await ethConnect.client.eth_gasPrice())
//                    getEthereumGasPrice()
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
    @State private var amount: String = ""
    @State private var recipientAddressETH: String = ""
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
                    let result = Decimal(string: amount) ?? 0 * Decimal(pow(10,18))
                    ethT.amount = BigUInt(result.description)
                }
                .padding()
                .foregroundColor(.blue)
                .background(Color(.white))
                
                TextField("Recipient Address", text: $recipientAddressETH) {
                    ethT.toAddress = String(recipientAddressETH)
                }
                .padding()
                .foregroundColor(.blue)
                .background(Color(.white))
                
                Button("Send")
                {
                    let result = Decimal(string: amount)! * Decimal(pow(10,18))
                    let final = BigUInt(result.description)
                    postEthereumTransaction(toAddress: recipientAddressETH, amount: final ?? 0)
                    confirmEth()
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
            ethT.gasPrice = ethConnect.gasPrice
        }
    }
    //maybe create ENUM type for different confirm views
    func confirmEth()
    {
        isShowingConfirmView = true
    }
}
