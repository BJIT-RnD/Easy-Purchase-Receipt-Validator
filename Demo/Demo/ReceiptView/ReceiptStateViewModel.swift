//
//  ReceiptStateViewModel.swift
//  Demo
//
//  Created by BJIT on 18/10/23.
//

import Foundation
import Security

final class ReceiptStateViewModel {
    var isReceiptAvailable: ObservableObject<Bool?> = ObservableObject(nil)

    func doesAppStoreReceiptExist() -> Bool {

        if let receiptString = UserDefaults.standard.string(forKey: Constants.receiptDataKey) {
            return true
        }

        if let receiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: receiptURL.path) {
            isReceiptAvailable.value = true
            //Access the Reciept data from url and save to user defaults
            do {
                let receiptData = try Data(contentsOf: receiptURL, options: .alwaysMapped)
                let recieptString = receiptData.base64EncodedString()
                UserDefaults.standard.setValue(recieptString, forKey: Constants.receiptDataKey)
            } catch {
            }
            return true
        }
        return false
    }
    func refreshReceipt(){
        IAPHelper.shared.refreshReceipt()
    }
}
