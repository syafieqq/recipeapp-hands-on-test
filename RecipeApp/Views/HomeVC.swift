//
//  HomeVC.swift
//  RecipeApp
//
//  Created by Megat Syafiq on 16/07/2020.
//  Copyright © 2020 Megat Syafiq. All rights reserved.
//

import UIKit
import Alamofire
import SWXMLHash
import RxSwift
import RxCocoa
import CoreData

class HomeVC: UIViewController {
    
    let disposeBag = DisposeBag()
    var selectedRecipeType = "0"
    var isFilter = false
    var filterRecipeList = [RecipeList]()
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var recipeTypeTexField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Helper.helper.navigationConfig(title: "Home", vc: self, barColor: Common.BASECOLOR, titleColor: .white)
        createToolbar(pickername: recipeTypeTexField)
        getRecipeType()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getRecipeList()
    }
    
    @IBAction func logoutButtonDidTappped(_ sender: UIBarButtonItem) {
        if UserDefaults.standard.string(forKey: Common.TOKEN) != nil {
            self.alertCustom(title: "Logout", message: "Are sure you want to logout?")
        } else {
            self.alertCustom(title: "No Login Session", message: "Please login")
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
    
    func getRecipeList() {
        RecipeList.items.removeAll()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Common.ENTITYNAME)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                let id = data.value(forKey: "id") as! Int
                let catid = data.value(forKey: "catid") as? String ?? "1"
                let name = data.value(forKey: "name") as! String
                let description = data.value(forKey: "rdescription") as! String
                let ingredient = data.value(forKey: "ingredient") as! String
                let step = data.value(forKey: "step") as! String
                let image = data.value(forKey: "image") as! String
                let img = data.value(forKey: "img") as? NSData
                
                let opt = "opt"
                let recipe = RecipeList(id: id, catid: catid, name: name, description: description, ingredient: ingredient, step: step, image: image, img: img ?? opt.data(using: String.Encoding.utf8)! as NSData)
                RecipeList.items.append(recipe)
            }
            self.tableView.reloadData()
        } catch {
            
            
        }
    }
    
    func toObservable<T>(fileName:String) -> Observable<T> {
        return Observable.create {
            observer -> Disposable in
            
            RecipeType.items.append(RecipeType(id:"0", name: "Select Category"))
            if let path = Bundle.main.path(forResource: fileName, ofType: "xml") {
                
                AF.request(URL(fileURLWithPath: path), method: .get, parameters: nil, encoding: URLEncoding.default).responseString { (response) in
                    
                    switch response.result {
                    case .success(let res):
                        let xml = SWXMLHash.parse(res)
                        for element in xml["recipe_types"]["type"].all {
                            guard let id = element["id"].element?.text else {
                                return
                            }
                            guard let name = element["name"].element?.text else {
                                return
                            }
                            let data = RecipeType(id: id, name: name)
                            RecipeType.items.append(data)
                            
                        }
                        self.setupRecipeTypePickerView(textField: self.recipeTypeTexField)
                        
                    case .failure(let error):
                        print (error)
                        
                    }
                }
                observer.onCompleted()
            }
            return Disposables.create()
        }
        
    }
    func getRecipeType() {
        
        toObservable(fileName: "recipetypes")
            .debug("Alamofire.request")
            .subscribe(onNext: {
                print("onNext")
            }, onCompleted: {
                print("onCompelete")
            }, onDisposed: nil)
            .disposed(by: disposeBag)
        
    }
    
}

//MARK: Rx Setup
private extension HomeVC {
    
    func setupRecipeTypePickerView(textField: UITextField) {
        
        let pickerView = UIPickerView()
        pickerView.selectRow(Int(self.selectedRecipeType) ?? 0, inComponent: 0, animated: false)
        textField.inputView = pickerView
        
        let recipeType = Observable.of(RecipeType.items)
        recipeType.bind(to: pickerView.rx.itemTitles) { (row, element) in
            return "\(element.name)"
        }
        .disposed(by: disposeBag)
        
        pickerView.rx.itemSelected
            .subscribe(onNext: { (row, value) in
    
                row == 0 ? (self.isFilter = false) : (self.isFilter = true)
                
                let recipeType = RecipeType.items[row]
                textField.text = recipeType.name
                
                self.selectedRecipeType = recipeType.id
                
                self.filterRecipeList = RecipeList.items.filter( {$0.catid == recipeType.id})
                
                self.tableView.reloadData()
                
                
            })
            .disposed(by: disposeBag)
    }
    
    func setupCellConfiguration() {
        
        let recipeList = Observable.just(RecipeList.items)
        recipeList
            .bind(to: tableView
                .rx
                .items(cellIdentifier: RecipeListCell.Identifier,
                       cellType: RecipeListCell.self)) { row, recipe, cell in
                        cell.configureWithRecipe(recipe: recipe)
        }
        .disposed(by: disposeBag)
    }
    
    func setupCellTapHandling() {
        tableView.rx.modelSelected(RecipeList.self).subscribe(onNext: { [unowned self] recipe in
            
            if let selectedRowIndexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: selectedRowIndexPath, animated: true)
                
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "ViewRecipeVC") as! ViewRecipeVC
                newViewController.recipeID = recipe.id
                newViewController.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(newViewController, animated: true)
            }
        }).disposed(by: disposeBag)
    }
}

// MARK: - SegueHandler
extension HomeVC: SegueHandler {
    enum SegueIdentifier: String {
        case goToAddRecipe
    }
}

// MARK: - Custom PickerView Toolbar
extension HomeVC {
    
    func createToolbar(pickername: UITextField) {
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        toolBar.barTintColor = Common.BASECOLOR
        toolBar.tintColor = .white
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissKeyboard))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        pickername.inputAccessoryView = toolBar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}


extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFilter {
            return self.filterRecipeList.count
        } else {
            return RecipeList.items.count
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isFilter {
            let data =  self.filterRecipeList[indexPath.row]
            
            let cell = (tableView.dequeueReusableCell(withIdentifier: "RecipeListCell") as? RecipeListCell)
            cell?.configureWithRecipe(recipe: data)
            
            return cell!
        } else {
            let data = RecipeList.items[indexPath.row]
            
            let cell = (tableView.dequeueReusableCell(withIdentifier: "RecipeListCell") as? RecipeListCell)
            cell?.configureWithRecipe(recipe: data)
            
            return cell!
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFilter {
            let data = self.filterRecipeList[indexPath.row]
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "ViewRecipeVC") as! ViewRecipeVC
            newViewController.recipeID = data.id
            newViewController.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(newViewController, animated: true)
        } else {
            let data = RecipeList.items[indexPath.row]
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "ViewRecipeVC") as! ViewRecipeVC
            newViewController.recipeID = data.id
            newViewController.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(newViewController, animated: true)
        }
        
    }
    
    
}
