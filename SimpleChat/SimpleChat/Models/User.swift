//
//  LoginEntity.swift
//  SimpleChat
//
//  Created by Developer on 10.07.2023.
//

import Foundation

enum UserError: String, Error {
    case convertToJSON = "unable to convert user to JSON"
}

class User: Codable {
    var id: String
    var firstName: String
    var lastName: String
    var imageUrl: String
    var lastOnlineDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName
        case lastName
        case message
        case imageUrl
        case lastOnlineDate
    }
    
    init(id: String = UUID().uuidString, firstName: String, lastName: String, imageUrl: String, lastOnlineDate: Date? = nil) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.imageUrl = imageUrl
        self.lastOnlineDate = lastOnlineDate
    }
    
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(lastOnlineDate, forKey: .lastOnlineDate)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        if let dateString = try container.decodeIfPresent(String.self, forKey: .lastOnlineDate) {
            lastOnlineDate = dateFormatter.date(from: dateString)
        }
    }
    
    func convertToJson() throws -> Data {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            throw UserError.convertToJSON
        }
    }
}
