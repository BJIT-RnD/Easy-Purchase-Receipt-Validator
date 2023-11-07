//
//  RestoreViewModel.swift
//  Demo
//
//  Created by BJIT on 17/10/23.
//

import Foundation
import StoreKit

final class RestoreViewModel {
    var fetchList: ObservableObject<[SKPaymentTransaction]?> = ObservableObject(nil)
    
    func restoreCompletedTransactions() {
        IAPHelper.shared.restoreProducts()
    }
}
