//
//  ChatManager.swift
//  SimpleChat
//
//  Created by Developer on 18.07.2023.
//

import Foundation

class ChatManager: NSObject {
    var webSocketTask: URLSessionWebSocketTask?
    var messagesArray = [UserMessage]()
    var completion: (() -> Void)?
    
    func setupWebSocket(userID: String, oponentID: String) {
        guard webSocketTask == nil else { return }
        let session = URLSession(configuration: .default,
                                 delegate: self,
                                 delegateQueue: OperationQueue())
        
        let url = URL(string: "ws://127.0.0.1:8080/chat?userID=\(userID)&oponentID=\(oponentID)")!
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        ping()
        reciveMessage() { messages in
            self.messagesArray = messages
            self.completion?()
        }
    }
    
    func closeWebSocket() {
        webSocketTask?.cancel(with: .goingAway, reason: "Connection ended".data(using: .utf8))
    }
    
    func ping() {
        webSocketTask?.sendPing(pongReceiveHandler: { error in
            if let error = error {
                print("Ping error: ", error)
            }
        })
    }
    
    func sendMessage(receiverID: String, message: String) {
        do {
            let userMessage = try UserMessage(senderID: CurrentUser.shared.currentUser.id!,
                                              receiverID: receiverID,
                                              message: message).convertToJsonData()
            let message = URLSessionWebSocketTask.Message.data(userMessage)
            webSocketTask?.send(message) { error in
                if let error {
                    print("websocet couldnt send emssage: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Chat manager" + error.localizedDescription)
        }
    }
    
    func reciveMessage(completion: @escaping ([UserMessage]) -> Void) {
        webSocketTask?.receive { result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    do {
                        let userMessage = try JSONDecoder().decode(UserMessage.self, from: data)
                            self.messagesArray.append(userMessage)
                    } catch {
                        print("Error at decoding data into a single message. Try to decode as array!")
                        do {
                            let userMessages = try JSONDecoder().decode([UserMessage].self, from: data)
                            self.messagesArray = userMessages
                        } catch {
                            print("Error at decoding data into message array of messages")
                        }
                    }
                case .string(let message):
                    print("Message: \(message)")
                default: print("Unknown case")
                }
            case .failure(let error):
                print("Something went wrong \(error.localizedDescription)")
            }
            self.reciveMessage() { messages in
                self.messagesArray = messages
                self.completion?()
            }
            completion(self.messagesArray)
        }
    }
}

extension ChatManager: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
            print("Did connect to webSocket")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Did disconnect to webSocket")
    }
}
