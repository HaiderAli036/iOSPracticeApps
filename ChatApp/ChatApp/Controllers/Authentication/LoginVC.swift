import UIKit
import Firebase

class LoginVC: UIViewController {
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private let ChatLogo:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "chat_logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let scrollView:UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let EmailInput:UITextField = {
        let field = UITextField()
        field.placeholder = "Email"
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.layer.cornerRadius = 12
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: field.frame.height))
        field.leftView = paddingView
        field.leftViewMode = .always
        
        return field
    }()
    
    private let PasswordInput:UITextField = {
        let field = UITextField()
        field.placeholder = "Password"
        field.layer.borderWidth = 1
        field.isSecureTextEntry = true
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.isSecureTextEntry = true
        field.layer.cornerRadius = 12
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: field.frame.height))
        field.leftView = paddingView
        field.leftViewMode = .always
        
        return field
    }()
    
    private let LoginButton:UIButton = {
        let button = UIButton()
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Login", for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(RegisterHandler))
        
        EmailInput.becomeFirstResponder()
        LoginButton.addTarget(self, action: #selector(LoginHandeler), for: .touchUpInside)
        EmailInput.delegate = self
        PasswordInput.delegate = self
        //Login Subviews
        view.addSubview(scrollView)
        scrollView.addSubview(ChatLogo)
        scrollView.addSubview(EmailInput)
        scrollView.addSubview(PasswordInput)
        scrollView.addSubview(LoginButton)
        scrollView.addSubview(activityIndicator)
        activityIndicator.color = .gray
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let size = view.width/3
        let indicatorWidth: CGFloat = 50
        let indicatorHeight: CGFloat = 50
        scrollView.frame = view.bounds
        activityIndicator.frame = CGRect( x: (scrollView.bounds.width - indicatorWidth) / 2,
                                          y: (scrollView.bounds.height - indicatorHeight) / 2,
                                          width: indicatorWidth,
                                          height: indicatorHeight)
        ChatLogo.frame = CGRect(x:(scrollView.width-size)/2 ,
                                y: 10,
                                width: size,
                                height: size)
        EmailInput.frame = CGRect(x:30,
                                  y: ChatLogo.bottom+20,
                                  width: scrollView.width-60,
                                  height: 52)
        PasswordInput.frame = CGRect(x:30,
                                     y: EmailInput.bottom+20,
                                     width: scrollView.width-60,
                                     height: 52)
        LoginButton.frame = CGRect(x:30,
                                   y: PasswordInput.bottom+20,
                                   width: scrollView.width-60,
                                   height: 52)
    }
    
    @objc func RegisterHandler(){
        navigationController?.pushViewController(RegisterVC(), animated: true)
    }
    
    @objc func LoginHandeler(){
        activityIndicator.startAnimating()
        LoginButton.isEnabled = false
        
        EmailInput.resignFirstResponder()
        PasswordInput.resignFirstResponder()
        
        guard let email = EmailInput.text, !email.isEmpty,
              let pass = PasswordInput.text, !pass.isEmpty, pass.count>=6 else{
            showToast(message:"Missing field data" )
            LoginButton.isEnabled = true
            activityIndicator.stopAnimating()
            return
        }
        Auth.auth().signIn(withEmail: email, password: pass) { [weak self] authResult, error in
            
            guard let strongSelf = self else { return }
            
            if let error = error {
                // Handle sign-in error
                print("Sign-in error: \(error.localizedDescription)")
                strongSelf.showToast(message: "Error occurred on Sign")
                strongSelf.activityIndicator.stopAnimating()
                strongSelf.LoginButton.isEnabled = true
            } else {
                print("Sign-in successful")
                strongSelf.showToast(error: false, message: "Signed in successfully")
                strongSelf.activityIndicator.stopAnimating()
                strongSelf.LoginButton.isEnabled = true
                let safeEmail = DatabaseManager.safeEmail(email: email)
                DatabaseManager.shared.getDataFor(path:safeEmail , completion: {result in
                    switch result{
                    case .success(let data):
                        guard let userData = data as? [String:Any],
                              let firstName = userData["first_name"],
                              let lastName = userData["last_name"] else{
                            return
                            
                        }
                        UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "user_name")
                    case .failure(let error) :
                        print(error)
                        break
                    }
                })
                UserDefaults.standard.setValue(email, forKey: "user_email")
              
                // Post the notification
                let myNotificationName = Notification.Name("MyNotificationName")
                NotificationCenter.default.post(name:myNotificationName, object: nil, userInfo: ["key": "value"])
                
                strongSelf.navigationController?.dismiss(animated: true)
            }
        }
        
    }
    
    
    func showToast(error:Bool = true,message: String) {
        let toastView = CustomToast(error:error,message: message)
        toastView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toastView)
        toastView.show(in: view)
    }
}

extension LoginVC:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == EmailInput {
            PasswordInput.becomeFirstResponder()
        }
        else if textField == PasswordInput {
            LoginHandeler()
        }
        return true
    }
}
