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
                //REMOVE AT REALEASE
                let words = "today unfold raise orphan section talent rotate abuse throw entire media square"
                hdwallet = HDWallet(mnemonic: words, passphrase: "")
                print("HDWALLET CREATED")
            }
        }
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

struct HomeView_Previews: PreviewProvider{
    static var previews: some View{
        HomeView()
    }
}
