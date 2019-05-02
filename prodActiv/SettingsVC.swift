//
//  SettingsVC.swift
//  prodActiv
//
//  Created by Jaime Alberto Gonzalez on 3/18/19.
//  Copyright © 2019 Jaime Alberto Gonzalez. All rights reserved.
//

import UIKit

protocol protocolSettings {
    func updateTag(newTag : Tag) -> Void
}

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, protocolTags {
    
    // TAGS PROTOCOL
    
    func addTag(newTag: Tag) {
        tagsArray.append(newTag)
        tagsTableView.reloadData()
        saveData()
    }
    
    func editTag(newTag: Tag, i: IndexPath) {
        tagsArray[i.row] = newTag
        tagsTableView.reloadData()
        saveData()
    }
    
    var tagsArray = [Tag]()
    
    var delegate : protocolSettings!
    
    @IBOutlet weak var switchEsp: UISwitch!
    @IBOutlet weak var switchEng: UISwitch!
    
    @IBOutlet weak var switchNotif: UISwitch!
    
    @IBOutlet weak var tagsTableView: UITableView!
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTags()
        switchEng.setOn(true, animated: true)
        switchEsp.setOn(true, animated: true)
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
    }
    
    // SEGUE
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! NewTagVC
        if (segue.identifier == "edit") {
            vc.editTag = true
            vc.editingTag = tagsArray[(tagsTableView.indexPathForSelectedRow?.row)!]
            vc.editingIndex = tagsTableView.indexPathForSelectedRow
        }
        else {
            vc.editTag = false
        }
        vc.delegate = self
    }
    
    // FUNC SAVE DATA
    func saveData() {
        let saveData = NSKeyedArchiver.archivedData(withRootObject: tagsArray)
        UserDefaults.standard.set(saveData, forKey: "tagsList")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        switchEng.isOn = UserDefaults.standard.bool(forKey: "switchEng")
        switchEsp.isOn = UserDefaults.standard.bool(forKey: "switchEsp")
        switchNotif.isOn = UserDefaults.standard.bool(forKey: "switchNotif")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (!switchEng.isOn && !switchEsp.isOn) {
            showAlert(msg: "Please select a language for regex parser.")
        }
        else {
            UserDefaults.standard.set(switchEng.isOn, forKey: "switchEng")
            UserDefaults.standard.set(switchEsp.isOn, forKey: "switchEsp")
            UserDefaults.standard.set(switchNotif.isOn, forKey: "switchNotif")
        }
        
    }
    
    // REGEX LANGUAGE SWITCHES
    
    @IBAction func switchEsp(_ sender: UISwitch) {
        if (!switchEsp.isOn && !switchEng.isOn) {
            showAlert(msg: "Please select at least one language.")
            switchEsp.setOn(true, animated: true)
        }
    }
    
    @IBAction func switchEng(_ sender: UISwitch) {
        if (!switchEng.isOn && !switchEsp.isOn) {
            showAlert(msg: "Please select at least one language.")
            switchEng.setOn(true, animated: true)
        }
    }
    
    
    
    
    // ALERT FUNCTION
    
    func showAlert(msg : String) {
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
    override var shouldAutorotate: Bool {
        return false
    }
}

