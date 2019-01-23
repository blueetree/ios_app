//
//  ItemDetailViewController.swift
//  ladGame1.1
//
//  Created by Jiahuan Li on 1/27/16.
//  Copyright © 2016 Jiahuan Li. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol ItemDetailViewControllerDelegate:
class {
//    func itemDetailViewControllerDidCancel(controller: ItemDetailViewController)
//    func itemDetailViewController(controller: ItemDetailViewController, didFinishEditingItem item: ChecklistItem)
}

class ItemDetailViewController: UITableViewController, UITextFieldDelegate{
    //add rank 249...?
//    @IBOutlet weak var rankSelected: UISegmentedControl!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var shouldRemindSwitch: UISwitch!
    @IBOutlet weak var dueDateLabel: UILabel!
    
    @IBOutlet weak var datePickerCell: UITableViewCell!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var slider: UISlider!
    //Core Data
     var managedObjectContext: NSManagedObjectContext!
    //rank
    var rank = 50
    @IBAction func sliderMoved(slider: UISlider) {
        rank = lroundf(slider.value)
    }
    
    //delegate
     weak var delegate: ItemDetailViewControllerDelegate?
    
    //NSDate
    var dueDate = NSDate()
    var datePickerVisible = false
    var itemToEdit: ChecklistItem?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let item = itemToEdit {
            title = "Edit Item"
            textField.text = item.text
            doneBarButton.enabled = true
            shouldRemindSwitch.on = item.shouldRemind
            dueDate = item.dueDate
            rank = Int(item.rank)
            slider.value = Float(item.rank)
        }
        //NSDate
        updateDueDateLabel()
    }
    func updateDueDateLabel() {
        let formatter = NSDateFormatter()
            formatter.dateStyle = .MediumStyle
            formatter.timeStyle = .ShortStyle
            dueDateLabel.text = formatter.stringFromDate(dueDate)
    }
    func showDatePicker() {
        datePickerVisible = true
        let indexPathDateRow = NSIndexPath(forRow: 2, inSection: 1)
        let indexPathDatePicker = NSIndexPath(forRow: 3, inSection: 1)
        if let dateCell = tableView.cellForRowAtIndexPath(indexPathDateRow) {
           dateCell.detailTextLabel!.textColor =  dateCell.detailTextLabel!.tintColor
        }
        tableView.beginUpdates()         
        tableView.insertRowsAtIndexPaths([indexPathDatePicker], withRowAnimation: .Fade)
        tableView.reloadRowsAtIndexPaths([indexPathDateRow],withRowAnimation: .None)
        tableView.endUpdates()
        datePicker.setDate(dueDate, animated: false)
    }
    func hideDatePicker() {
            if datePickerVisible {
            datePickerVisible = false
            let indexPathDateRow = NSIndexPath(forRow: 2, inSection: 1)
            let indexPathDatePicker = NSIndexPath(forRow: 3, inSection: 1)
            if let cell = tableView.cellForRowAtIndexPath(indexPathDateRow) {
            cell.detailTextLabel!.textColor = UIColor(white: 0, alpha: 0.5)
            }
            tableView.beginUpdates()
            tableView.reloadRowsAtIndexPaths([indexPathDateRow],withRowAnimation: .None)
            tableView.deleteRowsAtIndexPaths([indexPathDatePicker],withRowAnimation: .Fade)
            tableView.endUpdates()
            }
    }
    @IBAction func dateChanged(datePicker: UIDatePicker!) {
        dueDate = datePicker.date
        updateDueDateLabel()
    }
    
    @IBAction func shouldRemindToggled(switchControl: UISwitch) {
        textField.resignFirstResponder()
        if switchControl.on {
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert , .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        }
    }
    //end
    
    @IBAction func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func done() {
        //delegate
        if let item = itemToEdit {
//            let fetchRequest:NSFetchRequest = NSFetchRequest()
//            fetchRequest.fetchLimit = 10 //限定查询结果的数量
//            fetchRequest.fetchOffset = 0 //查询的偏移量
//            //设置数据请求的实体结构
//            fetchRequest.entity = NSEntityDescription.entityForName("ChecklistItem", inManagedObjectContext: managedObjectContext)
//            
//            //设置查询条件，条件为nil的时候则返回所有资料
//                fetchRequest.predicate = NSPredicate(format: "text == %@",textField.text!)
//                print(fetchRequest.predicate)
//            //
//            do {
//                let fetchedObjects:[AnyObject]? = try managedObjectContext.executeFetchRequest(fetchRequest)
//                
//                print(fetchedObjects)
//                guard fetchedObjects?.count > 0 else { print("not found in coredata"); return }
//                managedObjectContext.deleteObject(fetchedObjects![0] as! NSManagedObject)
//                let item = NSEntityDescription.insertNewObjectForEntityForName( "ChecklistItem", inManagedObjectContext: managedObjectContext) as! ChecklistItem
                item.text = textField.text!
                item.shouldRemind = shouldRemindSwitch.on
                item.dueDate = dueDate
                item.rank = rank
                item.scheduleNotification()
            do {
                try managedObjectContext.save()
            } catch {
                fatalCoreDataError(error)
            }
//                try managedObjectContext.save()
//            }catch{
//                fatalCoreDataError(error)
//            }
            dismissViewControllerAnimated(true, completion: nil)
            //
            
//            newitem.text = textField.text!
//            newitem.shouldRemind = shouldRemindSwitch.on
//            newitem.dueDate = dueDate
//            newitem.rank = rank
//            newitem.scheduleNotification()
//            delegate?.itemDetailViewController(self, didFinishEditingItem: item)
            

        } else {
            let item = NSEntityDescription.insertNewObjectForEntityForName( "ChecklistItem", inManagedObjectContext: managedObjectContext) as! ChecklistItem
            item.text = textField.text!
            item.checked = false
            item.shouldRemind = shouldRemindSwitch.on
            item.dueDate = dueDate
            item.rank = rank
            item.scheduleNotification()
            do {
               try managedObjectContext.save()
            } catch {
                fatalCoreDataError(error)
            }
            dismissViewControllerAnimated(true, completion: nil)
        }
//func
//        let item = NSEntityDescription.insertNewObjectForEntityForName( "ChecklistItem", inManagedObjectContext: managedObjectContext) as! ChecklistItem
    }
    
