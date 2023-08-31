import UIKit
import Firebase
import SDWebImage

struct conversation{
    let id:String
    let name:String
    let otherUserEmail:String
    let latestMessage:LatestMessage
    var profilePictureUrl:URL!
}

struct LatestMessage{
    let date:String
    let text:String
    let isRead:Bool
}

class ConversationsVC: UIViewController {
    
    public var conversations:[conversation] = [conversation]()
    
    private let tableView:UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        let nib = UINib(nibName: "ConversationTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: ConversationTableViewCell.identifier)
        
        return tableView
    }()
    
    private let noChatsLabel:UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Conversations"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let rightButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(composeNewChat))
        navigationItem.rightBarButtonItem = rightButton
        startListeningForConversation()
        fetchChats()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
        view.addSubview(tableView)
        view.addSubview(noChatsLabel)
        setUpTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func startListeningForConversation(){
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "user_email") as? String else{
            return
        }
        let currentUserSafeEmail = DatabaseManager.safeEmail(email: currentUserEmail)
        
        DatabaseManager.shared.getAllChatsFromDatabase(for: currentUserSafeEmail, completion: {[weak self] result in
            switch(result){
            case .success(let conversations):
                guard !conversations.isEmpty else{
                    return
                }
                self?.tableView.isHidden = false
                self?.conversations = conversations
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(_):
                print("failed to get conversations")
            }
        })
    }
    
    @objc private func composeNewChat(){
        let vc = NewConversationVC()
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "user_email") as? String else{
            return
        }
        let currentUserSafeEmail = DatabaseManager.safeEmail(email: currentUserEmail)
        
        vc.completion = {[weak self] result,myConversations in
            var isFound = false
            var position = 0
            
            for singleConversation in myConversations{
                if let other_user_email = singleConversation["other_user_email"] as? String,other_user_email == currentUserSafeEmail {
                    guard singleConversation["id"] is String else{
                        return
                    }
                    isFound = true
                    break
                }
                position+=1
            }
            
            if isFound {
                let model = myConversations[position]
                
                guard let otherUserEmail = model["other_user_email"] as? String,
                      let name = model["name"] as? String,
                      let id = model["id"] as? String else{
                    self?.startNewChat(result: result)
                    return
                }
                
                let vc = ChatVC(with: otherUserEmail,name: name,id: id)
                vc.title = result.firstName+" "+result.lastName
                vc.navigationItem.largeTitleDisplayMode = .never
                self?.navigationController?.pushViewController(vc, animated: true)
            }else{
                self?.startNewChat(result: result)
            }
            
        }
        let navVc = UINavigationController(rootViewController:vc)
        present(navVc, animated: true)
    }
    
    private func startNewChat(result:UserInfo){
        let vc = ChatVC(with: result.email,name: result.firstName+" "+result.lastName,id: nil)
        vc.isNewConversation = true
        vc.title = result.firstName
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setUpTableView(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func validateAuth(){
        if Auth.auth().currentUser == nil {
            let vc = LoginVC()
            let navigation = UINavigationController(rootViewController: vc )
            navigation.modalPresentationStyle = .fullScreen
            present(navigation, animated: false)
        }
    }
    
    private func fetchChats(){
        tableView.isHidden = false
    }
    
}

extension ConversationsVC:  UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as! ConversationTableViewCell
        
        cell.title.text = model.name
        cell.message.text = model.latestMessage.text
        
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        
        StorageManager.shared.downloadUrl(for: path, completion: {[weak self]result in
            switch result{
            case .success(let url):
                
                self?.conversations[indexPath.row].profilePictureUrl = url
                DispatchQueue.main.async {
                    cell.profileImage.sd_setImage(with: self?.conversations[indexPath.row].profilePictureUrl,completed: nil)
                }
            case .failure(_):
                print("Error while downloading image url")
            }
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        let vc = ChatVC(with: model.otherUserEmail,name: model.name,id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}
