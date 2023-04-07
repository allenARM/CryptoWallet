//
//  SolanaView.swift
//  CryptoWallet
//
//  Created by Allen Melikian on 4/7/23.
//

import SwiftUI
import Foundation
import SolanaWeb3

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
                    Text("Balance: " + String(solConnect.solBal ?? 987654321))
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding()
                        .background(Capsule().foregroundColor(.blue))
                }
                Button("Try Sol")
                {
                    try_SOL()
                }
                let coinAddress = hdwallet.getAddressForCoin(coin: .solana)
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
            isLoading = true
            do {
                solConnect.account = try SolanaWeb3.Account(secretKey: hdwallet.getKeyForCoin(coin: .solana).data, publicKey: hdwallet.getKeyForCoin(coin: .solana).getPublicKey(coinType: .solana).data)

                if (solConnect.account.publicKey.base58 == hdwallet.getAddressForCoin(coin: .solana)) {
                    print("Solana account restored")
                }
                solConnect.client.getBalance(publicKey: solConnect.account.publicKey) {result in switch result{
                case .success(let balance):
                    solConnect.solBal = balance
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
        

    }
}
