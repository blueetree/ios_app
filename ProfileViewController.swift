//
//  SecondViewController.swift
//  ladGame1.1
//
//  Created by Jiahuan Li on 1/19/16.
//  Copyright © 2016 Jiahuan Li. All rights reserved.
//

import UIKit
import CoreData

class ProfileViewController: UIViewController {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var gender: UILabel!
    
    @IBOutlet weak var share: UIButton!
    
    @IBOutlet weak var icon: UIImageView!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as!AppDelegate).managedObjectContext
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
//        fetchedResultsController.delegate = HistoryViewController
        return fetchedResultsController
    }()
    

    @IBAction func share(sender: UIButton) {
        let shareParames = NSMutableDictionary()
        
        shareParames.SSDKSetupShareParamsByText("分享内容",
            images : UIImage(named: "shareImg.png"),
            url : NSURL(string:"http://mob.com"),
            title : "分享标题",
            type : SSDKContentType.Auto)
        
        //2.进行分享
        ShareSDK.share(SSDKPlatformType.TypeSinaWeibo, parameters: shareParames) {
            (state : SSDKResponseState, userData : [NSObject : AnyObject]!, contentEntity :SSDKContentEntity!, error : NSError!) -> Void in
            
            switch state{
                
            case SSDKResponseState.Success:
                print("分享成功")
                let alert = UIAlertView(title: "分享成功", message: "分享成功", delegate: self, cancelButtonTitle: "取消")
                alert.show()
            case SSDKResponseState.Fail:    print("分享失败,错误描述:\(error)")
            case SSDKResponseState.Cancel:  print("分享取消")
                
            default:
                break
            }
        }
    }
    
    override func viewDidLoad() {
        
        let fetchRequest:NSFetchRequest = NSFetchRequest()
        fetchRequest.fetchLimit = 10
        fetchRequest.fetchOffset = 0
        fetchRequest.entity = NSEntityDescription.entityForName("NamelistItem", inManagedObjectContext: managedObjectContext)
        fetchRequest.predicate = NSPredicate(format: "alive == %@",true)
        print(fetchRequest.predicate)
        do {
            let fetchedObjects = try managedObjectContext.executeFetchRequest(fetchRequest) as! [NamelistItem]
            name.text = String(fetchedObjects[0].name)
            age.text = String(fetchedObjects[0].age)
            icon.image = UIImage(named: fetchedObjects[0].iconImg!)
            if fetchedObjects[0].gender{
                gender.text = "女"
            }else{
                gender.text = "男"
            }
            
        } catch {
            fatalCoreDataError(error)
        }

        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
     override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}





