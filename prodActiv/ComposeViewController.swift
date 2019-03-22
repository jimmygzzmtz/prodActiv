//
//  ComposeViewController.swift
//  prodActiv
//
//  Created by Jaime Alberto Gonzalez on 3/22/19.
//  Copyright © 2019 Jaime Alberto Gonzalez. All rights reserved.
//

import UIKit

protocol protocolAddTask {
    func addTask(newTask : Task)
}


extension String {
    func matchingStrings(regex: String) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: [.caseInsensitive]) else { return [] }
        let nsString = self as NSString
        let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
        return results.map { result in
            (0..<result.numberOfRanges).map {
                result.range(at: $0).location != NSNotFound
                    ? nsString.substring(with: result.range(at: $0))
                    : ""
            }
        }
    }
}

class ComposeViewController: UIViewController {
    
    @IBOutlet weak var tvCompose: UITextView!
    
    var newTask = Task(title: "title", date: "date", time: "time");
    
    var delegate : protocolAddTask!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tvCompose.layer.borderColor = UIColor.lightGray.cgColor
        self.tvCompose.layer.borderWidth = 1

    }
    
    @IBAction func addButton(_ sender: UIButton) {
        
        let taskText = tvCompose.text!;
        
        var dateMatch = "";
        var timeMatch = "";
        
        let dateMatches = taskText.matchingStrings(regex: "((for)?\\s*(today|tomorrow|in a day|in \\d+ days|next week|in a week|in \\d+ weeks|next month|in a month|in \\d+ months|next year|in a year|in \\d+ years))|((for|on)?\\s*(next)?\\s*(monday|tuesday|wednesday|thursday|friday|saturday|sunday))|((for|on)?\\s*(january \\d+|february \\d+|march \\d+|april \\d+|may \\d+|june \\d+|july \\d+|august \\d+|september \\d+|october \\d+|november \\d+|december \\d+))")
        
        let timeMatches = taskText.matchingStrings(regex: "((at)?\\s*((\\d+):(\\d+)\\s*(am|pm)))|((at)?\\s*((\\d+):(\\d+)))|((at)?\\s*((\\d+)\\s*(am|pm)))|(at\\s*(\\d+))")
        
        if (dateMatches.count != 0){
            dateMatch = dateMatches[0][0];
        }
        
        if (timeMatches.count != 0){
            timeMatch = timeMatches[0][0];
        }
        
        var titleMatch = taskText.replacingOccurrences(of: dateMatch, with: "")
        titleMatch = titleMatch.replacingOccurrences(of: timeMatch, with: "")
        
        newTask = Task(title: titleMatch, date: dateMatch, time: timeMatch);
        
        delegate.addTask(newTask: newTask)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cardsView = segue.destination as! FirstViewController
        cardsView.tasksList.append(newTask);
        cardsView.collectionView.reloadData();
    }
     */
    

}
