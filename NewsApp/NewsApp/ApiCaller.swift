import Foundation

class APIManager {
    static let shared = APIManager() // Singleton instance
    
    private init() {} // Private initializer to prevent external instantiation
    
    func fetchData(completion: @escaping (Result<[Article], Error>) -> Void) {
        // Create a URL
        if let url = URL(string: "https://newsapi.org/v2/everything?q=tesla&from=2023-07-15&sortBy=publishedAt&apiKey=2298f232a66744cfb64b5d61a474366c") {
            // Create a URLSession instance
            let session = URLSession.shared
            
            // Create a data task
            let task = session.dataTask(with: url) { data, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                else if let data = data {
                    do {
                        let json = try JSONDecoder().decode(Articles.self,from: data)
                        completion(.success(json.articles))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
            
            // Start the data task
            task.resume()
        }
    }
}
