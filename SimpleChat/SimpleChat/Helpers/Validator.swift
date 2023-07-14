//
//  Validator.swift
//  SimpleChat
//
//  Created by Developer on 14.07.2023.
//

import Foundation

enum ValidationError: Error {
    case firstName
    case lastName
    case imageUrl
    
    var description: String {
        switch self {
        case .firstName:
            return "first name validation error"
        case .lastName:
            return "first name validation error"
        case .imageUrl:
            return "user image URL validation error"

        }
    }
}

protocol UserValidatorProtocol {
    func validateUser(firstName: String?, lastName: String?, imageUrl: String?) throws
}

final class UserValidator {
    
    private let mockUser = User(firstName: "1111", lastName: "1111", imageUrl: "1111")
    private var errorType: ValidationError!
    
    func validateUser(firstName: String?, lastName: String?, imageUrl: String?) throws -> User {
        guard let firstName, firstName == mockUser.firstName || firstName.count < 1  else { throw ValidationError.firstName }
        guard let lastName, lastName == mockUser.lastName    || lastName.count < 1   else { throw ValidationError.lastName }
        guard let imageUrl, imageUrl == mockUser.imageUrl    || imageUrl.count < 1   else { throw ValidationError.imageUrl }
        return User(firstName: firstName, lastName: lastName, imageUrl: imageUrl)
    }
}
