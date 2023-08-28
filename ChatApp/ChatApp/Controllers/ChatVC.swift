import UIKit
import MessageKit
import InputBarAccessoryView

struct Message:MessageType{
    public var sender: MessageKit.SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKit.MessageKind
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
    
    public static var dateFormatter:DateFormatter = {
        var format = DateFormatter()
        format.dateStyle = .medium
        format.timeStyle = .long
        format.locale = .current
        return format
    }()
    
    init(with email:String){
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var selfSender:Sender? {
        guard let email = UserDefaults.standard.value(forKey: "user_email") else{
            return nil
        }
       return Sender(senderId:email as! String , displayName: "usama", photoUrl: "")
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
}

extension ChatVC:InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: "", with: " ").isEmpty,
        let selfSender = self.selfSender else{
            return
        }
        //send message
        if(isNewConversation){
            var message = Message(sender: selfSender, messageId: createMessageId(), sentDate: Date(), kind: .text(text))
            //create a new converstaion in db
            DatabaseManager.shared.createNewChat(with: otherUserEmail, firstMessage: message, completion: {result in
                if(result){
                    print("new conversation created")
                }else{
                    print("conversation Creation error")
                }
            })
            isNewConversation=false
        }else{
            var message = Message(sender: selfSender, messageId: createMessageId(), sentDate: Date(), kind: .text(text))
            //Append to converstaion in db
            DatabaseManager.shared.sendMessage(to: otherUserEmail, message: message, completion: {result in
                
            })
             
        }
        
            
    }
    
    private func createMessageId()->String{
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "user_email") else{
            return ""
        }
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
