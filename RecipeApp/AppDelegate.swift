//
//  AppDelegate.swift
//  RecipeApp
//
//  Created by Megat Syafiq on 16/07/2020.
//  Copyright © 2020 Megat Syafiq. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        if UserDefaults.standard.integer(forKey: Common.COUNT) == 0 {
            getBookList(fileName: "recipelistinitial")
        }
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "RecipeApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func getBookList(fileName:String) {
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? NSArray {
                
                    for data in jsonResult {
                        if let obj = data as? NSDictionary {
                            let id = obj["id"] as? Int
                            let catid = obj["catid"] as? String
                            let name = obj["name"] as? String
                            let description = obj["description"] as? String
                            let ingredient = obj["ingredient"] as? String
                            let step = obj["step"] as? String
                            let image = obj["image"] as? String
                           // let img = obj["img"] as? String
                            
                            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                            
                            let managedContext = appDelegate.persistentContainer.viewContext
                            let userEntity = NSEntityDescription.entity(forEntityName: Common.ENTITYNAME, in: managedContext)!
                            let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
//                            let ud = UserDefaults.standard.integer(forKey: Common.COUNT)
                            user.setValue(id, forKey: "id")
                            user.setValue(catid, forKeyPath: "catid")
                            user.setValue("\(name ?? "opt")", forKey: "name")
                            user.setValue("\(description ?? "opt")", forKey: "rdescription")
                            user.setValue("\(ingredient ?? "opt")", forKeyPath: "ingredient")
                            user.setValue("\(step ?? "opt")", forKey: "step")
                            user.setValue(image ?? "1", forKey: "image")
                            UserDefaults.standard.set(id, forKey: Common.COUNT)
                            
                            do {
                                try managedContext.save()
                                print ("success save data")

                            } catch let error as NSError {
                                print("Could not save. \(error), \(error.userInfo)")
                            }
                            
                        }
                        
                    }
                    print(jsonResult)
                }
            } catch {
                
            }
        }
    }
    
}

