//
//  Utils.swift
//  CryptoWallet
//
//  Created by Ashot Alajanyan on 3/26/23.
//

import Foundation
import SwiftUI

public func noMissingWords(twelveWords: [String]) -> Bool {
    
    for word in twelveWords {
        if(word == "") {
            return false;
        }
    }
    return true;
}

public func createQRCode(from string: String) -> UIImage? {
    let data = string.data(using: String.Encoding.ascii)
    guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
    qrFilter.setValue(data, forKey: "inputMessage")
    let transform = CGAffineTransform(scaleX: 10, y: 10)
    guard let qrImage = qrFilter.outputImage?.transformed(by: transform) else { return nil }
    
    // Convert the CIImage to a UIImage
    let context = CIContext()
    guard let cgImage = context.createCGImage(qrImage, from: qrImage.extent) else { return nil }
    return UIImage(cgImage: cgImage)
}
