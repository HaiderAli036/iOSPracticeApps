//
//  TaskEntryViewController.swift
//  ToDoList
//
//  Created by PakWheels Test on 15/08/2023.
//

import UIKit

class TaskEntryViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var taskEntry: UITextField!
    var update: (()-> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskEntry.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveTask))
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveTask()
        return true
    }
    
    @objc func saveTask(){
        // save task
        guard let text = taskEntry.text, !text.isEmpty else{
            return
        }
        var currentTasks = UserDefaults.standard.stringArray(forKey: "taskItems") ?? []
        currentTasks.append(text)
        UserDefaults.standard.setValue(currentTasks, forKey: "taskItems")
        update?()
        navigationController?.popViewController(animated: true)
    }
}
