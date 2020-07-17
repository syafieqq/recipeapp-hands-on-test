//
//  RegisterVC.swift
//  RecipeApp
//
//  Created by Megat Syafiq on 18/07/2020.
//  Copyright © 2020 Megat Syafiq. All rights reserved.
//

import UIKit
import Alamofire

class RegisterVC: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Register"
    }
    
    @IBAction func signupButtonDidTapped(_ sender: Any) {
        userSignup()
    }
    
    func userSignup () {
        
        let str = "{\"name\":\"\(nameTextField.text ?? "")\",\"email\":\"\(emailTextField.text ?? "")\",\"password\":\"\(passwordTextField.text ?? "")\"}"
        
        let dict = convertToDictionary(text: str)
        AF.request(Config.REGISTER, method: .post, parameters: dict, encoding: JSONEncoding.default ).responseJSON{ (response) in
            switch response.result {
            case .success(let res):
                if let obj = res as? NSDictionary {
                    let success = obj["success"] as? Int
                    
                    if success == 1 {
                        
                        self.alertSuccess()
                        
                        
                    } else {
                        if let msg = obj["message"] as? String {
                            self.alertError(message:msg)
                        }
                    }
                }
            case .failure(let error):
                print (error)
            }
        }
    }
    func alertError (message:String) {
        let alert = UIAlertController(title: "Error", message:message , preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: {
            UIAlertAction in
            
        })
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    func alertSuccess () {
        let alert = UIAlertController(title: "Success", message:"You have successfully registered. Please login!" , preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: {
            UIAlertAction in
            _ = self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
