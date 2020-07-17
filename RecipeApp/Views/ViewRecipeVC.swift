//
//  ViewRecipeVC.swift
//  RecipeApp
//
//  Created by Megat Syafiq on 17/07/2020.
//  Copyright © 2020 Megat Syafiq. All rights reserved.
//

import UIKit
import CoreData

class ViewRecipeVC: UIViewController {
    
    var recipeID = 0
    
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeCategoryLabel: UILabel!
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var recipeDescriptionLabel: UILabel!
    @IBOutlet weak var recipeIngredientsLabel: UILabel!
    @IBOutlet weak var recipeInstructionsLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.retriveRecipe()
    }
    
    @IBAction func deleteDidTapped(_ sender: UIBarButtonItem) {
        self.alertConfirmDeleteRecipe()
    }
    
    @IBAction func editDidTapped(_ sender: UIBarButtonItem) {
        if UserDefaults.standard.string(forKey: Common.TOKEN) != nil {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "AddRecipeVC") as! AddRecipeVC
            newViewController.recipeID = recipeID
            newViewController.editMode = true
            newViewController.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(newViewController, animated: true)
        } else {
            self.alertCustom(title: "No Login Session", message: "Please login to edit the data")
        }

    }
    
    func alertCustom (title: String, message:String) {
        let alert = UIAlertController(title: title, message:message , preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: {
            UIAlertAction in
            let defaults = UserDefaults.standard
            let dictionary = defaults.dictionaryRepresentation()
            dictionary.keys.forEach { key in
                defaults.removeObject(forKey: Common.TOKEN)
            }
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "MainNVC") as! MainNavigationVC
            newViewController.modalPresentationStyle = .fullScreen
            self.present(newViewController, animated: true, completion: nil)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler:nil)
        alert.addAction(action)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func retriveRecipe() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Common.ENTITYNAME)
        fetchRequest.predicate = NSPredicate.init(format: "id==\(recipeID)")
        do
        {
            
            let data = try managedContext.fetch(fetchRequest)
            let catid = (data[0] as AnyObject).value(forKey: "catid") as? String ?? "1"
            let name = (data[0] as AnyObject).value(forKey: "name") as! String
            let description = (data[0] as AnyObject).value(forKey: "rdescription") as! String
            let ingredient = (data[0] as AnyObject).value(forKey: "ingredient") as! String
            let step = (data[0] as AnyObject).value(forKey: "step") as! String
            let img = (data[0] as AnyObject).value(forKey: "img") as? NSData
            let image = (data[0] as AnyObject).value(forKey: "image") as? String
        
            if image != "" {
                recipeImage.image = UIImage(named: image ?? "")
            } else {
                recipeImage.image = UIImage(data: img! as Data)
            }
            
            
            recipeImage.clipsToBounds = true
            recipeCategoryLabel.text = RecipeType.items[Int(catid) ?? 0].name
            recipeNameLabel.text = name.uppercased()
            recipeDescriptionLabel.text = description
            recipeIngredientsLabel.text = ingredient
            recipeInstructionsLabel.text = step
            
        }
        catch
        {
            print(error)
        }
    }
    
    func deleteRecipe(){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Common.ENTITYNAME)
        fetchRequest.predicate = NSPredicate.init(format: "id==\(recipeID)")
        do
        {
            let test = try managedContext.fetch(fetchRequest)
            let objectToDelete = test[0] as! NSManagedObject
            managedContext.delete(objectToDelete)
            do{
                try managedContext.save()
                _ = self.navigationController?.popViewController(animated: true)
            }
            catch
            {
                print(error)
            }
        }
        catch
        {
            print(error)
        }
    }
    
    func alertConfirmDeleteRecipe () {
        let alert = UIAlertController(title: "Confirmation", message: "Are you sure you want to delete this recipe? You cannot undo this action.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: {
            UIAlertAction in
            self.deleteRecipe()
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            UIAlertAction in
            
        })
        alert.addAction(cancel)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
}