//    //查询：
//    func findAll()-> NSMutableArray {
//        println(self.applicationDocumentsDirectory.description)
//        let cxt = self.managedObjectContext
//        let entityDescription = NSEntityDescription.entityForName("Student", inManagedObjectContext:cxt!)
//        let request = NSFetchRequest()
//        request.entity = entityDescription
//        var error: NSError? = nil
//        var listData:[AnyObject]? = cxt?.executeFetchRequest(request, error: &error)
//        var resListData: NSMutableArray = NSMutableArray()
//        for data in listData as! [StudentManagedObject] {
//            var model = StudentModel()
//            model.name = data.name
//            model.date = data.date
//            resListData.addObject(model)
//        }
//        return resListData
//    }
//    //新增：
//    func insert(student: StudentModel){
//        let cxt = self.managedObjectContext
//        let entity = NSEntityDescription.insertNewObjectForEntityForName("Student", inManagedObjectContext: cxt!) as! StudentManagedObject         entity.name = student.name!
//            entity.date = NSDate()
//        var error: NSError? = nil
//        if (self.managedObjectContext?.save(&error) != nil) {
//            print("插入成功")
//        }else{
//            print("插入失败")
//        }
//    }
//    //删除：
//    func remove(student:StudentModel){
//        //eg
//        let ctx = self.managedObjectContext
//        let entityDescription = NSEntityDescription.entityForName("Student", inManagedObjectContext: ctx!)
//        let request = NSFetchRequest()
//        request.entity = entityDescription
//        request.predicate = NSPredicate(format: "date == %@", student.date!)
//        var error: NSError? = nil
//        let listData:[AnyObject]? = ctx?.executeFetchRequest(request, error: &error)
//        for data in listData as! [StudentManagedObject] {
//            ctx?.deleteObject(data)
//            var savingError: NSError? = nil
//            if ctx?.save(&savingError) != nil {
//                println("删除成功")
//            }else{
//                println("删除失败")
//            }
//        }
//        //real
//        override func tableView(tableView: UITableView,
//            commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//                if editingStyle == .Delete {
//                    let checklistItem = fetchedResultsController.objectAtIndexPath(indexPath) as! ChecklistItem
//                    managedObjectContext.deleteObject(checklistItem)
//                    do {
//                        try managedObjectContext.save()
//                    } catch {
//                        fatalCoreDataError(error)
//                    }
//                }
//        }
//
//    }
//    //修改：
//    func modify(student:StudentModel){
//        let ctx = self.managedObjectContext
//        let entityDescription = NSEntityDescription.entityForName("Student", inManagedObjectContext: ctx!)
//        let request = NSFetchRequest()
//        request.entity = entityDescription
//        request.predicate = NSPredicate(format: "date == %@", student.date!)
//        var error: NSError? = nil
//        let listData:[AnyObject]? = ctx?.executeFetchRequest(request, error: &error)
//        for data in listData as! [StudentManagedObject] {
//            data.name = student.name!
//            var savingError: NSError? = nil
//            if ctx?.save(&savingError) != nil {
//                println("修改成功")
//            }else{
//                println("修改失败")
//            }
//        }
//    }
//    最后，通过调用sharedDao返回唯一实例。
//    private let sharedInstance = StudentDao()
//    class StudentDao: BaseDao {
//        class var sharedDao : StudentDao {
//            return sharedInstance
//        }  ...... }
//    

    
    
//    weak var delegate: ItemDetailViewControllerDelegate?
    
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
            if indexPath.section == 1 && indexPath.row == 2 {
                return indexPath
            } else {
                return nil
            }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
    
    //data picker
    override func tableView(tableView: UITableView,cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 1 && indexPath.row == 3 {
        return datePickerCell
    } else {
        return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 && datePickerVisible {
            return 4
    } else {
        return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    override func tableView(tableView: UITableView,heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 3 {
        return 217
    } else {
        return super.tableView(tableView,heightForRowAtIndexPath: indexPath)
        }
    }
    override func tableView(tableView: UITableView,didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        textField.resignFirstResponder()
        if indexPath.section == 1 && indexPath.row == 2 {
        if !datePickerVisible {
        showDatePicker()
        }else{
        hideDatePicker()
        }
    }
}
    func textFieldDidBeginEditing(textField: UITextField) {
        hideDatePicker()
    }
    override func tableView(tableView: UITableView, var indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        if indexPath.section == 1 && indexPath.row == 3 {
        indexPath = NSIndexPath(forRow: 0, inSection: indexPath.section)
        }
        return super.tableView(tableView,indentationLevelForRowAtIndexPath: indexPath)
    }
    
    //end

func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
        replacementString string: String) -> Bool {
        let oldText: NSString = textField.text!
        let newText: NSString = oldText.stringByReplacingCharactersInRange(range, withString: string)
        doneBarButton.enabled = (newText.length > 0)
        return true
}
    
}