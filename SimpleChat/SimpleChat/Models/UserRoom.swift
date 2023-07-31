//
//  Room.swift
//  SimpleChat
//
//  Created by Developer on 28.07.2023.
//

import Foundation

class UserRoom: Codable {
    var id: UUID?
    var users: [String]
    var messages: [UserMessage]
    
    init(id: UUID? = nil, users: [String], messages: [UserMessage]) {
        self.id = id
        self.users = users
        self.messages = messages
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case users
        case messages
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id)
        messages = try container.decode([UserMessage].self, forKey: .messages)
        users = try container.decode([String].self, forKey: .users)
    }
}
