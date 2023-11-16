//
//  BundleExtension.swift
//
//  Description: This file contains the implementation of the `BundleExtension`,
//  which is an extension for Bundle providing additional functionality.
//  It includes a method to retrieve the appropriate app version for receipt validation.
//  Created by BJIT on 10/11/23.
//
import Foundation

extension Bundle {
    /// Returns the app version for receipt validation.
    ///
    /// - Note: This method uses the appropriate key (`CFBundleShortVersionString` for macOS and Mac Catalyst, `CFBundleVersion` for other platforms)
    ///
    /// - Returns: The app version string, or `nil` if unable to retrieve.
    var bundleVersion: String? {
        #if targetEnvironment(macCatalyst) || os(macOS)
        let versionKey: String = "CFBundleShortVersionString"
        #else
        let versionKey: String = "CFBundleVersion"
        #endif

        guard let version = infoDictionary?[versionKey] as? String else {
            return nil
        }
        return version
    }
}
