import UIKit


class ViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
   
    var veiwModel:[Article] = [Article]()

//    print(data)
    let cellIdentifier = "cell"
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "News"
        view.backgroundColor = .systemBackground
        
        tableView.delegate  = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)

        APIManager.shared.fetchData { result in
            switch result {
            case .success(let articles):
                self.veiwModel = articles
                print("API Response: Got")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                case .failure(let error):
                    print("API Error: \(error)")
            }
        }
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return veiwModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
//        as! CustomTableViewCell
                
//        let item = veiwModel[indexPath.row]
//        
//        cell.titleLabel.text = item.title
//        cell.descriptionLabel.text = item.description
              cell.textLabel?.text = veiwModel[indexPath.row].title
        return cell
    }
}

class CustomTableViewCell: UITableViewCell {
//    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var descriptionLabel: UILabel!
//    @IBOutlet weak var customImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
}
