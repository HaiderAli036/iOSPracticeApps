import FirebaseDatabase
import Foundation

final class DatabaseManager{
    
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
    static func safeEmail(email:String) -> String{
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

//MARK: User Account Management
extension DatabaseManager{

    ///Validating new user email
    public func validateUser(wiht email:String, completion:@escaping((Bool)->Void)){
        var safeEmail = DatabaseManager.safeEmail(email: email)
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? String != nil else{
                completion(false)
                return
            }
            completion(true)
        })
    }

    ///Creating new user
    public func createUser( for user:ChatAPPUser,completion:@escaping(Bool)->Void ){
        database.child(user.safeEmail).setValue([
            "first_name":user.firstName,
            "last_name":user.lastName
        ],withCompletionBlock: { error, _ in
            guard error == nil else{
                print("failed to write to database")
                completion(false)
                return
            }
            completion(true)
            return
        });
    }
    
    func fetchDataFromDatabase(completion: @escaping (Result<[String: [String: String]], Error>) -> Void) {
        let database = Database.database().reference()

        database.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists(), let data = snapshot.value as? [String: [String: String]]{
                completion(.success(data))
            } else {
                completion(.failure(NSError(domain: "YourAppDomain", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch data"])))
            }
        }
    }
    
}
