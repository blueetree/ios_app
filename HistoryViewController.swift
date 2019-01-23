//
//  HistoryViewController.swift
//  ladGame1.1
//
//  Created by Jiahuan Li on 2/7/16.
//  Copyright © 2016 Jiahuan Li. All rights reserved.
//
import UIKit
import CoreData

class HistoryViewController: UITableViewController {
    

    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    //fetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("NamelistItem",inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entity
        let sortDescriptor = NSSortDescriptor(key: "age", ascending: true)
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
    deinit {
        fetchedResultsController.delegate = nil
    }

        
    override func viewDidLoad() {
        super.viewDidLoad()
        performFetch()
    }
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalCoreDataError(error)
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("NamelistItem", forIndexPath: indexPath)
        
        let item = fetchedResultsController.objectAtIndexPath(indexPath)
        
        configureTextForCell(cell, withNamelistItem: item as! NamelistItem)

        
        return cell
    }
    
    func configureTextForCell(cell: UITableViewCell, withNamelistItem namelistitem: NamelistItem) {
        let name = cell.viewWithTag(1002) as! UILabel
        name.text = namelistitem.name
        let age = cell.viewWithTag(1003) as! UILabel
        age.text = String(namelistitem.age)
    
    }
    //Swipe to delete
    override func tableView(tableView: UITableView,
        commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
            if editingStyle == .Delete {
                let namelistItem = fetchedResultsController.objectAtIndexPath(indexPath) as! NamelistItem
                managedObjectContext.deleteObject(namelistItem)
                do {
                    try managedObjectContext.save()
                } catch {
                    fatalCoreDataError(error)
                }
            }
    }
}
//extension delegate
extension HistoryViewController: NSFetchedResultsControllerDelegate {
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
                    let item = controller.objectAtIndexPath(indexPath!) as! NamelistItem
                    configureTextForCell(cell, withNamelistItem: item)
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

