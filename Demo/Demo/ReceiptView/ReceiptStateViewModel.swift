//
//  ReceiptStateViewModel.swift
//  Demo
//
//  Created by BJIT on 18/10/23.
//

import Foundation

final class ReceiptStateViewModel {
    var isReceiptAvailable: ObservableObject<Bool?> = ObservableObject(nil)
    func doesAppStoreReceiptExist() -> Bool {
        if let receiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: receiptURL.path) {
            isReceiptAvailable.value = true
            return true
        }
        return false
    }
}
