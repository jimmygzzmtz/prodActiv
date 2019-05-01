//
//  ComposeVC.swift
//  prodActiv
//
//  Created by Jaime Alberto Gonzalez on 3/22/19.
//  Copyright © 2019 Jaime Alberto Gonzalez. All rights reserved.
//

import UIKit
import UserNotifications

protocol protocolAddTask {
    func addTask(newTask : Task)
}

var switchEsp = true;
var switchEng = true;
var switchNotif = true;


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

class ComposeVC: UIViewController, UITextViewDelegate, protocolAddTaskDetails {
    
    @IBOutlet weak var tvCompose: UITextView!
    @IBOutlet weak var tvDetectedTags: UITextView!
    
    var datesEnglish = "((for)?\\s*(today|tomorrow|in a day|in \\d+ days|next week|in a week|in \\d+ weeks|next month|in a month|in \\d+ months|next year|in a year|in \\d+ years))|((for|on)?\\s*(next)?\\s*(monday|tuesday|wednesday|thursday|friday|saturday|sunday))|((for|on)?\\s*(january \\d+|february \\d+|march \\d+|april \\d+|may \\d+|june \\d+|july \\d+|august \\d+|september \\d+|october \\d+|november \\d+|december \\d+))";
    var datesSpanish = "((para)?\\s*(hoy|mañana|en un día|en \\d+ días|la próxima semana|en una semana|en \\d+ semanas|el próximo mes|en un mes|en \\d+ meses|el próximo año|en un año|en \\d+ años))|((para|en)?\\s*(el)?\\s*(siguiente)?\\s*(lunes|martes|miércoles|jueves|viernes|sábado|domingo))|((para|en)?\\s*(el)?\\s*(enero \\d+|\\d+ de enero|febrero \\d+|\\d+ de febrero|marzo \\d+|\\d+ de marzo|abril \\d+|\\d+ de abril|mayo \\d+|\\d+ de mayo|junio \\d+|\\d+ de junio|julio \\d+|\\d+ de julio|agosto \\d+|\\d+ de agosto|septiembre \\d+|\\d+ de septiembre|octubre \\d+|\\d+ de octubre|noviembre \\d+|\\d+ de noviembre|diciembre \\d+|\\d+ de diciembre))";
    
    var newDate = Date()
    
    var dateMatch = "";
    var timeMatch = "";
    var allDates = "";
    var taskText = "";
    var tagMatch : Tag!
    
    
    var newTask = Task(title: "title", date: Date(), tag: Tag(name: "tagname", color: UIColor.gray), done: false);
    var tagsArray = [Tag]()
    
