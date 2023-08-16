//
//  TaskViewController.swift
//  ToDoList
//
//  Created by PakWheels Test on 15/08/2023.
//

import UIKit

class TaskViewController: UIViewController {

    var task = String()
    var taskIndex = Int()
    @IBOutlet weak var taskTitle: UILabel!
    var update: (()-> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskTitle.text = task
        title = "Task \(taskIndex+1)"
    }
    
    @IBAction func deleteTask(_ sender: Any) {
        var allTasks  = UserDefaults.standard.stringArray(forKey: "taskItems") ?? []
        allTasks.remove(at: taskIndex)
        
        UserDefaults.standard.set(allTasks, forKey: "taskItems")
        update?()
        navigationController?.popViewController(animated: true)
    }
}
