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

struct User: Codable {
    var firstName: String
    var lastName: String
    var imageUrl: String
    
    func convertToJson() throws -> Data {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            throw UserError.convertToJSON
        }
    }
}
