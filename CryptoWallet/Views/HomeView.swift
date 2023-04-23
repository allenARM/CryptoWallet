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
                  
                    VStack{ //Balance information
                            Text("Balance: " + "$100.00")
                                .foregroundColor(Color.white)
                                .font(.largeTitle)
                                .padding(.bottom, 30.0)
                                
                            
                            ScrollView{
                                VStack(spacing: 5){
                                
                            NavigationLink(destination: EthView()) //Ethereum rectangle
                            {
                                ZStack(alignment: .leading){
                                    RoundedRectangle(cornerRadius: 25.0)
                                        .fill(uiColor)
                                        .frame(width: .infinity, height: 80)
                                        .padding(5)
                                        .shadow(radius: 10)
                                        
                                    HStack(spacing: 60){
                                        Image("Ethereum")
                                            .resizable()
                                            .frame(maxWidth: 60, maxHeight: 60, alignment: .leading)
                                            .padding()
                                            
                                        Text("Ethereum")
                                            .font(.title2)
                                            
                                        
                                    }
                                }
                            }
                            
                            NavigationLink(destination: SolView()) //Solana Rectangle
                            {
                                ZStack(alignment: .leading){
                                    RoundedRectangle(cornerRadius: 25.0)
                                        .fill(uiColor)
                                        .frame(width: .infinity, height: 80)
                                        .padding(5)
                                        .shadow(radius: 10)
                                    
                                    HStack(spacing: 60){
                                        Image("Solana")
                                            .resizable()
                                            .frame(maxWidth: 60, maxHeight: 60, alignment: .leading)
                                            .padding()

                                        Text("Solana")
                                            .font(.title2)
                                            
                                        
                                    }
                                }
                            }
                         
                            
                            NavigationLink(destination: BtcView()) //Bitcoin rectangle
                            {
                                ZStack(alignment: .leading){
                                    RoundedRectangle(cornerRadius: 25.0)
                                        .fill(uiColor)
                                        .frame(width: .infinity, height: 80)
                                        .padding(5)
                                        .shadow(radius: 10)
                                    
                                    HStack(spacing: 60){
                                        Image("Bitcoin")
                                            .resizable()
                                            .frame(maxWidth: 60, maxHeight: 60, alignment: .leading)
                                            .padding()
                                        
                                        Text("Bitcoin")
                                            .font(.title2)
                                        
                                    }
                                }
                            }
                        }
                    }
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
