//
//  NewTagVC.swift
//  prodActiv
//
//  Created by Kevin Radtke on 4/6/19.
//  Copyright © 2019 Jaime Alberto Gonzalez. All rights reserved.
//

import UIKit

protocol protocolTags {
    func addTag(newTag : Tag, i : IndexPath) -> Void
    func editTag(newTag : Tag, i : IndexPath) -> Void
}

class NewTagVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var colorsArray = [UIColor.blue, UIColor.green, UIColor.purple, UIColor.red, UIColor.yellow, UIColor.orange, UIColor.cyan]
    
    var delegate : protocolTags!
    
    var tagName : String!
    var selectedColor : UIColor!
    var editTag: Bool!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tfTagName: UITextField!
    @IBOutlet weak var viewSelectedColor: UIView!
    @IBOutlet weak var btnSave: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (editTag) {
            tfTagName.text = tagName
            viewSelectedColor.backgroundColor = selectedColor.withAlphaComponent(0.75)
            lblTitle.text = "Edit Tag"
        }
        else {
            lblTitle.text = "New Tag"
        }
    }
    
    // BTN METHODS
    
    @IBAction func saveTag(_ sender: UIButton) {
        if (tfTagName.text != nil) {
            if (editTag) {
                
                //call delegate function for editing tag
                
//                let newTag = Tag(name: tagName, color: selectedColor)
                self.dismiss(animated: true, completion: nil)
            }
            else {
                // delegate fctn for new tag
            }
        }
        else {
            //alert, tf empty
        }
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // TABLE VIEW
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colorsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.backgroundColor = colorsArray[indexPath.row].withAlphaComponent(0.75)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        btnSave.isEnabled = true
        selectedColor = colorsArray[indexPath.row]
        viewSelectedColor.backgroundColor = selectedColor.withAlphaComponent(0.75)
    }

    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
