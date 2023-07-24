//
//  UserMessage.swift
//  SimpleChat
//
//  Created by Developer on 20.07.2023.
//

import Foundation

struct UserMessage: Codable {
    var id: String? = UUID().uuidString
    var senderID: String
    var receiverID: String
    var message: String
    var roomID: String?
    
    func convertToJsonData() throws -> Data {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            throw UserError.convertToJSON
        }
    }
}
