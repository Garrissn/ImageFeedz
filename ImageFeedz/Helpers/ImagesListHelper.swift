//
//  ImagesListHelper.swift
//  ImageFeedz
//
//  Created by Игорь Полунин on 09.06.2023.
//

import Foundation

protocol ImagesListHelperProtocol {
    var isoDateFormatter: ISO8601DateFormatter { get }
    var dateFormatter: DateFormatter {  get }
}
class ImagesListHelper: ImagesListHelperProtocol {
    internal lazy var isoDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        return formatter
    }()
    internal lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()
    
}
