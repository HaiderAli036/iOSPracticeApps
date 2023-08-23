import UIKit
import Firebase

class ViewController: UIViewController {
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
   
    private let Pagetitle:UILabel = {
        let title = UILabel()
        title.textAlignment = .center
        title.font = .systemFont(ofSize: 24,weight: .bold)
        title.text = "Sign In"
        title.font = title.font.withSize(40)
        title.adjustsFontSizeToFitWidth = true
        title.textColor = .white
        title.numberOfLines = 0
        return title
    }()
    
    private let EmailInput:UITextField = {
        let EmailInput = UITextField()
        EmailInput.placeholder = "Email"
        EmailInput.layer.borderWidth = 3
        EmailInput.layer.borderColor = UIColor.systemGreen.cgColor
        EmailInput.backgroundColor = .white
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: EmailInput.frame.height))
        EmailInput.leftView = paddingView
        EmailInput.leftViewMode = .always
        
        return EmailInput
    }()
    
    private let PasswordInput:UITextField = {
        let PasswordInput = UITextField()
        PasswordInput.placeholder = "Password"
        PasswordInput.layer.borderWidth = 3
        PasswordInput.isSecureTextEntry = true
        PasswordInput.layer.borderColor = UIColor.systemGreen.cgColor
        PasswordInput.backgroundColor = .white
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: PasswordInput.frame.height))
        PasswordInput.leftView = paddingView
        PasswordInput.leftViewMode = .always
        
        return PasswordInput
    }()
    
    private let button:UIButton = {
        let Button = UIButton()
        Button.backgroundColor = .systemGreen
        Button.setTitleColor(.white, for: .normal)
        Button.setTitle("Continue", for: .normal)
        return Button
    }()
   
    private let LogoutButton:UIButton = {
        let Button = UIButton()
        Button.backgroundColor = .systemGreen
        Button.setTitleColor(.white, for: .normal)
        Button.setTitle("Logout", for: .normal)
        return Button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        view.addSubview(Pagetitle)
        view.addSubview(EmailInput)
        view.addSubview(PasswordInput)
        view.addSubview(button)
        view.addSubview(activityIndicator)

        activityIndicator.color = .gray
        
        button.addTarget(self, action: #selector(buttonHandeler), for: .touchUpInside)
        LogoutButton.addTarget(self, action: #selector(LogoutButtonHandler), for: .touchUpInside)
        
        if (Auth.auth().currentUser != nil) {
            Pagetitle.text = "Welcome Home"
            EmailInput.isHidden = true
            PasswordInput.isHidden = true
            button.isHidden = true
            view.addSubview(LogoutButton)
            addLogoutButtonContraints()
        }
        
        Pagetitle.translatesAutoresizingMaskIntoConstraints = false
        EmailInput.translatesAutoresizingMaskIntoConstraints = false
        PasswordInput.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        LogoutButton.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            Pagetitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            Pagetitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            Pagetitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            Pagetitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            EmailInput.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            EmailInput.topAnchor.constraint(equalTo: Pagetitle.bottomAnchor, constant: 20),
            EmailInput.widthAnchor.constraint(equalToConstant: view.frame.size.width-30),
            EmailInput.heightAnchor.constraint(equalToConstant:50),
            
            PasswordInput.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            PasswordInput.topAnchor.constraint(equalTo: EmailInput.bottomAnchor, constant: 20),
            PasswordInput.widthAnchor.constraint(equalToConstant: view.frame.size.width-30),
            PasswordInput.heightAnchor.constraint(equalToConstant:50),
            
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: PasswordInput.bottomAnchor, constant: 20),
            button.widthAnchor.constraint(equalToConstant: view.frame.size.width-20),
            button.heightAnchor.constraint(equalToConstant:50),
          
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        EmailInput.becomeFirstResponder()
    }
    @objc func buttonHandeler(){
        activityIndicator.startAnimating()
        guard let email = EmailInput.text, !email.isEmpty,
              let pass = PasswordInput.text, !pass.isEmpty else{
            showErrorToast(message:"Missing field data" )
            activityIndicator.stopAnimating()
            return
        }
        Auth.auth().signIn(withEmail: email, password: pass) { [weak self] authResult, error in
            
            guard let strongSelf = self else { return }
            
            strongSelf.activityIndicator.stopAnimating()
            
            if let error = error {
                print("Sign-in error: \(error)")
                strongSelf.showCreateAccound(email: email, password:pass)
            } else {
                print("Sign-in successful")
                strongSelf.Pagetitle.text = "Welcome HOME"
                strongSelf.EmailInput.isHidden = true
                strongSelf.PasswordInput.isHidden = true
                strongSelf.button.isHidden = true
                strongSelf.view.addSubview(strongSelf.LogoutButton)
                strongSelf.addLogoutButtonContraints()
            }
        }
        
    }
    
    @objc func LogoutButtonHandler(){
        do{
            try Auth.auth().signOut()
            Pagetitle.text = "Sign In"
            EmailInput.isHidden = false
            PasswordInput.isHidden = false
            button.isHidden = false
            LogoutButton.removeFromSuperview()
            
        }catch{
            print("error occured")
            showErrorToast(message:"Something went wrong!")
        }
        
    }
    
    func showErrorToast(message: String) {
        let toastView = CustomToast(message: message)
        toastView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toastView)
        toastView.show(in: view)
    }
    func addLogoutButtonContraints(){
        NSLayoutConstraint.activate([
        LogoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        LogoutButton.topAnchor.constraint(equalTo: Pagetitle.bottomAnchor, constant: 50),
        LogoutButton.widthAnchor.constraint(equalToConstant: view.frame.size.width-20),
        LogoutButton.heightAnchor.constraint(equalToConstant:50),
        ])
    }
    func showCreateAccound(email:String,password:String){
        let alert = UIAlertController(title: "Create Account",
                                      message: "Would you like to create account",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue",
                                      style: .default,
                                      handler:{_ in
            self.activityIndicator.startAnimating()
            Auth.auth().createUser(withEmail: email, password: password,completion: {[weak self] result, error in
                guard let strongSelf = self else { return }
                self?.activityIndicator.stopAnimating()
                if let error = error {
                    print("Sign-Up error: \(error.localizedDescription)")
                    strongSelf.showErrorToast(message:"Something went wrong!")
                } else {
                    print("Account Created successful")
                    strongSelf.Pagetitle.text = "Welcome HOME"
                    strongSelf.EmailInput.isHidden = true
                    strongSelf.PasswordInput.isHidden = true
                    strongSelf.button.isHidden = true
                    strongSelf.view.addSubview(strongSelf.LogoutButton)
                    strongSelf.addLogoutButtonContraints()
                }
            })
        }
                                     ))
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel,
                                      handler:{_ in}
                                     ))
        present(alert, animated: true)
    }
}

