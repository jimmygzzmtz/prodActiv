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
    
    var newTask = Task(title: "title", date: Date(), time: "time", tag: "", done: false);
    
    var delegate : protocolAddTask!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tvCompose.layer.borderColor = UIColor.lightGray.cgColor
        self.tvCompose.layer.borderWidth = 1

    }
    
    @IBAction func addButton(_ sender: UIButton) {
        
        let taskText = tvCompose.text!;
        
        var newDate = Date()
        
        var dateMatch = "";
        var timeMatch = "";
        
        let dateMatches = taskText.matchingStrings(regex: "((for)?\\s*(today|tomorrow|in a day|in \\d+ days|next week|in a week|in \\d+ weeks|next month|in a month|in \\d+ months|next year|in a year|in \\d+ years))|((for|on)?\\s*(next)?\\s*(monday|tuesday|wednesday|thursday|friday|saturday|sunday))|((for|on)?\\s*(january \\d+|february \\d+|march \\d+|april \\d+|may \\d+|june \\d+|july \\d+|august \\d+|september \\d+|october \\d+|november \\d+|december \\d+))")
        
        let timeMatches = taskText.matchingStrings(regex: "((at)?\\s*((\\d+):(\\d+)\\s*(am|pm)))|((at)?\\s*((\\d+):(\\d+)))|((at)?\\s*((\\d+)\\s*(am|pm)))|(at\\s*(\\d+))")
        
        if (dateMatches.count != 0){
            dateMatch = dateMatches[0][0];
            newDate = convertToDate(sDate: dateMatch, today: newDate);
        }
        
        if (timeMatches.count != 0){
            timeMatch = timeMatches[0][0];
            newDate = convertToTime(sTime: timeMatch, theDate: newDate);
        }
        
        var titleMatch = taskText.replacingOccurrences(of: dateMatch, with: "")
        titleMatch = titleMatch.replacingOccurrences(of: timeMatch, with: "")
        
        newTask = Task(title: titleMatch, date: newDate, time: timeMatch, tag: "", done: false);
        
        delegate.addTask(newTask: newTask)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func cancelButton(_ sender: Any) {
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
    
    func convertToDate(sDate: String, today: Date) -> Date {
        
        if sDate.matchingStrings(regex: "today").count != 0{
            return today;
        }
        
        if sDate.matchingStrings(regex: "tomorrow|in a day").count != 0{
            return Calendar.current.date(byAdding: .day, value: 1, to: today)!;
        }
        
        if sDate.matchingStrings(regex: "in \\d+ days").count != 0{
            return Calendar.current.date(byAdding: .day, value: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!, to: today)!;
        }
        
        if sDate.matchingStrings(regex: "next week|in a week").count != 0{
            return Calendar.current.date(byAdding: .day, value: 7, to: today)!;
        }
        
        if sDate.matchingStrings(regex: "in \\d+ weeks").count != 0{
            return Calendar.current.date(byAdding: .day, value: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!*7, to: today)!;
        }
        
        if sDate.matchingStrings(regex: "next month|in a month").count != 0{
            return Calendar.current.date(byAdding: .month, value: 1, to: today)!;
        }
        
        if sDate.matchingStrings(regex: "in \\d+ months").count != 0{
            return Calendar.current.date(byAdding: .month, value: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!, to: today)!;
        }
        
        if sDate.matchingStrings(regex: "next year|in a year").count != 0{
            return Calendar.current.date(byAdding: .year, value: 1, to: today)!;
        }
        
        if sDate.matchingStrings(regex: "in \\d+ years").count != 0{
            return Calendar.current.date(byAdding: .year, value: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!, to: today)!;
        }
        
        let calendar = Calendar(identifier: .gregorian)
        
        if sDate.matchingStrings(regex: "monday").count != 0{
            let dateComponents = DateComponents(calendar: calendar, weekday: 2)
            return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
        }
        
        if sDate.matchingStrings(regex: "tuesday").count != 0{
            let dateComponents = DateComponents(calendar: calendar, weekday: 3)
            return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
        }
        
        if sDate.matchingStrings(regex: "wednesday").count != 0{
            let dateComponents = DateComponents(calendar: calendar, weekday: 4)
            return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
        }
        
        if sDate.matchingStrings(regex: "thursday").count != 0{
            let dateComponents = DateComponents(calendar: calendar, weekday: 5)
            return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
        }
        
        if sDate.matchingStrings(regex: "friday").count != 0{
            let dateComponents = DateComponents(calendar: calendar, weekday: 6)
            return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
        }
        
        if sDate.matchingStrings(regex: "saturday").count != 0{
            let dateComponents = DateComponents(calendar: calendar, weekday: 7)
            return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
        }
        
        if sDate.matchingStrings(regex: "sunday").count != 0{
            let dateComponents = DateComponents(calendar: calendar, weekday: 1)
            return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
        }
        
        if sDate.matchingStrings(regex: "january \\d+").count != 0{
            let dateComponents = DateComponents(calendar: calendar, month: 1, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
            return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
        }
        
        if sDate.matchingStrings(regex: "february \\d+").count != 0{
            let dateComponents = DateComponents(calendar: calendar, month: 2, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
            return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
        }
        
        if sDate.matchingStrings(regex: "march \\d+").count != 0{
            let dateComponents = DateComponents(calendar: calendar, month: 3, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
            return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
        }
        
        if sDate.matchingStrings(regex: "april \\d+").count != 0{
            let dateComponents = DateComponents(calendar: calendar, month: 4, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
            return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
        }
        
        if sDate.matchingStrings(regex: "may \\d+").count != 0{
            let dateComponents = DateComponents(calendar: calendar, month: 5, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
            return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
        }
        
        if sDate.matchingStrings(regex: "june \\d+").count != 0{
            let dateComponents = DateComponents(calendar: calendar, month: 6, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
            return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
        }
        
        if sDate.matchingStrings(regex: "july \\d+").count != 0{
            let dateComponents = DateComponents(calendar: calendar, month: 7, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
            return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
        }
        
        if sDate.matchingStrings(regex: "august \\d+").count != 0{
            let dateComponents = DateComponents(calendar: calendar, month: 8, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
            return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
        }
        
        if sDate.matchingStrings(regex: "september \\d+").count != 0{
            let dateComponents = DateComponents(calendar: calendar, month: 9, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
            return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
        }
        
        if sDate.matchingStrings(regex: "october \\d+").count != 0{
            let dateComponents = DateComponents(calendar: calendar, month: 10, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
            return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
        }
        
        if sDate.matchingStrings(regex: "november \\d+").count != 0{
            let dateComponents = DateComponents(calendar: calendar, month: 11, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
            return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
        }
        
        if sDate.matchingStrings(regex: "december \\d+").count != 0{
            let dateComponents = DateComponents(calendar: calendar, month: 12, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
            return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
        }
        
        
        
        return today;
        
    }
    
    func convertToTime(sTime: String, theDate: Date) -> Date {
        
        var hours = 0;
        var minutes = 0;
        
        hours = Int(sTime.matchingStrings(regex: "\\d+")[0][0])!
        
        if (hours == 12){
            hours = 0;
        }
        
        if sTime.matchingStrings(regex: ":\\s*\\d+").count != 0{
            minutes = Int(sTime.matchingStrings(regex: ":\\s*\\d+")[0][0].matchingStrings(regex: "\\d+")[0][0])!
        }
        
        if sTime.matchingStrings(regex: "pm").count != 0{
            hours += 12;
        }
        
        return Calendar.current.date(bySettingHour: hours, minute: minutes, second: 0, of: theDate)!
        
    }
    

}
