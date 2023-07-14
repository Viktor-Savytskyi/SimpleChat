//
//  NetworkingManager.swift
//  SimpleChat
//
//  Created by Developer on 13.07.2023.
//

import Foundation

class NetworkingManager {
    let users = "users"
    let value = "application/json"
    let contentType = "Content-Type"
    
    func createUser() {
        guard let url = URL(string: "http://localhost:8080/\(users)") else { return }
        
        // Створюємо об'єкт користувача
        let user = User(firstName: "your-image-url",
                        lastName: "John",
                        image: "Doe")
        
        do {
            let jsonData = try JSONEncoder().encode(user)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue(value, forHTTPHeaderField: contentType)
            request.httpBody = jsonData
            
            // Виконуємо запит
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                if let data = data {
                    print("User saved successfully!")
                }
            }.resume()
        } catch {
            // Обробка помилки кодування в JSON
            print("Error encoding user: \(error.localizedDescription)")
        }
    }
    
    func getUsers() {
        guard let url = URL(string: "http://localhost:8080/\(users)") else { return }
        
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                // Обробка помилки
                print("Помилка: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                // Обробка невдачі запиту
                print("Невдача запиту: \(response)")
                return
            }

            if let data = data {
                do {
                    // Розпарсити отримані дані в масив користувачів
                    let users = try JSONDecoder().decode([User].self, from: data)
                    
                    // Вивести отриманих користувачів
                    for user in users {
                        print("Юзер: \(user.firstName) \(user.lastName)")
                    }
                } catch {
                    // Обробка помилки розпарсингу даних
                    print("Помилка розпарсингу даних: \(error.localizedDescription)")
                }
            }
        }

        task.resume()
    }
}
