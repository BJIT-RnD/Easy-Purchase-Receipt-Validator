//
//  ObservableObject.swift
//  Demo
//
//  Created by BJIT on 17/10/23.
//

import Foundation

final class ObservableObject<T> {
    private var listener: ((T) -> Void)?
    var value: T {
        didSet {
            listener?(value)
        }
    }

    init(_ value: T) {
        self.value = value
    }

    func bind(listener: @escaping (T) -> Void) {
        self.listener = listener
    }
}
