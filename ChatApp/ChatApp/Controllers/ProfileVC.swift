import UIKit
import Firebase

class ProfileVC: UIViewController {
    
    @IBOutlet var profileImageView:UIImageView!
    @IBOutlet var tableView:UITableView!
    let data = ["Settings","Log out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView?.delegate = self
        tableView?.dataSource = self
        setProfileImage()
    }

    private func setProfileImage(){
        profileImageView.image = UIImage(systemName: "person.circle")
        profileImageView.tintColor = .gray
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.isUserInteractionEnabled = true
        profileImageView.layer.cornerRadius = profileImageView.width/2.0
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.lightGray.cgColor
        profileImageView.clipsToBounds = true
    
        let email = UserDefaults.standard.string(forKey: "email")!
        let safeEmail = DatabaseManager.safeEmail(email: email)
        let fileName = safeEmail+"_profile_picture.png"
        let path = "images/"+fileName
        
        StorageManager.shared.downloadUrl(for:path, completion: { result in
            switch(result){
            case  .success(let downloadUrl):
                self.downloadAndSetImage(from:downloadUrl)
            case .failure(let error):
                 print(error)
            }
        })
    }
    
    func downloadAndSetImage(from imageURL: URL) {
            let session = URLSession.shared
    
            let task = session.dataTask(with: imageURL) { data, response, error in
                if let error = error {
                    print("Error downloading image: \(error)")
                    return
                }
                guard let data = data else {
                    print("No data received")
                    return
                }
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        print("got the image")
                        self.profileImageView.image = image
                    }
                }
            }
            task.resume()
    }
}

extension ProfileVC:  UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .left
        cell.imageView?.image = UIImage(systemName: "square.and.pencil")
        if indexPath.row == data.count-1 {
            cell.textLabel?.textColor = .red
            cell.imageView?.image = UIImage(systemName: "arrowshape.left")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == data.count-1 {
            self.showLogoutAlert()
        }
    }
    
    func showLogoutAlert() {
            let alertController = UIAlertController(
                title: "Loging out",
                message: "Are you sure you want to logout?",
                preferredStyle: .actionSheet
            )
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in}
            
            let logoutAction = UIAlertAction(title: "Logout", style: .destructive) {[weak self] _ in
                guard let stronSelf = self else{
                    return
                }
                stronSelf.Logout()
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(logoutAction)
            
            present(alertController, animated: true, completion: nil)
        }
    
    public func Logout(){
        do{
            try Auth.auth().signOut()
            let vc = LoginVC()
            let navigation = UINavigationController(rootViewController: vc )
            navigation.modalPresentationStyle = .fullScreen
            let tabController = self.tabBarController

            self.present(navigation, animated: true,completion:{
                tabController?.selectedIndex = 0
            })

        }catch{
            print("Error while logging out")
        }
    }
    
}
