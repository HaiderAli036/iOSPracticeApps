import UIKit
import MessageKit
import InputBarAccessoryView

struct Message:MessageType{
    public var sender: MessageKit.SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKit.MessageKind
}

extension MessageKind{
    var messageKindString:String{
        switch self{
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedText"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}

struct Sender:SenderType{
    public var senderId: String
    public var displayName: String
    public var photoUrl:String
}

class ChatVC:MessagesViewController{
    private var messages = [Message]()
    public var isNewConversation = false
    public let otherUserEmail:String
    public let otherUserName:String
    public let conversationId:String?
    
    public static var dateFormatter:DateFormatter = {
        var format = DateFormatter()
        format.dateStyle = .medium
        format.timeStyle = .long
        format.locale = .current
        return format
    }()
    
    init(with email:String,name:String,id:String?){
        self.otherUserEmail = email
        self.otherUserName = name
        self.conversationId = id
        super.init(nibName: nil, bundle: nil)
        if let conversationId = conversationId {
            startListeningForMessages(id: conversationId,scrollTobottom:true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var selfSender:Sender? {
        guard let email = UserDefaults.standard.value(forKey: "user_email") else{
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(email: email as! String)
        return Sender(senderId:safeEmail as! String , displayName: "Me", photoUrl: "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
    private func startListeningForMessages(id:String,scrollTobottom:Bool){
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "user_email") as? String else{
            return
        }
        let currentUserSafeEmail = DatabaseManager.safeEmail(email: currentUserEmail)
        
        DatabaseManager.shared.getAllMessagesForChat(with:id,completion: {[weak self] result in
            switch(result){
            case .success(let messages):
                guard !messages.isEmpty else{
                    return
                }
                self?.messages = messages
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if scrollTobottom{
                        self?.messagesCollectionView.scrollToBottom(animated: true)
                    }
                }
                print("got messages",self?.messages)
            case .failure(_):
                print("failed to get conversations")
            }
        })
    }
}

extension ChatVC:InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        guard !text.replacingOccurrences(of: "", with: " ").isEmpty,
              let selfSender = self.selfSender else{
            return
        }
        let message = Message(sender: selfSender, messageId: createMessageId(), sentDate: Date(), kind: .text(text))
        
        if(isNewConversation){
            DatabaseManager.shared.createNewChat(with: otherUserEmail,otherUserName:otherUserName, firstMessage: message, completion: {[weak self]result in
                if(result){
                    inputBar.inputTextView.text = ""
                    print("new conversation created")
                    self?.isNewConversation=false
                }else{
                    print("conversation Creation error")
                }
            })
        }else{
            //Append to converstaion in db
            guard let conversationId = self.conversationId else{
                return
            }
            
            DatabaseManager.shared.sendMessage(to: conversationId,otherUserEmail: otherUserEmail,otherUserName:otherUserName, newMessage: message, completion: {success in
                if success{
                    inputBar.inputTextView.text = ""
                    print("message sent")
                }else{
                    print("message sent failed")
                }
            })
        }
    }
    
    private func createMessageId()->String{
        guard let userEmail = UserDefaults.standard.value(forKey: "user_email") else{
            return ""
        }
        let currentUserEmail = DatabaseManager.safeEmail(email: userEmail as! String)
        let dateString = Self.dateFormatter.string(from :Date())
        let uniqueId = "\(otherUserEmail)_\(currentUserEmail)_\(Date())_\(dateString)"
        print(uniqueId)
        return uniqueId
    }
}

extension ChatVC: MessagesDataSource,MessagesLayoutDelegate,MessagesDisplayDelegate{
    func currentSender() -> MessageKit.SenderType {
        if let sender =  selfSender{
            return sender
        }
        fatalError("Self sender is nill email should be cached")
        return Sender(senderId: "", displayName: "", photoUrl: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        messages.count
    }
    
    
}
