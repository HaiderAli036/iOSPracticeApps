import UIKit

struct UserInfo {
    let email: String!
    let firstName: String!
    let lastName: String!
}

class NewConversationVC: UIViewController {
    var users:[UserInfo] = []
    var allUsers:[UserInfo] = []
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    public var completion:((UserInfo,[[String:Any]])->(Void))?
    
    let searchBar:UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "search"
        searchBar.autocorrectionType = .no
        searchBar.autocapitalizationType = .none
        return searchBar
    }()
    
    private let tableView:UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private let noChatsLabel:UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Users found.."
        label.textAlignment = .center
        label.textColor = .gray
        label.numberOfLines  = 0
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView =  searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelChat))
        fetchUsers()
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        activityIndicator.startAnimating()
        view.addSubview(tableView)
        view.addSubview(noChatsLabel)
        view.addSubview(activityIndicator)
        view.addSubview(noChatsLabel)
        setUpTableView()
        
        DatabaseManager().fetchDataFromDatabase { result in
            switch result {
            case .success(let data):
                let userInfoArray = self.convertToUserInfoArray(data: data)
                self.users = userInfoArray
                self.allUsers = userInfoArray
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
            case .failure(let error):
                print("Error: \(error)")
            }
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        let indicatorWidth: CGFloat = 50
        let indicatorHeight: CGFloat = 50
        noChatsLabel.frame = CGRect( x: 0,
                                     y: 100,
                                     width: view.bounds.width,
                                     height: 100)
        activityIndicator.frame = CGRect( x: (view.bounds.width - indicatorWidth) / 2,
                                          y: (view.bounds.height - indicatorHeight) / 2,
                                          width: indicatorWidth,
                                          height: indicatorHeight)
    }
    
    func convertToUserInfoArray(data: [[String: Any]]) -> [UserInfo] {
        var userInfoArray: [UserInfo] = []
        let currentEmail = DatabaseManager.safeEmail(email: UserDefaults.standard.string(forKey: "user_email")!)
        
        for (info) in data {
            if let email = info["email"], let name = info["name"] {
                if(email as! String != currentEmail){
                    let userInfo = UserInfo(email:email as! String,firstName: name as! String, lastName: "" )
                    
                    userInfoArray.append(userInfo)
                }
            }
        }
        return userInfoArray
    }
    
    private func setUpTableView(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchUsers(){
        tableView.isHidden = false
    }
    
    @objc func cancelChat(){
        navigationController?.dismiss(animated: true)
    }
    
}

extension NewConversationVC:  UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].firstName+" "+users[indexPath.row].lastName
        cell.accessoryType  = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let targetUser = users[indexPath.row]
        var myConversations = [[String:Any]]()
        
        //get tpped user conversations
        DatabaseManager.shared.getMyConversations(path: "\(targetUser.email ?? "")/conversations", completion: {result  in
            switch result {
            case .success(let conversations):
                myConversations = conversations
            case .failure(let error):
                print("error occured while fetching conversations",error);
            }
        })
        
        dismiss(animated: true,completion: { [weak self] in
            self?.completion?(targetUser,myConversations)
        })
    }
}

extension NewConversationVC:UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchText = searchBar.text {
            users = filterUserInfoArray(userInfoArray:allUsers,searchPrefix:searchText )
            
            if users.count == 0 {
                noChatsLabel.isHidden = false
            }else{
                noChatsLabel.isHidden = true
            }
            
            tableView.reloadData()
        }
    }
    
    func filterUserInfoArray(userInfoArray: [UserInfo], searchPrefix: String) -> [UserInfo] {
        let filteredArray = userInfoArray.filter { userInfo in
            return userInfo.firstName.hasPrefix(searchPrefix) || userInfo.lastName.hasPrefix(searchPrefix)
        }
        return filteredArray
    }
    
}
