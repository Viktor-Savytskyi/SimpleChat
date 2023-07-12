//
//  FirebaseStorage.swift
//  SimpleChat
//
//  Created by Developer on 11.07.2023.
//

import Foundation
import FirebaseStorage

class FirebaseStorage {
    static let folderName = "Avatars"
    
    static func createRef(image: Data, completion: @escaping ((String?, Error?) -> Void)) {
        let imageRef = Storage.storage().reference().child(folderName).child("\(UUID().uuidString).png")
        imageRef.putData(image, metadata: nil) { (_, error) in
            if let error {
                completion(nil, error)
            } else {
                imageRef.downloadURL { (url, error) in
                    guard let url else { return }
                    completion(url.absoluteString, nil)
                }
            }
        }
    }
}
