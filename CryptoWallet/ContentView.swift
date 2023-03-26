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
            } else{
                Button("Login")
                {
                    words.append(TextField12Words)
                    TextField12Words = ""
                    addingWords()
                }
            }
            
            Button("Try ME") { try_ETH() }
        }
        func try_ETH(){
            checkETHBalance(for: "0xb28C08e98aA98d94917851C1C99e5F13C3561eb8") { result in
                switch result {
                case .success(let balance):
                    print("Balance: \(balance) ETH")
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
        func try_SOL()
        {
            checkSOLBalance(for: "J6vcaEVVLfd6Cf8b8X5J8pr85yWokgDz5TJTrCpsdD4p") { result in
                switch result {
                case .success(let balance):
                    print("Balance: \(balance) SOL")
                case .failure(let error):
                    print("Error: \(error)")
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
