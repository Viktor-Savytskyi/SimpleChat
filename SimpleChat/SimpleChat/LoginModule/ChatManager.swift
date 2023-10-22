//
//  ChatManager.swift
//  SimpleChat
//
//  Created by Developer on 18.07.2023.
//

import Foundation

enum UserTypingState: String {
    case typing
    case stopTyping
}

enum MessageField: String {
    case message
    case senderID
    case receiverID
}

enum WebsocketMessages: String {
    case connectionLost = "Connection lost"
    case connected = "Did connect to webSocket"
    case disconnected = "Did disconnect to webSocket"
}


class ChatManager: NSObject {
    let webSocketHostName = "ws://127.0.0.1:8080/chat?userID="
    var webSocketTask: URLSessionWebSocketTask?
    var messagesArray: [UserMessage]?
    var completion: (() -> Void)?
    var roomsArray = [UserRoom]() {
        didSet {
            tableViewCompletion?()
        }
    }
    var onlineUsers: [String : String?]?
    var tableViewCompletion: (() -> Void)?
    var isOponentTypingCompletion: ((Bool) -> Void)?
    var onlineUsersListCompletion: (() -> Void)?
    var onlineUserCompletion: (() -> Void)?
    
    
    func setupWebSocket(userID: String) {
        guard webSocketTask == nil else { return }
        let session = URLSession(configuration: .default,
                                 delegate: self,
                                 delegateQueue: OperationQueue())
        
        let url = URL(string: webSocketHostName + userID)!
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
        webSocketTask?.cancel(with: .goingAway, reason: WebsocketMessages.connectionLost.rawValue.data(using: .utf8))
    }
    
    func getMessagesHistoryPing() {
        webSocketTask?.sendPing(pongReceiveHandler: { error in
            if let error = error {
                print("Chat manager: Ping error: ", error)
            }
        })
    }
    
    func sendTypingState(userID: String, oponentID: String, userTypingState: UserTypingState) {
        guard let webSocketTask else { return }
        let typingMessage = URLSessionWebSocketTask.Message.string(
                """
                \(MessageField.senderID.rawValue) : \(userID)
                \(MessageField.receiverID.rawValue) : \(oponentID)
                \(MessageField.message.rawValue) : \(userTypingState.rawValue)
                """)
        webSocketTask.send(typingMessage) { error in
            if let error {
                print("Chat manager: Failed to send \(userTypingState) message: \(error)")
            }
        }
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
                    print("Chat manager websocet couldnt send emssage: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Chat manager" + error.localizedDescription)
        }
    }
    
    func reciveMessage(completion: @escaping () -> Void) {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    do {
                        self?.parseImcomingData(data)
                    }
                case .string(let message):
                    let dictMessage = message.convertToDict()
                    let isOponentTyping = dictMessage[MessageField.message.rawValue] == UserTypingState.typing.rawValue
                    if dictMessage[MessageField.message.rawValue] == UserTypingState.typing.rawValue || dictMessage[MessageField.message.rawValue] == UserTypingState.stopTyping.rawValue {
                        self?.isOponentTypingCompletion?(isOponentTyping)
                    } else {
                        self?.onlineUsers = dictMessage
                        self?.onlineUsersListCompletion?()
                        self?.onlineUserCompletion?()
                    }
                default:
                    print("Unknown case")
                }
            case .failure(let error):
                print("Something went wrong \(error.localizedDescription)")
                self?.closeWebSocket()
            }
            self?.reciveMessage() {
                self?.tableViewCompletion?()
                self?.completion?()
            }
            completion()
        }
    }
    
    func parseImcomingData(_ data: Data) {
        do {
            let userMessage = try JSONDecoder().decode(UserMessage.self, from: data)
            roomsArray.forEach { room in
                if room.users.contains(userMessage.senderID) && room.users.contains(userMessage.receiverID) {
                    room.messages.append(userMessage)
                }
            }
        } catch {
            print("Error at decoding data into a SINGLE MESSAGE. Try to decode as array!")
            do {
                let usersRoom = try JSONDecoder().decode(UserRoom.self, from: data)
                if roomsArray.filter({ $0.id == usersRoom.id }).count == 0 {
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
    }
}

extension ChatManager: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print(WebsocketMessages.connected.rawValue)
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print(WebsocketMessages.disconnected.rawValue)
    }
}
