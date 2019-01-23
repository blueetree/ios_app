//
//  PocketViewController.swift
//  ladGame1.1
//
//  Created by Jiahuan Li on 2/18/16.
//  Copyright © 2016 Jiahuan Li. All rights reserved.
//

import UIKit
import CoreData

class InventoryViewController: UITableViewController {

       let managedObjectContext = (UIApplication.sharedApplication().delegate as!AppDelegate).managedObjectContext
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("InventoryItem",inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entity
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
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
    
    var usedButton: UIButton!
    //button used
    @IBAction func useInventory(sender: AnyObject?) {
//        //问题一
//        //如何将按钮所在行的indexPath传进来？
        let cell = sender!.superview as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let inventoryItem = fetchedResultsController.objectAtIndexPath(indexPath!) as! InventoryItem
        inventoryItem.used = true
        usedButton.enabled = false
        inventoryItem.iconImg = inventoryItem.name
        do {
            try managedObjectContext.save()
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier( "InventoryItem", forIndexPath: indexPath)
//        cell.addSubview(usedButton)

        let item = fetchedResultsController.objectAtIndexPath(indexPath)
        configureTextForCell(cell, withInventoryItem: item as! InventoryItem)
        
//        usedButton.tag = indexPath.row
//        print(usedButton.tag)
        return cell
    }
    
    func configureTextForCell(cell: UITableViewCell, withInventoryItem item: InventoryItem) {
        let name = cell.viewWithTag(1005) as! UILabel
        name.text = item.name
        usedButton = cell.viewWithTag(1004) as! UIButton
        cell.addSubview(usedButton)
        usedButton.enabled = !item.used
    }
}




//extension delegate
extension InventoryViewController: NSFetchedResultsControllerDelegate {
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
                    let item = fetchedResultsController.objectAtIndexPath(indexPath!)
                    configureTextForCell(cell, withInventoryItem: item as! InventoryItem)
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
