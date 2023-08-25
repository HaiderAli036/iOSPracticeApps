import UIKit
import Firebase

class ConversationsVC: UIViewController {
    private let tableView:UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
        let rightButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(startNewChat))
        navigationItem.rightBarButtonItem = rightButton

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
    
    @objc private func startNewChat(){
        let vc = UINavigationController(rootViewController:NewConversationVC())
        present(vc, animated: true)
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Usama"
        cell.accessoryType  = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = ChatVC()
        vc.title = "Usama"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
