//
//  ContentView.swift
//  CryptoWallet
//
//  Created by Ashot Alajanyan on 3/5/23.
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

public var hdwallet:HDWallet!

let bgColor = Color(red: 19/255, green: 33/255, blue: 45/255)
let uiColor = Color(red:30/255, green:44/255, blue:55/255)
let buttonColor = Color(red:54/255, green:115/255, blue:218/255)

struct ContentView: View {
    
    var body: some View {
        NavigationView{
            ZStack{
                bgColor
                    .ignoresSafeArea(.all)
                VStack(spacing: 20) {
                    Spacer()
                    Image("Logo")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .padding()
                    
                    Spacer()
                    
                    NavigationLink(destination: LoginView()){
                        Text("Login to existing wallet")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(8)
                            .padding(.horizontal, 25)
                    }
                    NavigationLink(destination: CreateWalletView()) {
                        Text("Create a new wallet")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .background(Color.gray)
                            .cornerRadius(8)
                            .padding(.horizontal, 25)
                    }
                    
                    NavigationLink(destination: HomeView())
                    {
                        Text("Go to homeview (Login Test)")
                        
                    }
                    .padding(.bottom, 25.0)
                    .onSubmit {
//                        let words = "today unfold raise orphan section talent rotate abuse throw entire media square"
                        let words = "section pair clay machine garbage rocket rubber pitch mom assist flavor obtain"
                        hdwallet = HDWallet(mnemonic: words, passphrase: "")
                    }
                }
              
                .task {
                    do {
                        
                        
                    }
                    catch{}
                }
            }
        }
    }

    
    // MOVED ALL "TRY" CODE TO HOMEVIEW
    struct LoginView: View {
        @State private var TextField12Words = ""
        @State private var words: [String] = []
        @State private var isShowingHomeView = false
        
        @State private var accountSecretKey: Data?

        
        var body: some View {
            ZStack{
                bgColor
                    .ignoresSafeArea(.all)
                VStack{
                    TextField("12 Words", text: $TextField12Words)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .autocapitalization(.none)
                        
                    
                    if(words.count < 11)
                    {
                        Button("Add word") {
                            words.append(TextField12Words)
                            TextField12Words = ""
                        }
                    } else{
                        Button("Login")
                        {
                            words.append(TextField12Words)
                            TextField12Words = ""
//                            login()
                            hdwallet = getWallet(words: words)

                            self.isShowingHomeView = true
                        }
                    }
                }
                .fullScreenCover(isPresented: $isShowingHomeView){
                    HomeView()
                }
            }
        }
}
    
    struct CreateWalletView: View {
//        @State private var words: [String] = []

        var body: some View {
            let words = getWords()
            ZStack{
                bgColor
                    .ignoresSafeArea(.all)
                VStack{
                    HStack {
                        VStack {
                            Text("This is your secret key.")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: CGFloat(20)).foregroundColor(.gray))
                            Text("Please write it down and save it in safe place. You will need it to loging to your account")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: CGFloat(20)).foregroundColor(.blue))
                            Text("Never share your secret key with anyone.")
                                .font(.title3)
                                .foregroundColor(.red)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: CGFloat(20)).foregroundColor(.white))
                        }
                    }
                    HStack {
                        VStack {
                            Text("1: " + words[0])
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding()
                                .background(Capsule().foregroundColor(.blue))
                            Text("2: " + words[1])
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding()
                                .background(Capsule().foregroundColor(.blue))
                            Text("3: " + words[2])
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding()
                                .background(Capsule().foregroundColor(.blue))
                            Text("4: " + words[3])
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding()
                                .background(Capsule().foregroundColor(.blue))
                            Text("5: " + words[4])
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding()
                                .background(Capsule().foregroundColor(.blue))
                            Text("6: " + words[5])
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding()
                                .background(Capsule().foregroundColor(.blue))
                        }
                        VStack {
                            Text("7: " + words[6])
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding()
                                .background(Capsule().foregroundColor(.blue))
                            Text("8: " + words[7])
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding()
                                .background(Capsule().foregroundColor(.blue))
                            Text("9: " + words[8])
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding()
                                .background(Capsule().foregroundColor(.blue))
                            Text("10: " + words[9])
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding()
                                .background(Capsule().foregroundColor(.blue))
                            Text("11: " + words[10])
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding()
                                .background(Capsule().foregroundColor(.blue))
                            Text("12: " + words[11])
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding()
                                .background(Capsule().foregroundColor(.blue))
                        }
                    }
                }
            }
        }
        
        func createWalletButtonTapped() {
            // Split the input into individual words and display them
//            words = getWords()
//            for word in words {
//                print(word)
//            }
        }
    }
}

struct ContentView_Previews: PreviewProvider{
    static var previews: some View{
        ContentView()
    }
}
