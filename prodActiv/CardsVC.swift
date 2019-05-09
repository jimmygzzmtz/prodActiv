//
//  CardsVC.swift
//  prodActiv
//
//  Created by Jaime Alberto Gonzalez on 3/18/19.
//  Copyright © 2019 Jaime Alberto Gonzalez. All rights reserved.
//

import UIKit

class CardsVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, protocolTask, protocolSettings {
    
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var tasksList = [Task]()
    var showList = [Task]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(UserDefaults.standard.object(forKey: "tasksList") == nil)
        {
            
        }
        else{
            let saveData = UserDefaults.standard.data(forKey: "tasksList")
            let arreglo = NSKeyedUnarchiver.unarchiveObject(with: saveData!) as? [Task]
            tasksList = arreglo!
        }
        
        showList = tasksList;
        
        let app = UIApplication.shared
        NotificationCenter.default.addObserver(self, selector: #selector(aplicacionTerminara(notif:)), name: UIApplication.willResignActiveNotification, object: app)
        
        loadCards()
    }
    
    @IBAction func aplicacionTerminara(notif: NSNotification) {
        let saveData = NSKeyedArchiver.archivedData(withRootObject: tasksList)
        UserDefaults.standard.set(saveData, forKey: "tasksList")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return showList.count;
    }
    
    @IBAction func changeSegmented(_ sender: UISegmentedControl) {
        loadCards()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        cell.setupSwipeGesture()
        cell.swipeGesture.delegate = self;
        
        let formatter = DateFormatter()
        
        cell.lbTitle.text = showList[indexPath.row].title;
        cell.lblTagName.text = showList[indexPath.row].tag.name
        formatter.dateFormat = "dd MMMM, yyyy"
        cell.lbDate.text = formatter.string(from: showList[indexPath.row].date);
        formatter.dateFormat = "HH:mm"
        cell.lbTime.text = formatter.string(from: showList[indexPath.row].date);
        
        cell.contentView.layer.backgroundColor = showList[indexPath.row].tag.color.cgColor
        cell.contentView.layer.cornerRadius = 4.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        cell.layer.shadowRadius = 4.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        
        cell.btDelete.addTarget(self, action: #selector(deleteTask), for: .touchUpInside)
        cell.btDelete.tag = indexPath.row
        
        let origTrash = UIImage(named: "trash");
        let tintedTrash = origTrash?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        cell.btDelete.setImage(tintedTrash, for: .normal)
        cell.btDelete.tintColor = UIColor.red
        
        let origCheck = UIImage(named: "check");
        let tintedCheck = origCheck?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        cell.checkImg.image = tintedCheck
        cell.checkImg.tintColor = UIColor.green
        
        cell.btDone.addTarget(self, action: #selector(doneTask), for: .touchUpInside)
        cell.btDone.tag = indexPath.row
        
        
        if(showList[indexPath.row].done == true){
            cell.checkImg.isHidden = false;
            cell.btInfo.isHidden = true;
        }
        if(showList[indexPath.row].done == false){
            cell.checkImg.isHidden = true;
            cell.btInfo.isHidden = false;
        }
        
        cell.btInfo.tag = indexPath.row
        
        
        cell.btDone.isHidden = true;
        
        return cell;
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Entered settings")
        if (segue.identifier == "add") {
            let composeView = segue.destination as! ComposeVC
            composeView.editTask = false
            composeView.delegate = self
        }
        else {
            let settingsView = segue.destination as! SettingsVC
            settingsView.delegate = self
        }
    }
    
    var editPos : Int!
    
    @IBAction func showDetails(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let composeView = storyboard.instantiateViewController(withIdentifier: "ComposeVC") as! ComposeVC
        var count = 0;
        for task in tasksList{
            if (task == showList[sender.tag]){
                editPos = sender.tag
                composeView.editTitle = tasksList[count].title
                composeView.editTag = tasksList[count].tag
                composeView.editDate = tasksList[count].date
            }
            count = count + 1;
        }
        composeView.editTask = true
        composeView.delegate = self
        present(composeView, animated: true, completion: nil)
    }
    
    //TASK PROTOCOL
    
    func addTask(newTask: Task) {
        tasksList.append(newTask);
        tasksList.sort(by: ({ $0.date.compare($1.date) == ComparisonResult.orderedAscending}))
        loadCards();
    }
    
    func editTask(newTask: Task) {
        print("edit cards")
        print(newTask.date)
        print(newTask.title)
        self.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
        self.tasksList[editPos] = newTask
        tasksList.sort(by: ({ $0.date.compare($1.date) == ComparisonResult.orderedAscending}))
        loadCards();
    }
    
    // SETTINGS PROTOCOL
    
    func updateTag(newTag: Tag) {
        print("received tag")
        print(newTag)
    }
    
    @IBAction func deleteTask(_ sender: UIButton) {
        //tasksList.remove(at: sender.tag)
        
        let alerta = UIAlertController(title: "Delete?", message: "The task will be permanently removed.", preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            var count = 0;
            for task in self.tasksList{
                if (task == self.showList[sender.tag]){
                    self.tasksList.remove(at: count)
                }
                count = count + 1;
            }
            self.loadCards();
        }))
        alerta.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in

        }))
        
        present(alerta, animated: true, completion: nil)
    }
    
    @IBAction func doneTask(_ sender: UIButton) {
        //tasksList[sender.tag].done = true;
        
        if(showList.count == 0){
            return
        }
    
        var count = 0;
        for task in tasksList{
            if (task == showList[sender.tag]){
                if(tasksList[count].done == false){
                    tasksList[count].done = true;
                    loadCards();
                    return;
                }
                if(tasksList[count].done == true){
                    tasksList[count].done = false;
                    loadCards();
                    return;
                }
                
            }
            count = count + 1;
        }
        
        //loadCards();
    }
    
    func loadCards(){
        if(segmentedControl.selectedSegmentIndex == 0){
            showList = tasksList.filter{$0.done == false}
        }
        if(segmentedControl.selectedSegmentIndex == 1){
            showList = tasksList.sorted(by: {$0.tag.name > $1.tag.name}).filter{$0.done == false}
        }
        if(segmentedControl.selectedSegmentIndex == 2){
            showList = tasksList.filter{$0.done == true};
        }
        if(segmentedControl.selectedSegmentIndex == 3){
            showList = tasksList;
        }
        collectionView.reloadData();
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    override var shouldAutorotate: Bool {
        return false
    }


}

