//
//  NetworkingManager.swift
//  SimpleChat
//
//  Created by Developer on 13.07.2023.
//

import Foundation

enum Result<T> {
    case success(T)
    case error(String)
}

final class NetworkingManager {
    private let users = "users"
    private let value = "application/json"
    private let contentType = "Content-Type"
    
    func createUser(user: User, completion: @escaping (() -> Void)) {
        guard let url = URL(string: "http://localhost:8080/\(users)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(value, forHTTPHeaderField: contentType)
        
        do {
            request.httpBody = try user.convertToJson()
        } catch {
            print((error as! UserError).localizedDescription)
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error {
                print("Error: \(error.localizedDescription)")
                return
            } else if data != nil {
                completion()
            }
        }.resume()
    }
    
    func getUsers(completion: @escaping (Result<[User]>) -> Void) {
        guard let url = URL(string: "http://localhost:8080/\(users)") else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(Result.error(error.localizedDescription))
            } else if let data = data {
                do {
                    let users = try JSONDecoder().decode([User].self, from: data)
                    completion(Result.success(users))
                } catch {
                    completion(Result.error(error.localizedDescription))
                }
            }
        }
        task.resume()
    }
}
