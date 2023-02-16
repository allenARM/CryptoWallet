//
//  ViewController.swift
//  CryptoWallet
//
//  Created by Allen Melikian on 1/25/23.
//

import UIKit
import WalletCore

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    //FIRST STORYBOARD
    @IBAction func testButton(_ sender: Any) {
        let words = getWords()
        print(words)
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
        
        getLatestTransactionHashForBTCAddress(address: "muGuqWmcHpjmB2rBpdbTnCwD18wnrWCjBB") {
            txid, index, value in
            print("TXID: \(txid)")
            print("Address: \(index)")
            print("Value: \(value)")
        }
        
//        checkBalance(address: solAddress) { balance in
//            print("SOL Balance: \(balance ?? 0)")
//        }
    }
    
    //SECOND STORYBOARD
    @IBAction func LoginButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "twelveWords")
        self.present(vc, animated: true)
    }
    
    @IBAction func backButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "main")
        self.present(vc, animated: true)
    }
    
    
    @IBOutlet var TextField12Words: [UITextField]!
    
    
    @IBAction func Login(_ sender: Any) {
//        Check if there are any missing words
        if (noMissingWords(twelveWords: TextField12Words) == false) {
            print("INCORRECT WORDS")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "main")
            self.present(vc, animated: true)
            return;
        }
        var words: [String] = []
        for word in TextField12Words {
            words.append(word.text!)
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
    }
}
