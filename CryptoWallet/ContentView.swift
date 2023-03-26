//
//  ContentView.swift
//  CryptoWallet
//
//  Created by Ashot Alajanyan on 3/5/23.
//

import SwiftUI

struct ContentView: View {
    

    
    var body: some View {
        NavigationView{
            VStack {
                Image(systemName: "person.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .padding()
                
                
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
                        .background(Color.green)
                        .cornerRadius(8)
                        .padding(.horizontal, 25)
                }
            }
        }
    }
    
    
    struct LoginView: View {
        @State private var TextField12Words = ""
        @State private var words: [String] = []
        
        
        var body: some View {
            
            TextField("12 Words", text: $TextField12Words)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            if(words.count < 11)
            {
                Button("Add word") {
                    words.append(TextField12Words)
                    TextField12Words = ""
                }
            }else{
                Button("Login")
                {
                    words.append(TextField12Words)
                    TextField12Words = ""
                    addingWords()
                }
            }
        }
            func addingWords()
            {
                if (noMissingWords(twelveWords: words) == false) {
                    print("INCORRECT WORDS")
                }
                let hdwallet = getWallet(words: words)
                let btcAddress = hdwallet.getAddressForCoin(coin: .bitcoin)
                print("BTC: " + btcAddress)
                let ethAddress = hdwallet.getAddressForCoin(coin: .ethereum)
                print("ETH: " + ethAddress)
                let solAddress = hdwallet.getAddressForCoin(coin: .solana)
                print("SOL: " + solAddress)
                
                checkBTCBalance(address: btcAddress) { balance in
                    print("BTC Balance: \(balance ?? 0)")
                }
                
                getLatestTransactionHashForBTCAddress(address: btcAddress) {
                    txid, index, value in
                    print("TXID: \(txid)")
                    print("ID: \(index)")
                    print("Value: \(value)")
                }
            }
            
    }
    
    
    struct CreateWalletView: View {
        
        
        
        var body: some View {
            Text("Create Wallet")
        }
        
        func createWalletButtonTapped() {
            // Implement wallet creation functionality here
            // Then dismiss the view
        }
    }
}

struct ContentView_Previews: PreviewProvider{
    static var previews: some View{
        ContentView()
    }
}
