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
                    Button("Try ETH") { try_ETH() }
                        .padding()
                    
                    NavigationLink(destination: EthSend()) {
                        Text("Send Ethereum")
                    }
                    
                    let coinAddress = hdwallet.getAddressForCoin(coin: .ethereum)
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
        }
            .task {
                isLoading = true
                do {
                    ethConnect.blockNum = try await ethConnect.client.eth_blockNumber()
                    ethConnect.ethBal = BigUInt(try await ethConnect.client.eth_getBalance(address: web3.EthereumAddress(stringLiteral: hdwallet.getAddressForCoin(coin: .ethereum)), block: web3.EthereumBlock(rawValue: ethConnect.blockNum)))
                    await checkETHBalance(for: hdwallet.getAddressForCoin(coin: .ethereum))
                    ethConnect.gasPrice = BigUInt(try await ethConnect.client.eth_gasPrice())
                }
                catch{}
                isLoading = false
            }
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
