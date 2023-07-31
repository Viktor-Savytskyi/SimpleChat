//
//  UserMessage.swift
//  SimpleChat
//
//  Created by Developer on 20.07.2023.
//

import Foundation

class UserMessage: Codable {
    var id: UUID
    var senderID: String
    var receiverID: String
    var message: String
    var createdAt: Date?
    var room: Room?
    
    enum CodingKeys: String, CodingKey {
        case id
        case senderID
        case receiverID
        case message
        case createdAt
        case room
    }
    
    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
    
    
    init(id: UUID = UUID(), senderID: String, receiverID: String, message: String, createdAt: Date? = nil, room: Room? = nil) {
        self.id = id
        self.senderID = senderID
        self.receiverID = receiverID
        self.message = message
        self.createdAt = createdAt
        self.room = room
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        senderID = try container.decode(String.self, forKey: .senderID)
        receiverID = try container.decode(String.self, forKey: .receiverID)
        message = try container.decode(String.self, forKey: .message)
        if let dateString = try container.decodeIfPresent(String.self, forKey: .createdAt) {
            createdAt = UserMessage.dateFormatter.date(from: dateString)
        }
        room = try container.decodeIfPresent(Room.self, forKey: .room)
    }
    
    func convertToJsonData() throws -> Data {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            throw UserError.convertToJSON
        }
    }
}

struct Room: Codable {
    var id: String
}
