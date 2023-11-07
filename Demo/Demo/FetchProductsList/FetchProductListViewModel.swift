//
//  FetchProductListViewModel.swift
//  Demo
//
//  Created by BJIT on 17/10/23.
//

import Foundation
import StoreKit

struct FetchList {
    let consumable: [SKProduct]
    let nonConsumable: [SKProduct]
    let nonRenewable: [SKProduct]
    let autoRenewable: [SKProduct]
}

final class FetchProductListViewModel {
    var fetchedProducts: [SKProduct] = [] {
        didSet {
            createProductDictionary(fetchedProducts)
            filterProductsByType(fetchedProducts)
        }
    }
    var fetchList: ObservableObject<FetchList?> = ObservableObject(nil)
    let productsList = [
        "com.bjitgroup.easypurchase.consumable.tencoin",
        "com.bjitgroup.easypurchase.consumable.twentycoin",
        "com.bjitgroup.easypurchase.consumable.thirtycoin",
        "com.bjitgroup.easypurchase.nonconsumable.levelone",
        "com.bjitgroup.easypurchase.nonconsumable.leveltwo",
        "com.bjitgroup.easypurchase.nonconsumable.levelthree",
        "com.bjitgroup.easypurchase.nonRenewable.twenty",
        "com.bjitgroup.easypurchase.nonRenewable.thirty",
        "com.bjitgroup.easypurchase.nonRenewable.forty",
        "com.bjitgroup.easypurchase.autorenewweekly",
        "com.bjitgroup.easypurchase.autorenewmonthly",
        "com.bjitgroup.easypurchase.autorenewyearly"
    ]
    func getPurchasableProducts() {
        IAPHelper.shared.fetchProductsData(type: productsList)
    }
    func buyProduct(_ product: SKProduct) {
        IAPHelper.shared.buy(product)
    }
    private func determineProductType(for product: SKProduct) -> ProductType? {
        let productIdentifier = product.productIdentifier
        print(productIdentifier)
        if productIdentifier.contains(".consumable") {
            return .consumable
        } else if productIdentifier.contains(".nonconsumable") {
            return .nonConsumable
        } else if productIdentifier.contains(".nonRenewable") {
            return .nonRenewableSubscription
        } else if productIdentifier.contains(".autorenew") {
            return .autoRenewableSubscription
        }
        // If the product doesn't match any known type, return nil or an appropriate default type.
        return nil
    }
    private func filterProductsByType(_ products: [SKProduct]) {
        var consumables: [SKProduct] = []
        var nonConsumables: [SKProduct] = []
        var nonRenewables: [SKProduct] = []
        var autoRenewables: [SKProduct] = []
        for product in products {
            if let productType = determineProductType(for: product) {
                switch productType {
                case .consumable:
                    consumables.append(product)
                case .nonConsumable:
                    nonConsumables.append(product)
                case .nonRenewableSubscription:
                    nonRenewables.append(product)
                case .autoRenewableSubscription:
                    autoRenewables.append(product)
                }
            }
        }
        consumables = consumables.sorted { product1, product2 -> Bool in
            return product1.price.compare(product2.price) == .orderedAscending
        }
        nonConsumables = nonConsumables.sorted { product1, product2 -> Bool in
            return product1.price.compare(product2.price) == .orderedAscending
        }
        nonRenewables = nonRenewables.sorted { product1, product2 -> Bool in
            return product1.price.compare(product2.price) == .orderedAscending
        }
        autoRenewables = autoRenewables.sorted { product1, product2 -> Bool in
            return product1.price.compare(product2.price) == .orderedAscending
        }
        fetchList.value = FetchList(consumable: consumables, nonConsumable: nonConsumables, nonRenewable: nonRenewables, autoRenewable: autoRenewables)
    }
    private func createProductDictionary(_ fetchedProducts: [SKProduct]) {
        for index in 0..<fetchedProducts.count {
            Constants.availableProductsCollection[fetchedProducts[index].productIdentifier] = fetchedProducts[index]
        }
    }
}
