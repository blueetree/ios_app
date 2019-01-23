//
//  FirstViewController.swift
//  ladGame1.1
//
//  Created by Jiahuan Li on 1/19/16.
//  Copyright © 2016 Jiahuan Li. All rights reserved.
//

//note
//1.sort the list by rank
//2.additem add rank
import UIKit
import CoreData
class ChecklistViewController: UITableViewController,ItemDetailViewControllerDelegate{
    //countUncheck...?? P207
    let managedObjectContext = (UIApplication.sharedApplication().delegate as!AppDelegate).managedObjectContext
    //fetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("ChecklistItem",inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entity
        let sortDescriptor = NSSortDescriptor(key: "rank", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchBatchSize = 20
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName:nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    //defensive programming
//    deinit {
//        fetchedResultsController.delegate = nil
//    }
    
    
    override func viewDidLoad() {
        //AVObject
        let testObject:AVObject = AVObject(className: "TestObject")
        testObject["foo"] = "bar"
        testObject.save()
        //end
        
        if checkChecklistComplete(){
            getOlder()
        }else{
            regeneration()
        }
        super.viewDidLoad()
        deleteCompleted()
        changeUncompleted()
        performFetch()
    }
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    //1.check checklist complete
    func checkChecklistComplete()->Bool{
        //1.system time
        let date=NSDate()
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "yyyyMMdd"
        let nowTime = timeFormatter.stringFromDate(date) as String
        print(nowTime)
        //end
        //2. lookup all checklistItem dueDate
        let fetchRequest:NSFetchRequest = NSFetchRequest()
        fetchRequest.fetchLimit = 10
        fetchRequest.fetchOffset = 0
        fetchRequest.entity = NSEntityDescription.entityForName("ChecklistItem", inManagedObjectContext: managedObjectContext)
        //        fetchRequest.predicate = NSPredicate(format: "dueDate == %@", nowTime)
        //        print(fetchRequest.predicate)
        fetchRequest.predicate = NSPredicate(format: "checked == %@", false)
        print(fetchRequest.predicate)
        do {
            let fetchedObjects = try managedObjectContext.executeFetchRequest(fetchRequest) as! [ChecklistItem]
            if fetchedObjects.count > 0 {
                for fetchedObject in fetchedObjects {
                    let checkdate = fetchedObject.dueDate
                    let timeFormatter = NSDateFormatter()
                    timeFormatter.dateFormat = "yyyyMMdd"
                    let checkTime = timeFormatter.stringFromDate(checkdate) as String
                    print(checkTime)
                    if checkTime < nowTime{
                        print("uncomplete")
                        return false
                    }else{return true}
                }
            }else {return true}
        }catch {fatalError("could not search：\(error)")}
        return true
    }
    
    //2.create new life
    func regeneration(){
        //1.change alive to false
        let fetchRequest:NSFetchRequest = NSFetchRequest()
        fetchRequest.fetchLimit = 10
        fetchRequest.fetchOffset = 0
        fetchRequest.entity = NSEntityDescription.entityForName("NamelistItem", inManagedObjectContext: managedObjectContext)
        fetchRequest.predicate = NSPredicate(format: "alive == %@",true)
        print(fetchRequest.predicate)
        do {
            let fetchedObjects = try managedObjectContext.executeFetchRequest(fetchRequest) as! [NamelistItem]
            fetchedObjects[0].alive = false
            try self.managedObjectContext.save()
        } catch {
            fatalCoreDataError(error)
        }
        createNewLife()
    }
    func createNewLife(){
        //2.create a new life
        let namelistitem = NSEntityDescription.insertNewObjectForEntityForName( "NamelistItem", inManagedObjectContext: managedObjectContext) as! NamelistItem
        namelistitem.name = "王小明"
        namelistitem.age = 0
        namelistitem.alive = true
        namelistitem.gender = true
        namelistitem.lastTime = NSDate()
        do {
            try managedObjectContext.save()
        } catch {
            fatalCoreDataError(error)
        }
        
    }
    //3.get Older
    func getOlder() {
        //1.system time
        let date=NSDate()
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "dd"
        let nowTime = timeFormatter.stringFromDate(date) as String
        print(nowTime)
        //find alive then add age
        let fetchRequest:NSFetchRequest = NSFetchRequest()
        fetchRequest.fetchLimit = 10
        fetchRequest.fetchOffset = 0
        fetchRequest.entity = NSEntityDescription.entityForName("NamelistItem", inManagedObjectContext: managedObjectContext)
        fetchRequest.predicate = NSPredicate(format: "alive == %@",true)
        print(fetchRequest.predicate)
        do {
            let fetchedObjects = try managedObjectContext.executeFetchRequest(fetchRequest) as! [NamelistItem]
            if fetchedObjects.count > 0 {
                let lastDate = fetchedObjects[0].lastTime
                let timeFormatter = NSDateFormatter()
                timeFormatter.dateFormat = "dd"
                let lastTime = timeFormatter.stringFromDate(lastDate!) as String
                print(lastTime)
                let age = Int(nowTime)! - Int(lastTime)!
                print(age)
                fetchedObjects[0].age = age
                try self.managedObjectContext.save()
            }else {
                print("newlife")
                createNewLife()
            }
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    
    

    
    func deleteCompleted(){
        //1.system time
        let date=NSDate()
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "yyyyMMdd"
        let nowTime = timeFormatter.stringFromDate(date) as String
        print(nowTime)
        //end
        //2. lookup all checklistItem dueDate
        let fetchRequest:NSFetchRequest = NSFetchRequest()
        fetchRequest.fetchLimit = 10
        fetchRequest.fetchOffset = 0
        fetchRequest.entity = NSEntityDescription.entityForName("ChecklistItem", inManagedObjectContext: managedObjectContext)
        fetchRequest.predicate = NSPredicate(format: "checked == %@",true)
        print(fetchRequest.predicate)
        do {
            let fetchedObjects = try managedObjectContext.executeFetchRequest(fetchRequest) as! [ChecklistItem]
            print(fetchedObjects.count)
            if fetchedObjects.count > 0 {
                for fetchedObject in fetchedObjects {
                    let checkdate = fetchedObject.dueDate
                    let timeFormatter = NSDateFormatter()
                    timeFormatter.dateFormat = "yyyyMMdd"
                    let checkTime = timeFormatter.stringFromDate(checkdate) as String
                    print(checkTime)
                    if checkTime < nowTime{
                        managedObjectContext.deleteObject(fetchedObject)
                        do {
                            try managedObjectContext.save()
                        } catch {
                            fatalCoreDataError(error)
                        }
                    }
                }
                
             }
            }catch {
            fatalError("could not search：\(error)")
        }

    }
    
    func changeUncompleted(){
        //1.system time
        let date=NSDate()
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "yyyyMMdd"
        let nowTime = timeFormatter.stringFromDate(date) as String
        print(nowTime)
        //end
        //2. lookup all checklistItem dueDate
        let fetchRequest:NSFetchRequest = NSFetchRequest()
        fetchRequest.fetchLimit = 10
        fetchRequest.fetchOffset = 0
        fetchRequest.entity = NSEntityDescription.entityForName("ChecklistItem", inManagedObjectContext: managedObjectContext)
        fetchRequest.predicate = NSPredicate(format: "checked == %@",false)
        print(fetchRequest.predicate)
        do {
            let fetchedObjects = try managedObjectContext.executeFetchRequest(fetchRequest) as! [ChecklistItem]
            if fetchedObjects.count > 0 {
                for fetchedObject in fetchedObjects {
                    let checkdate = fetchedObject.dueDate
                    print(checkdate)
                    let timeFormatter = NSDateFormatter()
                    timeFormatter.dateFormat = "yyyyMMdd"
                    let checkTime = timeFormatter.stringFromDate(checkdate) as String
                    print(checkTime)
                    print(nowTime)
                    if checkTime < nowTime{
                        fetchedObject.dueDate = NSDate()
                        print(fetchedObject.dueDate)
                        do {
                            try managedObjectContext.save()
                        } catch {
                            fatalCoreDataError(error)
                        }
                    }
                }
                
            }
        }catch {
            fatalError("could not search：\(error)")
        }

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddItem" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! ItemDetailViewController
            controller.managedObjectContext = managedObjectContext
        }else if segue.identifier == "EditItem" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! ItemDetailViewController
            controller.managedObjectContext = managedObjectContext
            controller.delegate = self
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                let item = fetchedResultsController.objectAtIndexPath(indexPath) as! ChecklistItem
                controller.itemToEdit = item
                print(indexPath)
                print(item)

            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        return items.count
        //        section...???
        let sectionInfo = fetchedResultsController.sections![section]
        print(section)
        print(sectionInfo)
        print(sectionInfo.numberOfObjects)
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ChecklistItem", forIndexPath: indexPath)
        
        let item = fetchedResultsController.objectAtIndexPath(indexPath)
        
        configureTextForCell(cell, withChecklistItem: item as! ChecklistItem)
        configureCheckmarkForCell(cell, withChecklistItem: item as! ChecklistItem)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
//            let item = items[indexPath.row]
            let item = fetchedResultsController.objectAtIndexPath(indexPath) as! ChecklistItem
            item.toggleChecked()
            createRewards(indexPath)
            configureCheckmarkForCell(cell, withChecklistItem: item)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        do {
            try managedObjectContext.save()
        } catch {
            fatalCoreDataError(error)
        }

    }
    
    func configureTextForCell(cell: UITableViewCell, withChecklistItem item: ChecklistItem) {
        let label = cell.viewWithTag(1000) as! UILabel
        label.text = item.text
    }
    
    func configureCheckmarkForCell(cell: UITableViewCell, withChecklistItem item: ChecklistItem) {
        let label = cell.viewWithTag(1001) as! UILabel
        if item.checked {
            label.text = "√"
        } else {
            label.text = ""
        }
    }

    //create rewards
    func createRewards(indexPath: NSIndexPath){
        let item = fetchedResultsController.objectAtIndexPath(indexPath) as! ChecklistItem
        let random = item.rank.integerValue + Int(arc4random()%100)
        print(random)
        let rewardnames = ["Photos","Trips","Groceries"]
        if  random > 100{
            let inventoryitem = NSEntityDescription.insertNewObjectForEntityForName( "InventoryItem", inManagedObjectContext: self.managedObjectContext) as! InventoryItem
                inventoryitem.name = rewardnames[1]
                inventoryitem.used = false
                print("--------getin------")
            do {
                try self.managedObjectContext.save()
            } catch {
                fatalCoreDataError(error)
            }

            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
       //Swipe to delete
    override func tableView(tableView: UITableView,
        commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
                let checklistItem = fetchedResultsController.objectAtIndexPath(indexPath) as! ChecklistItem
                managedObjectContext.deleteObject(checklistItem)
                do {
                try managedObjectContext.save()
            } catch {
                    fatalCoreDataError(error)
                }
            }
    }
    
//    ItemDetailViewControllerDelegate
//    func itemDetailViewControllerDidCancel(controller: ItemDetailViewController) {
//        dismissViewControllerAnimated(true, completion: nil)
//    }
    
//    func itemDetailViewController(controller: ItemDetailViewController, didFinishAddingItem item: ChecklistItem) {
////        let sectionInfo = fetchedResultsController.sections![section]
////        return sectionInfo.numberOfObjects
////        let newRowIndex = items.count
////        items.append(item)
////        let indexPath = NSIndexPath(forRow: newRowIndex, inSection: 0)
////        let indexPaths = [indexPath]
////        tableView.insertRowsAtIndexPaths(indexPaths,withRowAnimation: .Automatic)
//        let checklistitem = NSEntityDescription.insertNewObjectForEntityForName( "ChecklistItem", inManagedObjectContext: item) as! ChecklistItem
//        
//        
//        do {
//            try managedObjectContext.save()
//        } catch {
//            fatalCoreDataError(error)
//        }
//        dismissViewControllerAnimated(true, completion: nil)
//    }
    
//    func itemDetailViewController(controller: ItemDetailViewController, didFinishEditingItem item: ChecklistItem) {
    
//        if let index = items.indexOf(item) {
//        let indexPath = NSIndexPath(forRow: index, inSection: 0)
//        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
//        configureTextForCell(cell, withChecklistItem: item)
//         }
//        }
//        
//        //
//        do {
//            try managedObjectContext.save()
//        } catch {
//            fatalCoreDataError(error)
//        }
//        dismissViewControllerAnimated(true, completion: nil)
//    }
    
    
    
    //end
    //Save and Load
//    func documentsDirectory() -> String {
//       let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
//        return paths[0]
//    }
//    
//    func dataFilePath() -> String {
//        return (documentsDirectory() as NSString).stringByAppendingPathComponent("Checklists.plist")
//    }
    
//    func saveChecklistItems() {
//        let data = NSMutableData()
//        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
//        archiver.encodeObject(items, forKey: "ChecklistItems")
//        archiver.finishEncoding()
//        data.writeToFile(dataFilePath(), atomically: true)
//    }
//    
//    func loadChecklistItems() {
//        let path = dataFilePath()
//        if NSFileManager.defaultManager().fileExistsAtPath(path) {
//        if let data = NSData(contentsOfFile: path) {
//        let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
//        items = unarchiver.decodeObjectForKey("ChecklistItems") as! [ChecklistItem]
//        unarchiver.finishDecoding()
//           }
//        }
//    }
    //end
    //count
//    func countUncheckedItems() -> Int {
//         var count = 0
//         for item in items where !item.checked {
//         count += 1
//            }
//        return count
//    }
    
}

//extension delegate
extension ChecklistViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        print("*** controllerWillChangeContent")
        tableView.beginUpdates()
}
    func controller(
            controller: NSFetchedResultsController,
            didChangeObject anObject: AnyObject,
            atIndexPath indexPath: NSIndexPath?,
            forChangeType type: NSFetchedResultsChangeType,
            newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            print("*** NSFetchedResultsChangeInsert (object)")
            tableView.insertRowsAtIndexPaths([newIndexPath!],withRowAnimation:.Fade)
        case .Delete:
            print("*** NSFetchedResultsChangeDelete (object)")
            tableView.deleteRowsAtIndexPaths([indexPath!],withRowAnimation:.Fade)
        case .Update:
            print("*** NSFetchedResultsChangeUpdate (object)")
            if let cell = tableView.cellForRowAtIndexPath(indexPath!){
            let item = controller.objectAtIndexPath(indexPath!) as! ChecklistItem
//            cell.configureForLocation(location)
            configureTextForCell(cell, withChecklistItem: item)
            configureCheckmarkForCell(cell, withChecklistItem: item)
            }

        case .Move:
            print("*** NSFetchedResultsChangeMove (object)")
            tableView.deleteRowsAtIndexPaths([indexPath!],withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
     }
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int,forChangeType type: NSFetchedResultsChangeType) {
            switch type {
            case .Insert:
            print("*** NSFetchedResultsChangeInsert (section)")
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
            print("*** NSFetchedResultsChangeDelete (section)")
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case.Update:
            print("*** NSFetchedResultsChangeUpdate (section)")
            case .Move:
            print("*** NSFetchedResultsChangeMove (section)")
                }
            }
            func controllerDidChangeContent(controller: NSFetchedResultsController) {
            print("*** controllerDidChangeContent")
                tableView.endUpdates()
            }
}








