//
//  SettingsVC.swift
//  prodActiv
//
//  Created by Jaime Alberto Gonzalez on 3/18/19.
//  Copyright © 2019 Jaime Alberto Gonzalez. All rights reserved.
//

import UIKit

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
    
    @IBOutlet weak var switchEsp: UISwitch!
    @IBOutlet weak var switchEng: UISwitch!
    
    @IBOutlet weak var tagsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(UserDefaults.standard.object(forKey: "tagsList") == nil)
        {
            let t1 = Tag(name: "iOS", color: UIColor.orange)
            let t2 = Tag(name: "Lenguajes", color: UIColor.yellow)
            let t3 = Tag(name: "Web", color: UIColor.cyan)
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.set(switchEng.isOn, forKey: "switchEng")
        UserDefaults.standard.set(switchEsp.isOn, forKey: "switchEsp")
    }
    
}

