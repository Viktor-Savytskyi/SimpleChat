//
//  ChatManager.swift
//  SimpleChat
//
//  Created by Developer on 18.07.2023.
//

import Foundation

class ChatManager: NSObject {
    var webSocketTask: URLSessionWebSocketTask?
    var messagesArray: [UserMessage]?
    var completion: (() -> Void)?
    var roomsArray = [UserRoom]() {
        didSet {
            tableViewCompletion?()
        }
    }
    var tableViewCompletion: (() -> Void)?
    
    func setupWebSocket(userID: String) {
        guard webSocketTask == nil else { return }
        let session = URLSession(configuration: .default,
                                 delegate: self,
                                 delegateQueue: OperationQueue())
        
        let url = URL(string: "ws://127.0.0.1:8080/chat?userID=\(userID)")!
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        getMessagesHistoryPing()
        reciveMessage() {
            self.completion?()
        }
    }
    
    func getRoomMessages(userID: String, opponentID: String) {
        messagesArray = []
        messagesArray = roomsArray.first(where: { room in
            if userID != opponentID {
                return room.users.contains(userID) && room.users.contains(opponentID)
            } else {
                // check is room twice containe userID (is it owner`s self chat)
                return room.users.filter { $0 == userID }.count == 2
            }
        })?.messages
    }
    
    func closeWebSocket() {
        webSocketTask?.cancel(with: .goingAway, reason: "Connection lost".data(using: .utf8))
    }
    
    func getMessagesHistoryPing() {
        webSocketTask?.sendPing(pongReceiveHandler: { error in
            if let error = error {
                print("Ping error: ", error)
            }
        })
    }
    
    func sendMessage(receiverID: String, message: String) {
        do {
            let userMessage = UserMessage(senderID: CurrentUser.shared.currentUser.id,
                                          receiverID: receiverID,
                                          message: message)
            let decodedUserMessage = try userMessage.convertToJsonData()
            let message = URLSessionWebSocketTask.Message.data(decodedUserMessage)
            webSocketTask?.send(message) { error in
                if let error {
                    print("websocet couldnt send emssage: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Chat manager" + error.localizedDescription)
        }
    }
    
    func reciveMessage(completion: @escaping () -> Void) {
        webSocketTask?.receive { result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    do {
                        let userMessage = try JSONDecoder().decode(UserMessage.self, from: data)
                        self.roomsArray.forEach { room in
                             if room.users.contains(userMessage.senderID) && room.users.contains(userMessage.receiverID) {
                                room.messages.append(userMessage)
                            }
                        }
                    } catch {
                        print("Error at decoding data into a single message. Try to decode as array!")
                        do {
                            let usersRoom = try JSONDecoder().decode(UserRoom.self, from: data)
                            if self.roomsArray.filter( { $0.id == usersRoom.id }).count == 0 {
                                self.roomsArray.append(usersRoom)
                            }
                        } catch {
                            print("Error at decoding data into ROOM MODEL \(error)")
                            do {
                                let rooms = try JSONDecoder().decode([UserRoom].self, from: data)
                                self.roomsArray = rooms
                            } catch {
                                print("Error at decoding data into message array of messages \(error)")
                            }
                        }
                        
                    }
                case .string(let message):
                    print("Message: \(message)")
                default:
                    print("Unknown case")
                }
            case .failure(let error):
                print("Something went wrong \(error.localizedDescription)")
                self.closeWebSocket()
            }
            self.reciveMessage() {
                self.tableViewCompletion?()
                self.completion?()
            }
            completion()
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
