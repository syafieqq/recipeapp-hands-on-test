//
//  AddRecipeVC.swift
//  RecipeApp
//
//  Created by Megat Syafiq on 17/07/2020.
//  Copyright © 2020 Megat Syafiq. All rights reserved.
//

import UIKit
import CoreData
import Material
import RxCocoa
import RxSwift

class AddRecipeVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var recipeImage: RoundableImageView!
    @IBOutlet weak var recipeNameTextField: UITextField!
    @IBOutlet weak var recipeTypeTextField: UITextField!
    @IBOutlet weak var recipeDescriptionTextView: TextView!
    @IBOutlet weak var recipeIngredientsTextView: TextView!
    @IBOutlet weak var recipeInstructionsTextView: TextView!
    
    let disposeBag = DisposeBag()
    var isSelectedImg = false
    var editMode = false
    var recipeID = 0
    var selectedRecipeType = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecipeTypePickerView(textField: recipeTypeTextField)
        if editMode {
            title = "Edit Recipe"
            retriveRecipe()
        } else {
            title = "Add Recipe"
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    func setupRecipeTypePickerView(textField: UITextField) {
        
        let pickerView = UIPickerView()

        textField.inputView = pickerView
        let recipeType = Observable.of(RecipeType.items)
        recipeType.bind(to: pickerView.rx.itemTitles) { (row, element) in
            return "\(element.name)"
        }
        .disposed(by: disposeBag)
       
        pickerView.selectRow(Int(self.selectedRecipeType) ?? 0, inComponent: 0, animated: true)
        pickerView.rx.itemSelected
            .subscribe { (event) in
                switch event {
                case .next(let selected):

                    let recipeType = RecipeType.items[selected.row]
            
                    textField.text = recipeType.name
                    self.selectedRecipeType = recipeType.id

                default:
                    break
                }
        }
        .disposed(by: disposeBag)
        
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
            
            recipeImage.contentMode = .scaleAspectFill
            recipeImage.clipsToBounds = true
            recipeTypeTextField.text = RecipeType.items[Int(catid) ?? 0].name
            recipeNameTextField.text = name.uppercased()
            recipeDescriptionTextView.text = description
            recipeIngredientsTextView.text = ingredient
            recipeInstructionsTextView.text = step
            self.selectedRecipeType = catid
            
        }
        catch
        {
            print(error)
        }
    }
    
    
    @IBAction func uploadImageDidTapped(_ sender: CustomButton) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (alert:UIAlertAction) in
            
        }
        
        let photoLibrary = UIAlertAction(title: "Photo Library", style: UIAlertAction.Style.default) { (alert: UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = true
                imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }
            
        }
        
        let camera = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default) { (alert: UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                //   imagePicker.allowsEditing = true
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
        sheet.addAction(photoLibrary)
        sheet.addAction(camera)
        sheet.addAction(cancel)
        self.present(sheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            
            recipeImage.contentMode = .scaleAspectFill
            recipeImage.image = selectedImage.flattened
            isSelectedImg = true
            
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion:nil)
    }
    
    @IBAction func submitDidTapped(_ sender: UIButton) {
        if recipeNameTextField.text == "" || recipeTypeTextField.text == "" || recipeDescriptionTextView.text == "" || recipeIngredientsTextView.text == "" || recipeInstructionsTextView.text == "" {
            self.alertUnfullfilForm ()
        } else {
            if editMode {
                self.alertConfirmEditRecipe()
            } else {
                self.alertConfirmAddRecipe()
            }
            
        }
        
    }
    
    func alertConfirmAddRecipe () {
        let alert = UIAlertController(title: "Confirmation", message: "Are you sure you want to add this recipe?", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: {
            UIAlertAction in
            self.addNewRecipe()
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            UIAlertAction in
            
        })
        alert.addAction(cancel)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    func alertConfirmEditRecipe () {
        let alert = UIAlertController(title: "Confirmation", message: "Are you sure you want to edit this recipe?", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: {
            UIAlertAction in
            self.editCurrentRecipe()
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            UIAlertAction in
            
        })
        alert.addAction(cancel)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertUnfullfilForm () {
        let alert = UIAlertController(title: "Warning!", message: "Please fill in all required fields", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: {
            UIAlertAction in
            
        })
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func editCurrentRecipe() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Common.ENTITYNAME)
        fetchRequest.predicate = NSPredicate.init(format: "id==\(recipeID)")
        do
        {
            let obj = try managedContext.fetch(fetchRequest)
            let objectToUpdate = obj[0] as! NSManagedObject

            objectToUpdate.setValue(selectedRecipeType, forKeyPath: "catid")
            objectToUpdate.setValue("\(recipeNameTextField.text ?? "opt")", forKey: "name")
            objectToUpdate.setValue("\(recipeDescriptionTextView.text ?? "opt")", forKey: "rdescription")
            objectToUpdate.setValue("\(recipeIngredientsTextView.text ?? "opt")", forKeyPath: "ingredient")
            objectToUpdate.setValue("\(recipeInstructionsTextView.text ?? "opt")", forKey: "step")
            objectToUpdate.setValue("", forKey: "image")
            objectToUpdate.setValue(recipeImage.image?.pngData(), forKey: "img")
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
    
    func addNewRecipe(){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let userEntity = NSEntityDescription.entity(forEntityName: Common.ENTITYNAME, in: managedContext)!
        let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
        let ud = UserDefaults.standard.integer(forKey: Common.COUNT)
        user.setValue(ud + 1, forKey: "id")
        user.setValue(selectedRecipeType, forKeyPath: "catid")
        user.setValue("\(recipeNameTextField.text ?? "opt")", forKey: "name")
        user.setValue("\(recipeDescriptionTextView.text ?? "opt")", forKey: "rdescription")
        user.setValue("\(recipeIngredientsTextView.text ?? "opt")", forKeyPath: "ingredient")
        user.setValue("\(recipeInstructionsTextView.text ?? "opt")", forKey: "step")
        user.setValue("", forKey: "image")
        user.setValue(recipeImage.image?.pngData(), forKey: "img")
        UserDefaults.standard.set(ud + 1, forKey: Common.COUNT)
        
        do {
            try managedContext.save()
            print ("success save data")
            _ = self.navigationController?.popViewController(animated: true)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
}
extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
    var png: Data? {
        guard let flattened = flattened else { return nil }
        return flattened.pngData()
    }
    var flattened: UIImage? {
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
}

