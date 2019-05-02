//
//  DetailsVC.swift
//  prodActiv
//
//  Created by Kevin Radtke on 4/25/19.
//  Copyright © 2019 Jaime Alberto Gonzalez. All rights reserved.
//

import UIKit

protocol protocolAddTaskDetails {
    func addTask(newTask : Task)
}

class DetailsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tagsArray = [Tag]()
    var selectedColor : UIColor!
    var selectedTag : Tag!
    
    var editTask : Bool!
    var editTitle : String!
    var editTag : Tag!
    var editDate : Date!
    
    var delegate : protocolAddTaskDetails!
    
    @IBOutlet weak var tfTaskName: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var viewSelectedColor: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(quitaTeclado))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        if (editTask) {
            tfTaskName.text = editTitle
            datePicker.date = editDate
            viewSelectedColor.backgroundColor = editTag.color
        }
        fetchTags()
        let currentDate = Date()
        datePicker.minimumDate = currentDate
    }
    
    @IBAction func quitaTeclado(){
        view.endEditing(true)
    }
    
    
    @IBAction func cancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTask(_ sender: UIButton) {
        
        let titulo = tfTaskName.text!
        
        if (titulo != "") {
            
            if (selectedTag == nil) {
                selectedTag = Tag(name: "", color: UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0))
            }
            
            let newTask = Task(title: titulo, date: datePicker.date, tag: selectedTag, done: false)
            
            delegate.addTask(newTask: newTask)
        }
        else {
            showAlert(msg: "Please enter a task name.")
        }
    }
    
    // TAGS TABLE VIEW
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = tagsArray[indexPath.row].name
        cell.backgroundColor = tagsArray[indexPath.row].color.withAlphaComponent(0.75)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedColor = tagsArray[indexPath.row].color
        selectedTag = tagsArray[indexPath.row]
        viewSelectedColor.backgroundColor = selectedColor.withAlphaComponent(0.75)
    }
    
    // FUNCTIONS
    
    func fetchTags() {
        if(UserDefaults.standard.object(forKey: "tagsList") == nil)
        {
            let t1 = Tag(name: "Personal", color: UIColor.orange)
            let t2 = Tag(name: "Work", color: UIColor.yellow)
            let t3 = Tag(name: "Health", color: UIColor.cyan)
            tagsArray.append(t1)
            tagsArray.append(t2)
            tagsArray.append(t3)
        }
        else{
            let saveData = UserDefaults.standard.data(forKey: "tagsList")
            let arr = NSKeyedUnarchiver.unarchiveObject(with: saveData!) as? [Tag]
            tagsArray = arr!
        }
    }
    
    func showAlert(msg : String) {
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