    var delegate : protocolAddTask!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(quitaTeclado))
        view.addGestureRecognizer(tap)
        
        self.tvCompose.layer.borderColor = UIColor.lightGray.cgColor
        self.tvCompose.layer.borderWidth = 1
        self.tvCompose.delegate = self
        
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
    
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText string: String) -> Bool {
        matchVariables()
        var detectedText = ""
        if (dateMatch != "") {
            detectedText += dateMatch
            detectedText += "\n"
        }
        if (timeMatch != "") {
            detectedText += timeMatch
            detectedText += "\n "
        }
        if (tagMatch.name != "") {
            detectedText += tagMatch.name
        }
        tvDetectedTags.text = detectedText
        return true
    }
    
    @IBAction func quitaTeclado(){
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(UserDefaults.standard.object(forKey: "switchEng") != nil){
            switchEng = UserDefaults.standard.bool(forKey: "switchEng")
            switchEsp = UserDefaults.standard.bool(forKey: "switchEsp")
            switchNotif = UserDefaults.standard.bool(forKey: "switchNotif")
        }
        else{
            UserDefaults.standard.set(true, forKey: "switchEng")
            UserDefaults.standard.set(true, forKey: "switchEsp")
            UserDefaults.standard.set(true, forKey: "switchNotif")
        }
    }
    
    func matchVariables() {
        taskText = tvCompose.text!
        
        //DATE MATCHING
        
        if(switchEsp == true && switchEng == true){
            allDates = datesEnglish + "|" + datesSpanish;
        }
        if(switchEsp == true && switchEng == false){
            allDates = datesSpanish;
        }
        if(switchEsp == false && switchEng == true){
            allDates = datesEnglish;
        }
        
        let dateMatches = taskText.matchingStrings(regex: allDates)
        
        if (dateMatches.count != 0){
            dateMatch = dateMatches[0][0];
            newDate = convertToDate(sDate: dateMatch, today: newDate);
        } else {
            dateMatch = ""
        }
        
        // TIME MATCHING
        
        var timeMatches = [[""]];
        
        if(switchEsp == true && switchEng == true){
            timeMatches = taskText.matchingStrings(regex: "((at|a las|a la)?\\s*((\\d+):(\\d+)\\s*(am|pm)))|((at|a las|a la)?\\s*((\\d+):(\\d+)))|((at|a las|a la)?\\s*((\\d+)\\s*(am|pm)))|((at|a las|a la)\\s*(\\d+))")
        }
        
        if(switchEsp == false && switchEng == true){
            timeMatches = taskText.matchingStrings(regex: "((at)?\\s*((\\d+):(\\d+)\\s*(am|pm)))|((at)?\\s*((\\d+):(\\d+)))|((at)?\\s*((\\d+)\\s*(am|pm)))|((at)\\s*(\\d+))")
        }
        
        if(switchEsp == true && switchEng == false){
            timeMatches = taskText.matchingStrings(regex: "((a las|a la)?\\s*((\\d+):(\\d+)\\s*(am|pm)))|((a las|a la)?\\s*((\\d+):(\\d+)))|((a las|a la)?\\s*((\\d+)\\s*(am|pm)))|((a las|a la)\\s*(\\d+))")
        }
        
        if (timeMatches.count != 0){
            timeMatch = timeMatches[0][0];
            newDate = convertToTime(sTime: timeMatch, theDate: newDate);
        } else {
            timeMatch = ""
        }
        
        if(timeMatches.count == 0){
            newDate = Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: Date()), minute: Calendar.current.component(.minute, from: Date()), second: Calendar.current.component(.second, from: Date()), of: newDate)!
        }
        
        // TAG MATCHING
        
        for tag in tagsArray {
            let searchName = tag.name.lowercased()
            let searchText = taskText.lowercased()
            let tagMatches = searchText.matchingStrings(regex: searchName)
            if (tagMatches.count != 0) {
                if (searchName == tagMatches[0][0]) {
                    tagMatch = tag
                    break
                }
            } else {
                tagMatch = Tag(name: "", color: UIColor.white)
            }
        }
        if (tagMatch == nil) {
            tagMatch = Tag(name: "", color: UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0))
        }
    }
    
    @IBAction func addButton(_ sender: UIButton) {
        
        matchVariables()
        //tagMatch = Tag(name: "iOS", color: UIColor.cyan)
        
        // TASK CREATION
        var titleMatch = taskText.replacingOccurrences(of: dateMatch, with: "")
        titleMatch = titleMatch.replacingOccurrences(of: timeMatch, with: "")
        if ((tagMatch) != nil) {
            titleMatch = titleMatch.replacingOccurrences(of: tagMatch.name, with: "", options: .caseInsensitive)
        }
        
        newTask = Task(title: titleMatch, date: newDate, tag: tagMatch, done: false)
        
        delegate.addTask(newTask: newTask)
        
        if(switchNotif == true && (Calendar.current.date(byAdding: .minute, value: -30, to: newDate)! > Date())){
            let notificationCenter = UNUserNotificationCenter.current()
            
            let content = UNMutableNotificationContent()
            content.title = "Reminder"
            content.body = titleMatch
            content.sound = UNNotificationSound.default
            content.badge = 1
            
            let dateTrig = Calendar.current.date(byAdding: .minute, value: -30, to: newDate)
            let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: dateTrig!)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            
            let identifier = "Task Notification"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            notificationCenter.add(request) { (error) in
                if let error = error {
                    print("Error \(error.localizedDescription)")
                }
            }
            
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func addTask(newTask: Task) {
        delegate.addTask(newTask: newTask)
        self.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "details" {
            let detailsView = segue.destination as! DetailsVC
            detailsView.delegate = self
        }
    }
 
    
    func convertToDate(sDate: String, today: Date) -> Date {
        
        if(switchEsp == true && switchEng == true){
            if sDate.matchingStrings(regex: "today|hoy").count != 0 {
                return today;
            }
            
            if sDate.matchingStrings(regex: "tomorrow|in a day|mañana|en un día").count != 0 {
                return Calendar.current.date(byAdding: .day, value: 1, to: today)!;
            }
            
            if sDate.matchingStrings(regex: "in \\d+ days|en \\d+ días").count != 0 {
                return Calendar.current.date(byAdding: .day, value: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!, to: today)!;
            }
            
            if sDate.matchingStrings(regex: "next week|in a week|la próxima semana|en una semana").count != 0 {
                return Calendar.current.date(byAdding: .day, value: 7, to: today)!;
            }
            
            if sDate.matchingStrings(regex: "in \\d+ weeks|en \\d+ semanas").count != 0 {
                return Calendar.current.date(byAdding: .day, value: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!*7, to: today)!;
            }
            
            if sDate.matchingStrings(regex: "next month|in a month|el próximo mes|en un mes").count != 0 {
                return Calendar.current.date(byAdding: .month, value: 1, to: today)!;
            }
            
            if sDate.matchingStrings(regex: "in \\d+ months|en \\d+ meses").count != 0 {
                return Calendar.current.date(byAdding: .month, value: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!, to: today)!;
            }
            
            if sDate.matchingStrings(regex: "next year|in a year|el próximo año|en un año").count != 0 {
                return Calendar.current.date(byAdding: .year, value: 1, to: today)!;
            }
            
            if sDate.matchingStrings(regex: "in \\d+ years|en \\d+ años").count != 0 {
                return Calendar.current.date(byAdding: .year, value: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!, to: today)!;
            }
            
            let calendar = Calendar(identifier: .gregorian)
            
            if sDate.matchingStrings(regex: "monday|lunes").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, weekday: 2)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "tuesday|martes").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, weekday: 3)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "wednesday|miércoles").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, weekday: 4)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "thursday|jueves").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, weekday: 5)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "friday|viernes").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, weekday: 6)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "saturday|sábado").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, weekday: 7)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "sunday|domingo").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, weekday: 1)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "january \\d+|enero \\d+|\\d+ de enero").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, month: 1, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "february \\d+|febrero \\d+|\\d+ de febrero").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, month: 2, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "march \\d+|marzo \\d+|\\d+ de marzo").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, month: 3, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "april \\d+|abril \\d+|\\d+ de abril").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, month: 4, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "may \\d+|mayo \\d+|\\d+ de mayo").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, month: 5, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "june \\d+|junio \\d+|\\d+ de junio").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, month: 6, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "july \\d+|julio \\d+|\\d+ de julio").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, month: 7, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "august \\d+|agosto \\d+|\\d+ de agosto").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, month: 8, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "september \\d+|septiembre \\d+|\\d+ de septiembre").count != 0{
                let dateComponents = DateComponents(calendar: calendar, month: 9, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "october \\d+|octubre \\d+|\\d+ de octubre").count != 0{
                let dateComponents = DateComponents(calendar: calendar, month: 10, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "november \\d+|noviembre \\d+|\\d+ de noviembre").count != 0{
                let dateComponents = DateComponents(calendar: calendar, month: 11, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "december \\d+|diciembre \\d+|\\d+ de diciembre").count != 0{
                let dateComponents = DateComponents(calendar: calendar, month: 12, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            
            
        }
        
        if(switchEsp == true && switchEng == false){
            if sDate.matchingStrings(regex: "hoy").count != 0 {
                return today;
            }
            
            if sDate.matchingStrings(regex: "mañana|en un día").count != 0 {
                return Calendar.current.date(byAdding: .day, value: 1, to: today)!;
            }
            
            if sDate.matchingStrings(regex: "en \\d+ días").count != 0 {
                return Calendar.current.date(byAdding: .day, value: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!, to: today)!;
            }
            
            if sDate.matchingStrings(regex: "la próxima semana|en una semana").count != 0 {
                return Calendar.current.date(byAdding: .day, value: 7, to: today)!;
            }
            
            if sDate.matchingStrings(regex: "en \\d+ semanas").count != 0 {
                return Calendar.current.date(byAdding: .day, value: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!*7, to: today)!;
            }
            
            if sDate.matchingStrings(regex: "el próximo mes|en un mes").count != 0 {
                return Calendar.current.date(byAdding: .month, value: 1, to: today)!;
            }
            
            if sDate.matchingStrings(regex: "en \\d+ meses").count != 0 {
                return Calendar.current.date(byAdding: .month, value: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!, to: today)!;
            }
            
            if sDate.matchingStrings(regex: "el próximo año|en un año").count != 0 {
                return Calendar.current.date(byAdding: .year, value: 1, to: today)!;
            }
            
            if sDate.matchingStrings(regex: "en \\d+ años").count != 0 {
                return Calendar.current.date(byAdding: .year, value: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!, to: today)!;
            }
            
            let calendar = Calendar(identifier: .gregorian)
            
            if sDate.matchingStrings(regex: "lunes").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, weekday: 2)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "martes").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, weekday: 3)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "miércoles").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, weekday: 4)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "jueves").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, weekday: 5)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "viernes").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, weekday: 6)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "sábado").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, weekday: 7)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "domingo").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, weekday: 1)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "enero \\d+|\\d+ de enero").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, month: 1, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "febrero \\d+|\\d+ de febrero").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, month: 2, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "marzo \\d+|\\d+ de marzo").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, month: 3, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "abril \\d+|\\d+ de abril").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, month: 4, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "mayo \\d+|\\d+ de mayo").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, month: 5, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "junio \\d+|\\d+ de junio").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, month: 6, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "julio \\d+|\\d+ de julio").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, month: 7, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "agosto \\d+|\\d+ de agosto").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, month: 8, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "septiembre \\d+|\\d+ de septiembre").count != 0{
                let dateComponents = DateComponents(calendar: calendar, month: 9, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "octubre \\d+|\\d+ de octubre").count != 0{
                let dateComponents = DateComponents(calendar: calendar, month: 10, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "noviembre \\d+|\\d+ de noviembre").count != 0{
                let dateComponents = DateComponents(calendar: calendar, month: 11, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "diciembre \\d+|\\d+ de diciembre").count != 0{
                let dateComponents = DateComponents(calendar: calendar, month: 12, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
        }
        
        if(switchEsp == false && switchEng == true){
            if sDate.matchingStrings(regex: "today").count != 0 {
                return today;
            }
            
            if sDate.matchingStrings(regex: "tomorrow|in a day").count != 0 {
                return Calendar.current.date(byAdding: .day, value: 1, to: today)!;
            }
            
            if sDate.matchingStrings(regex: "in \\d+ days").count != 0 {
                return Calendar.current.date(byAdding: .day, value: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!, to: today)!;
            }
            
            if sDate.matchingStrings(regex: "next week|in a week").count != 0 {
                return Calendar.current.date(byAdding: .day, value: 7, to: today)!;
            }
            
            if sDate.matchingStrings(regex: "in \\d+ weeks").count != 0 {
                return Calendar.current.date(byAdding: .day, value: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!*7, to: today)!;
            }
            
            if sDate.matchingStrings(regex: "next month|in a month").count != 0 {
                return Calendar.current.date(byAdding: .month, value: 1, to: today)!;
            }
            
            if sDate.matchingStrings(regex: "in \\d+ months").count != 0 {
                return Calendar.current.date(byAdding: .month, value: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!, to: today)!;
            }
            
            if sDate.matchingStrings(regex: "next year|in a year").count != 0 {
                return Calendar.current.date(byAdding: .year, value: 1, to: today)!;
            }
            
            if sDate.matchingStrings(regex: "in \\d+ years").count != 0 {
                return Calendar.current.date(byAdding: .year, value: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!, to: today)!;
            }
            
            let calendar = Calendar(identifier: .gregorian)
            
            if sDate.matchingStrings(regex: "monday").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, weekday: 2)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "tuesday").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, weekday: 3)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "wednesday").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, weekday: 4)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "thursday").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, weekday: 5)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "friday").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, weekday: 6)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "saturday").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, weekday: 7)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "sunday").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, weekday: 1)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "january \\d+").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, month: 1, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "february \\d+").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, month: 2, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "march \\d+").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, month: 3, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "april \\d+").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, month: 4, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "may \\d+").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, month: 5, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "june \\d+").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, month: 6, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "july \\d+").count != 0 {
                let dateComponents = DateComponents(calendar: calendar, month: 7, day: Int(sDate.matchingStrings(regex: "\\d+")[0][0])!)
                return calendar.nextDate(after: today, matching: dateComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
            }
            
            if sDate.matchingStrings(regex: "august \\d+").count != 0 {
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
