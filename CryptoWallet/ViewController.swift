//
//  ViewController.swift
//  CryptoWallet
//
//  Created by Allen Melikian on 1/25/23.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    @IBAction func testButton(_ sender: Any) {
        let words = getWords()
        let seed = getSeed(words: words)
        let address = getBTCAddress(seed: seed)
        print(address)
        
        checkBalance(address: address) { balance in
            print("Balance: \(balance ?? 0)")
        }
    }
}
