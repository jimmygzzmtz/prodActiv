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
    
    func addTag(newTag: Tag, i: IndexPath) {
        
    }
    
    func editTag(newTag: Tag, i: IndexPath) {
        
    }
    

    var tagsArray = [Tag]()
    
    @IBOutlet weak var switchEsp: UISwitch!
    @IBOutlet weak var switchEng: UISwitch!
    
    @IBOutlet weak var tagsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let t1 = Tag(name: "iOS", color: UIColor.orange)
        let t2 = Tag(name: "Lenguajes", color: UIColor.yellow)
        let t3 = Tag(name: "Web", color: UIColor.cyan)
        tagsArray.append(t1)
        tagsArray.append(t2)
        tagsArray.append(t3)
    }
    
    @IBAction func addTag(_ sender: UIButton) {
        
    }

    // TAGS TABLE VIEW
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = tagsArray[indexPath.row].name
//        cell.detailTextLabel?.text = tagsArray[indexPath.row].color.description
        return cell
    }
    
    // SEGUE
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! NewTagVC
        if (segue.identifier == "edit") {
            vc.editTag = true
            
//            vista.catNombre = cats[(tableView.indexPathForSelectedRow?.row)!].titulo
//            indexModifica = tableView.indexPathForSelectedRow
        }
        else {
            vc.editTag = false
        }
        vc.delegate = self
    }
    
}

