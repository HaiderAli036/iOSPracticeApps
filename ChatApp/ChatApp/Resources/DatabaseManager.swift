import FirebaseDatabase
import Foundation

final class DatabaseManager{
    
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
    static func safeEmail(email:String) -> String{
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    public enum DatabaseErrors: Error {
        case failedToFetch
    }
    
}

//MARK: User Account Management
extension DatabaseManager{
    
    ///Validating new user email
    public func validateUser(wiht email:String, completion:@escaping((Bool)->Void)){
        let safeEmail = DatabaseManager.safeEmail(email: email)
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard snapshot.value as? String != nil else{
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    ///Creating new user
    public func createUser(for user:ChatAPPUser,completion:@escaping(Bool)->Void ){
        
        database.child(user.safeEmail).setValue([
            "first_name":user.firstName,
            "last_name":user.lastName
        ],withCompletionBlock: { error, _ in
            guard error == nil else{
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value, with:{ snapshot in
                if var userCollection = snapshot.value as? [[String:String]]{
                    print(user.firstName+" "+user.lastName)
                    userCollection.append([
                        "email":user.safeEmail,
                        "name":user.firstName+" "+user.lastName
                    ])
                    
                    self.database.child("users").setValue(userCollection,withCompletionBlock: {error, _ in
                        guard error == nil else{
                            print("failed to write to database")
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                    
                }else{
                    let newCollection:[[String:String]] = [
                        [
                            "email":user.safeEmail,
                            "name":user.firstName+" "+user.lastName
                        ]
                    ]
                    self.database.child("users").setValue(newCollection,withCompletionBlock: {error, _ in
                        guard error == nil else{
                            print("failed to write to database")
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                    //create new users
                }
            })
            completion(true)
            return
            
        });
    }
    
    func fetchDataFromDatabase(completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            
            if snapshot.exists(), let data = snapshot.value as? [[String: Any]]{
                
                completion(.success(data))
                
            } else {
                completion(.failure(DatabaseErrors.failedToFetch))
            }
        }
    }
    
}

extension DatabaseManager{
    //get data for path
    public func getDataFor(path:String,completion:@escaping(Result<Any,Error>)->Void){
        print(path)
        self.database.child(path).observeSingleEvent(of: .value, with: {snapshot in
            guard var value  = snapshot.value as? [String:Any ] else{
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
    
    public func getMyConversations(path:String,completion:@escaping(Result<[[String:Any]] ,Error>)->Void){
        print(path)
        self.database.child(path).observeSingleEvent(of: .value, with: {snapshot in
            guard var value  = snapshot.value as? [[String:Any ]] else{
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
    
}
//MARK: Chat Management
extension DatabaseManager{
    
    public func createNewChat(with otherUserEmail:String,otherUserName:String,firstMessage:Message,completion:@escaping(Bool)->Void ){
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "user_email") as? String else{
            return
        }
        guard let currentUserName = UserDefaults.standard.value(forKey: "user_name") as? String else{
            return
        }
        
        let currentUserSafeEmail = DatabaseManager.safeEmail(email: currentUserEmail)
        
        let ref = database.child("\(currentUserSafeEmail)")
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            guard var userNode  = snapshot.value as? [String:Any ] else{
                completion(false)
                return
            }
            let messageDate = firstMessage.sentDate
            let dateString = ChatVC.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationID = "conversation_\(firstMessage.messageId)"
            let newConversationData:[String:Any] = [
                "id": conversationID,
                "other_user_email":otherUserEmail,
                "name":otherUserName,
                "latest_message":[
                    "date": dateString,
                    "is_read":false,
                    "message":message
                ]
            ]
            
            let recipientNewConversationData:[String:Any] = [
                "id": conversationID,
                "other_user_email":currentUserSafeEmail,
                "name":currentUserName,
                "latest_message":[
                    "date": dateString,
                    "is_read":false,
                    "message":message
                ]
            ]
            
            //update recipient data
            self.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with:{ [weak self] snapshot in
                if var conversations = snapshot.value as?  [[String:Any]]{
                    //append
                    conversations.append(recipientNewConversationData)
                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversations)
                }else{
                    //create
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipientNewConversationData])
                }
            })
            //update sender data
            if var conversations = userNode["conversations"] as? [[String:Any]]{
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error==nil else{
                        completion(false)
                        return
                    }
                    self?.finishCreatingChat(conversationID: conversationID,otherUserName: otherUserName, firstMessage: firstMessage, completion:completion)
                    completion(true)
                })
            }else{
                userNode["conversations"] = [
                    newConversationData
                ]
                ref.setValue(userNode, withCompletionBlock: {[weak self] error, _ in
                    guard error==nil else{
                        completion(false)
                        return
                    }
                    self?.finishCreatingChat(conversationID: conversationID,otherUserName: otherUserName, firstMessage: firstMessage, completion:completion)
                    completion(true)
                })
            }
            completion(true)
        })
    }
    
    func finishCreatingChat(conversationID:String,otherUserName:String,firstMessage:Message,completion:@escaping(Bool)->Void){
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatVC.dateFormatter.string(from: messageDate)
        
        var message = ""
        
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        guard let userEmail = UserDefaults.standard.string(forKey: "user_email") else{
            completion(false)
            return
        }
        let safeEmail = DatabaseManager.safeEmail(email: userEmail)
        
        let collectionMessage:[String:Any] = [
            "id":firstMessage.messageId,
            "type":firstMessage.kind.messageKindString,
            "content":message,
            "date":dateString,
            "sender_email":safeEmail,
            "is_read":false,
            "name":otherUserName
        ]
        
        let value:[String:Any] = [
            "messages":[collectionMessage]
        ]
        
        database.child("\(conversationID)").setValue(value,withCompletionBlock: {error,_ in
            guard error == nil else{
                print("failed to write to database")
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    func getAllChatsFromDatabase(for email:String, completion: @escaping (Result<[conversation], Error>) -> Void) {
        database.child("\(email)/conversations").observe(.value, with: {[weak self] snapshot in
            
            guard let value = snapshot.value as? [[String:Any]] else{
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            
            let conversations:[conversation] = value.compactMap({ disctionary in
                guard let conversationId = disctionary["id"] as? String,
                      let name = disctionary["name"] as? String,
                      let otherUserEmail = disctionary["other_user_email"] as? String,
                      let latestMessage = disctionary["latest_message"] as? [String:Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else{
                    completion(.failure(DatabaseErrors.failedToFetch))
                    return nil
                }
                let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)
                let conversation = conversation(id: conversationId, name: name, otherUserEmail: otherUserEmail, latestMessage:latestMessageObject )
                return conversation
            })
            completion(.success(conversations))
        })
    }
    
    func getAllMessagesForChat(with id:String, completion: @escaping (Result<[Message], Error>) -> Void) {
        database.child("\(id)/messages").observe(.value, with: {[weak self] snapshot in
            
            guard let value = snapshot.value as? [[String:Any]] else{
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            let messages:[Message] = value.compactMap({ disctionary in
                guard let messageId = disctionary["id"] as? String,
                      let content = disctionary["content"] as? String,
                      let senderEmail = disctionary["sender_email"] as? String,
                      let dateString = disctionary["date"] as? String,
                      let name = disctionary["name"] as? String,
                      let date = ChatVC.dateFormatter.date(from: dateString)else{
                    completion(.failure(DatabaseErrors.failedToFetch))
                    print("error occured")
                    return nil
                }
                
                let sender = Sender(senderId: senderEmail, displayName: name, photoUrl: "")
                
                let message = Message(sender: sender,
                                      messageId: messageId,
                                      sentDate: date,
                                      kind: .text(content))
                return message
            })
            completion(.success(messages))
        })
    }
    
    public func sendMessage(to conversation:String,otherUserEmail:String,otherUserName:String, newMessage:Message,completion:@escaping(Bool)->Void ){
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "user_email") as? String else{
            return
        }
        let  currentUserSafeEmail = DatabaseManager.safeEmail(email: currentUserEmail)
        //append message in messages array
        self.database.child("\(conversation)/messages").observeSingleEvent(of: .value, with: {[weak self] snapshot in
            
            guard let strongSelf = self else{
                return
            }
            guard var messages = snapshot.value as? [[String:Any]] else{
                print("failed to fetch",conversation)
                return
            }
            
            let messageDate = newMessage.sentDate
            let dateString = ChatVC.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch newMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            guard let userEmail = UserDefaults.standard.string(forKey: "user_email") else{
                completion(false)
                return
            }
            let safeEmail = DatabaseManager.safeEmail(email: userEmail)
            
            let collectionMessage:[String:Any] = [
                "id":newMessage.messageId,
                "type":newMessage.kind.messageKindString,
                "content":message,
                "date":dateString,
                "sender_email":safeEmail,
                "is_read":false,
                "name":otherUserName
            ]
            messages.append(collectionMessage)
            strongSelf.database.child("\(conversation)/messages").setValue(messages,withCompletionBlock: { error,_ in
                guard  error == nil else{
                    completion(false)
                    return
                }
                strongSelf.database.child("\(currentUserSafeEmail)/conversations").observeSingleEvent(of: .value, with: {[weak self] snapshot in
                    
                    let updatedValue:[String:Any] = [
                        "date":dateString,
                        "message":message,
                        "is_read":false
                    ]
                    
                    guard var currentUserConversations = snapshot.value as? [[String:Any]] else{
                        return
                    }
                    
                    var targetConversation:[String:Any]?
                    var position = 0
                    
                    for singleConversation in currentUserConversations{
                        if let conversationId = singleConversation["id"] as? String, conversationId == conversation{
                            targetConversation = singleConversation
                            break
                        }
                        position+=1
                    }
                    targetConversation?["latest_message"] = updatedValue
                    guard let targetConversation = targetConversation else{
                        completion(false)
                        return
                    }
                    currentUserConversations[position] = targetConversation
                    print(currentUserConversations)
                    
                    self?.database.child("\(currentUserSafeEmail)/conversations").setValue(currentUserConversations,withCompletionBlock: {error,_ in
                        guard error == nil else{
                            completion(false)
                            return
                        }
                        //now update the reciepient data similarly
                        strongSelf.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: {[weak self] snapshot in
                            
                            let updatedValue:[String:Any] = [
                                "date":dateString,
                                "message":message,
                                "is_read":false
                            ]
                            
                            guard var currentUserConversations = snapshot.value as? [[String:Any]] else{
                                return
                            }
                            
                            var targetConversation:[String:Any]?
                            var position = 0
                            
                            for singleConversation in currentUserConversations{
                                if let conversationId = singleConversation["id"] as? String, conversationId == conversation{
                                    targetConversation = singleConversation
                                    break
                                }
                                position+=1
                            }
                            targetConversation?["latest_message"] = updatedValue
                            guard let targetConversation = targetConversation else{
                                completion(false)
                                return
                            }
                            currentUserConversations[position] = targetConversation
                            print(currentUserConversations)
                            
                            self?.database.child("\(otherUserEmail)/conversations").setValue(currentUserConversations,withCompletionBlock: {error,_ in
                                guard error == nil else{
                                    completion(false)
                                    return
                                }
                                //now update the reciepient data similarly
                                completion(true)
                            })
                        })
                        completion(true)
                    })
                })
                
                completion(true)
            })
        })
    }
}
