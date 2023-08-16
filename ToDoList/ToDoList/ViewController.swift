//
//  ViewController.swift
//  ToDoList
//
//  Created by PakWheels Test on 15/08/2023.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {
   
    @IBOutlet weak var tableView: UITableView!
    
    private let table:UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    var todoItems:[String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title  = "Todo List"
        self.todoItems  = UserDefaults.standard.stringArray(forKey: "todoItems") ?? []
        view.addSubview(table)
        table.dataSource = self
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        table.frame = view.bounds
    }

    @objc func addButtonTapped() {
        let alertController = UIAlertController(title: "Add Todo", message: "Enter the details Todo item", preferredStyle: .alert)
        
            alertController.addTextField(configurationHandler: { textField in
                textField.placeholder = "Item Name"
                
                NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { _ in
                               let addAction = alertController.actions.first
                               addAction?.isEnabled = textField.text?.isEmpty == false
                    }
            })
        
            present(alertController, animated: true, completion: nil)
            let addAction = UIAlertAction(title: "Add", style: .default) { [weak self]_ in
               if let itemName = alertController.textFields?.first?.text {
                   DispatchQueue.main.async {
                       self?.todoItems.append(itemName)
                       self?.table.reloadData()
                       UserDefaults.standard.set(self?.todoItems, forKey:"todoItems")
                   }
               }
            }
           
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
           
            alertController.addAction(addAction)
            alertController.addAction(cancelAction)
       }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  todoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = todoItems[indexPath.row]
        return cell
    }

}

