//
//  FirstViewController.swift
//  prodActiv
//
//  Created by Jaime Alberto Gonzalez on 3/18/19.
//  Copyright © 2019 Jaime Alberto Gonzalez. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, protocolAddTask {
    
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
        
        let formatter = DateFormatter()
        
        cell.lbTitle.text = showList[indexPath.row].title;
        formatter.dateFormat = "dd MMMM, yyyy"
        cell.lbDate.text = formatter.string(from: showList[indexPath.row].date);
        formatter.dateFormat = "HH:mm"
        cell.lbTime.text = formatter.string(from: showList[indexPath.row].date);
        
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
        
        cell.btDone.addTarget(self, action: #selector(doneTask), for: .touchUpInside)
        cell.btDone.tag = indexPath.row
        
        if(showList[indexPath.row].done == true){
            cell.btDone.isHidden = true;
        }
        if(showList[indexPath.row].done == false){
            cell.btDone.isHidden = false;
        }
        
        return cell;
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let taskView = segue.destination as! ComposeViewController
        taskView.delegate = self
        
    }
    
    func addTask(newTask: Task) {
        tasksList.append(newTask);
        tasksList.sort(by: ({ $0.date.compare($1.date) == ComparisonResult.orderedAscending}))
        loadCards();
    }
    
    @IBAction func deleteTask(_ sender: UIButton) {
        //tasksList.remove(at: sender.tag)
        
        var count = 0;
        for task in tasksList{
            if (task == showList[sender.tag]){
                tasksList.remove(at: count)
            }
            count = count + 1;
        }
        
        loadCards();
    }
    
    @IBAction func doneTask(_ sender: UIButton) {
        //tasksList[sender.tag].done = true;
    
        var count = 0;
        for task in tasksList{
            if (task == showList[sender.tag]){
                tasksList[count].done = true;
            }
            count = count + 1;
        }
        
        loadCards();
    }
    
    func loadCards(){
        if(segmentedControl.selectedSegmentIndex == 0){
            showList = tasksList.filter{$0.done == false}
        }
        if(segmentedControl.selectedSegmentIndex == 1){
            showList = tasksList;
        }
        if(segmentedControl.selectedSegmentIndex == 2){
            showList = tasksList.filter{$0.done == true};
        }
        if(segmentedControl.selectedSegmentIndex == 3){
            showList = tasksList;
        }
        collectionView.reloadData();
    }


}

