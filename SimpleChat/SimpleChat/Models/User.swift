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
    var id: String = UUID().uuidString
    var firstName: String
    var lastName: String
    var imageUrl: String
    var lastOnlineDate: Date?
    
    func convertToJson() throws -> Data {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            throw UserError.convertToJSON
        }
    }
}

class CurrentUser {
    
    static let shared = CurrentUser()
    
    init() { }
    
    var currentUser: User!
    
//    func createUser(firstName: String) {
//        if firstName == "1" {
//            currentUser = User(id: "519D0148-2D43-4E9A-B40C-CC3C00AEF9F4",
//                               firstName: "Current",
//                               lastName: "Current",
//                               imageUrl: "https://firebasestorage.googleapis.com:443/v0/b/simplechat-dc2d0.appspot.com/o/Avatars%2F8535D8DC-BF07-47AC-AEB6-5783327A5B7C.png?alt=media&token=b34456aa-bb6b-411c-9254-70dda385df59")
//        } else if firstName == "2" {
//            currentUser = User(id: "544D7151-06E8-4109-819C-1F9C5A224A50",
//                               firstName: "victor",
//                               lastName: "victor",
//                               imageUrl: "https://firebasestorage.googleapis.com:443/v0/b/simplechat-dc2d0.appspot.com/o/Avatars%2F48373DEC-EDEE-486B-8947-654B0DA70E18.png?alt=media&token=ae934407-1d0c-4980-b849-afa1e0481218")
//        } else if firstName == "3" {
//            currentUser = User(id: "68BFF7F8-2753-4586-B9E3-01FA658E484D",
//                               firstName: "vacation",
//                               lastName: "vacation",
//                               imageUrl: "https://firebasestorage.googleapis.com:443/v0/b/simplechat-dc2d0.appspot.com/o/Avatars%2F5BE3D190-2060-4B06-9931-93B7B7FCDD82.png?alt=media&token=bf6a4c02-3cb1-4b03-a3de-2ba630751005")
//        }
//    }
}
