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
}

//MARK: User Account Management
extension DatabaseManager{

    ///Validating new user email
    public func validateUser(wiht email:String, completion:@escaping((Bool)->Void)){
        var safeEmail = DatabaseManager.safeEmail(email: email)
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? String != nil else{
                completion(false)
                return
            }
            completion(true)
        })
    }

    ///Creating new user
    public func createUser( for user:ChatAPPUser,completion:@escaping(Bool)->Void ){
        database.child(user.safeEmail).setValue([
            "first_name":user.firstName,
            "last_name":user.lastName
        ],withCompletionBlock: { error, _ in
            guard error == nil else{
                print("failed to write to database")
                completion(false)
                return
            }
            completion(true)
            return
        });
    }
    
    func fetchDataFromDatabase(completion: @escaping (Result<[String: [String: String]], Error>) -> Void) {
        let database = Database.database().reference()

        database.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists(), let data = snapshot.value as? [String: [String: String]]{
                completion(.success(data))
            } else {
                completion(.failure(NSError(domain: "YourAppDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch data"])))
            }
        }
    }
    
}

//MARK: Chat Management
extension DatabaseManager{

    public func createNewChat(with otherUserEmail:String,firstMessage:Message,completion:@escaping(Bool)->Void ){
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "user_email") as? String else{
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
            
            let newConversationData:[String:Any] = [
                "id": "conversation_\(firstMessage.messageId)",
                "other_user_email":otherUserEmail,
                "latest_message":[
                    "date": dateString,
                    "is_read":false,
                    "message":message
                ]
            ]
            
            if var conversations = userNode["conversations"] as? [[String:Any]]{
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode, withCompletionBlock: { error, _ in
                    guard error==nil else{
                        completion(false)
                        return
                    }
                    completion(true)
                })
            }else{
                userNode["conversations"] = [
                    newConversationData
                ]
                ref.setValue(userNode, withCompletionBlock: { error, _ in
                    guard error==nil else{
                        completion(false)
                        return
                    }
                    completion(true)
                })
            }
            completion(true)
        })
    }
    
    func getAllChatsFromDatabase(for email:String, completion: @escaping (Result<[String: [String: String]], Error>) -> Void) {
        
    }
    
    func getAllMessagesForChat(with id:String, completion: @escaping (Result<[String: [String: String]], Error>) -> Void) {
       
    }
    
    public func sendMessage(to conversation:String,message:Message,completion:@escaping(Bool)->Void ){
        
    }
}
