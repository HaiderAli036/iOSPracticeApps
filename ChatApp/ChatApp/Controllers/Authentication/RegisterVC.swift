import UIKit
import Firebase

class RegisterVC: UIViewController {
    
    let imagePicker = UIImagePickerController()
    var profileImage = UIImage()
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private let ChatLogo:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let scrollView:UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        scrollView.isUserInteractionEnabled = true
        return scrollView
    }()
    
    private let FirstNameInput:UITextField = {
        let field = UITextField()
        field.placeholder = "First Name"
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
   
    private let LastNameInput:UITextField = {
        let field = UITextField()
        field.placeholder = "Second Name"
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
    
    private let RegisterButton:UIButton = {
        let button = UIButton()
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Create Account", for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Account"
        view.backgroundColor = .white
        FirstNameInput.becomeFirstResponder()
        RegisterButton.addTarget(self, action: #selector(RegisterHandeler), for: .touchUpInside)
        EmailInput.delegate = self
        PasswordInput.delegate = self
        //Login Subviews
        view.addSubview(scrollView)
        scrollView.addSubview(ChatLogo)
        scrollView.addSubview(FirstNameInput)
        scrollView.addSubview(LastNameInput)
        scrollView.addSubview(EmailInput)
        scrollView.addSubview(PasswordInput)
        scrollView.addSubview(RegisterButton)
        scrollView.addSubview(activityIndicator)
        activityIndicator.color = .gray
        let imageGesture = UITapGestureRecognizer(target: self, action: #selector(ImageSelectHandler))
        ChatLogo.addGestureRecognizer(imageGesture)
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
        FirstNameInput.frame = CGRect(x:30 ,
                                  y: ChatLogo.bottom+20,
                                  width: scrollView.width-60,
                                  height: 52)
        LastNameInput.frame = CGRect(x:30 ,
                                  y: FirstNameInput.bottom+20,
                                  width: scrollView.width-60,
                                  height: 52)
        EmailInput.frame = CGRect(x:30 ,
                                  y: LastNameInput.bottom+20,
                                  width: scrollView.width-60,
                                  height: 52)
        PasswordInput.frame = CGRect(x:30,
                                  y: EmailInput.bottom+20,
                                  width: scrollView.width-60,
                                  height: 52)
        RegisterButton.frame = CGRect(x:30,
                                  y: PasswordInput.bottom+20,
                                  width: scrollView.width-60,
                                  height: 52)
    }
    
    
    @objc func LoginHandler(){
        navigationController?.pushViewController(LoginVC(), animated: true)
    }
    
    @objc func RegisterHandeler(){
        activityIndicator.startAnimating()
        FirstNameInput.resignFirstResponder()
        LastNameInput.resignFirstResponder()
        EmailInput.resignFirstResponder()
        PasswordInput.resignFirstResponder()
        
        guard let firstName = FirstNameInput.text, !firstName.isEmpty,
              let lastName = LastNameInput.text, !lastName.isEmpty,
              let email = EmailInput.text, !email.isEmpty,
              let pass = PasswordInput.text, !pass.isEmpty, pass.count>=6 else{
            activityIndicator.stopAnimating()
            showToast(message:"Please fill all the data" )
            return
        }
        DatabaseManager.shared.validateUser(wiht: email, completion: {exists in
            guard !exists else{
                self.showToast(message:"Email already exists" )
                self.activityIndicator.stopAnimating()
                return
            }

            Auth.auth().createUser(withEmail: email, password: pass,completion: {[weak self] result, error in

                guard let strongSelf = self else { return }

                if let error = error {
                    strongSelf.activityIndicator.stopAnimating()
                    print("Sign-Up error: \(error.localizedDescription)")
                    strongSelf.showToast(message:"Error Occured While creating account")
                } else {
                    strongSelf.activityIndicator.stopAnimating()
                    print("Account Created successful")

                    let user = ChatAPPUser(firstName: firstName, lastName: lastName, email: email)
                    DatabaseManager.shared.createUser(for: user,completion: {success in
                        if success {
                            guard let image = strongSelf.ChatLogo.image,
                                  let data = strongSelf.compressImage(image) else{
                                return
                            }
                    
                            let fileName = user.profilePictureFileName
                            print(fileName)
                            StorageManager.shared.uploadProfilePicture(wih:data, fileName: fileName, completion: { result in
                                switch(result){
                                case  .success(let downloadUrl):
                                    print(downloadUrl)
                                    UserDefaults.standard.setValue(downloadUrl, forKey: "profile_picuture_url")
                                    UserDefaults.standard.setValue(email, forKey: "email")
                                    UserDefaults.standard.setValue(firstName+" "+lastName, forKey: "user_name")
                                case .failure(let error):
                                     print(error)
                                }
                                
                            } )
                        }
                    })
                    
                    strongSelf.showToast(error:false, message:"Account Created successfully Logging in")

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        strongSelf.navigationController?.dismiss(animated: true)
                    }
                }
            })
        })
    
    }
    
    func compressImage(_ image: UIImage) -> Data? {
        guard let imageData = image.pngData() else {return nil}
        let compressionQuality: CGFloat = 0.5
        
        if let compressedImage = UIImage(data: imageData) {
            if let compressedImageData = compressedImage.jpegData(compressionQuality: compressionQuality) {
                return compressedImageData
            }
        }
        return nil
    }
    
    func showToast(error:Bool = true,message: String) {
        let toastView = CustomToast(error:error,message: message)
        toastView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toastView)
        toastView.show(in: view)
    }
}

extension RegisterVC:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == EmailInput {
            PasswordInput.becomeFirstResponder()
        }
        else if textField == PasswordInput {
            RegisterHandeler()
        }
        return true
    }
}

extension RegisterVC:UINavigationControllerDelegate,UIImagePickerControllerDelegate{
   
    @objc func ImageSelectHandler() {
        let alertController = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)

        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.openCamera()
        }
        alertController.addAction(cameraAction)

        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.openPhotoLibrary()
        }
        alertController.addAction(photoLibraryAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        } else {
            print("Camera is not available.")
        }
    }

    func openPhotoLibrary() {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            profileImage = selectedImage
            self.ChatLogo.image = profileImage
            ChatLogo.layer.cornerRadius = ChatLogo.width/2.0
            ChatLogo.layer.borderWidth = 2
            ChatLogo.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}
