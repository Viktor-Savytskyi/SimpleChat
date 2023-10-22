//
//  DateFormatter+Extension.swift
//  SimpleChat
//
//  Created by Developer on 22.10.2023.
//

import Foundation

enum DateFormat: String {
    case yyyyMMdd = "yyyy-MM-dd'T'HH:mm:ssZ"
}

extension DateFormatter {
    static func setDateFormat() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat.yyyyMMdd.rawValue
        return dateFormatter
    }
}
