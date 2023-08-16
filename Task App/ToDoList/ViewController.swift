import UIKit

class ViewController: UIViewController {
   
    @IBOutlet weak var tableView: UITableView!
    var tasks:[String] = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title  = "Todo List"
        self.loadTasks()
        
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func loadTasks(){
        self.tasks  = UserDefaults.standard.stringArray(forKey: "taskItems") ?? []
        tableView.reloadData()
    }

    @IBAction func addTask(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "entry") as! TaskEntryViewController
        vc.update = {
            DispatchQueue.main.async {
                self.loadTasks()
            }
        }
        vc.title = "Add Task"
        navigationController?.pushViewController(vc, animated: true)
    }
}


//Extensions added in view controller
extension ViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = storyboard?.instantiateViewController(withIdentifier: "task") as! TaskViewController
        vc.update = {
            DispatchQueue.main.async {
                self.loadTasks()
            }
        }
        vc.title = "Task \(indexPath.row+1)"
        vc.taskIndex = indexPath.row
        vc.task  = tasks[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = tasks[indexPath.row]
        return cell
    }
}
