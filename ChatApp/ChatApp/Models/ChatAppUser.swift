
struct ChatAPPUser  {
    let firstName:String
    let lastName:String
    let email:String
    
    var safeEmail:String{
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var profilePictureFileName:String{
        return "\(safeEmail)_profile_picture.png"
    }
}
