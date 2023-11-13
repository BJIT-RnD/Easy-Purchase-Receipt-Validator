//
//  File.swift
//  
//
//  Created by BJIT on 9/11/23.
//

import Foundation
/// A utility class for parsing date values encoded as strings in receipts.
enum ReceiptDateParser {
    /// Parses a date from a string encoded in receipt-conform representation.
    ///
    /// - Parameter dateString: A string representing the date.
    /// - Returns: A `Date` object if parsing is successful; otherwise, `nil`.
    static func parseDate(from dateString: String) -> Date? {
        return self.defaultDateFormatter.date(from: dateString)
    }

    /// The date formatter for parsing receipt-conform date strings.
    private static let defaultDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }()
}
