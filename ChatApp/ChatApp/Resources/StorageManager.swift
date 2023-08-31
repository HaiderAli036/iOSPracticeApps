import FirebaseDatabase
import FirebaseStorage
import Foundation

final class StorageManager{
    
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
}

//MARK: User Storage Management
extension StorageManager{
    public typealias UploadPictureCompletion = (Result<String,Error>) -> Void
    
    ///Upload picture to firebase
    public func uploadProfilePicture(wih data:Data, fileName:String, completion:@escaping UploadPictureCompletion){
        let imageRef = storage.child("images/\(fileName)")
        
        imageRef.putData(data, metadata: nil, completion: {metadata,error in
            guard error == nil else {
                completion(.failure(StorageErrors.failedToUpload))
                print("error while uploading profile picutre")
                return
            }
            
            imageRef.downloadURL { url, error in
                if let downloadURL = url {
                    completion(.success(downloadURL.absoluteString))
                }else{
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                }
            }
        })
    }
    
    public func downloadUrl( for path:String,completion: @escaping (Result<URL,Error>)->Void){
        let reference = storage.child(path)
        
        reference.downloadURL(completion: {url,error in
            guard let url = url, error == nil else{
                print(error)
                completion(.failure(StorageErrors.failedToGetDownloadURL))
                return
            }
            completion(.success(url))
        })
    }
    
    public enum StorageErrors:Error{
        case failedToUpload
        case failedToGetDownloadURL
    }
    
}
