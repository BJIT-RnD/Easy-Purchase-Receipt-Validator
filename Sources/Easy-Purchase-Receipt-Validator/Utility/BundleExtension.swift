//
//  BundleExtension.swift
//  
//
//  Created by BJIT on 10/11/23.
//

import Foundation

extension Bundle {

    /// Returns the appropriate app version for receipt validation.
    var appVersion: String? {
        #if targetEnvironment(macCatalyst) || os(macOS)
        // For macOS and Mac Catalyst, use "CFBundleShortVersionString" for version
        let versionKey: String = "CFBundleShortVersionString"
        #else
        // For other platforms, use "CFBundleVersion" for version
        let versionKey: String = "CFBundleVersion"
        #endif

        guard let version = infoDictionary?[versionKey] as? String else {
            // Unable to retrieve the app version
            return nil
        }
        return version
    }
}
