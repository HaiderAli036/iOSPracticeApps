import UIKit
import MessageKit

struct Message:MessageType{
    var sender: MessageKit.SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKit.MessageKind
}

struct Sender:SenderType{
    var senderId: String
    var displayName: String
    var photoUrl:String
}
class ChatVC:MessagesViewController{
    private var messages = [Message]()
    
    var selfSender:Sender = Sender(senderId: "1", displayName: "Usama", photoUrl: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messages.append(Message(sender: selfSender, messageId:"1", sentDate: Date(), kind: .text("Hy how")))
        messages.append(Message(sender: selfSender, messageId:"2", sentDate: Date(), kind: .text("Hy how")))
        messages.append(Message(sender: selfSender, messageId:"3", sentDate: Date(), kind: .text("Hy how")))
        messages.append(Message(sender: selfSender, messageId:"4", sentDate: Date(), kind: .text("Hy how")))
        messages.append(Message(sender: selfSender, messageId:"5", sentDate: Date(), kind: .text("Hy how")))
        messages.append(Message(sender: selfSender, messageId:"6", sentDate: Date(), kind: .text("Hy how are you doing i was worried about you where did you go please respond")))
        view.backgroundColor = .white
            
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }

}

extension ChatVC: MessagesDataSource,MessagesLayoutDelegate,MessagesDisplayDelegate{
    func currentSender() -> MessageKit.SenderType {
        selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        messages.count
    }
    
    
}
