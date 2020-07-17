//
//  LoginVC.swift
//  RecipeApp
//
//  Created by Megat Syafiq on 18/07/2020.
//  Copyright © 2020 Megat Syafiq. All rights reserved.
//

import UIKit
import Alamofire

class LoginVC: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBAction func loginButtonDidTapped(_ sender: Any) {
        userLogin()
    }
    
    func userLogin() {
        
        let str = "{\"email\":\"\(emailTextField.text ?? "")\",\"password\":\"\(passwordTextField.text ?? "")\"}"
        
        let dict = convertToDictionary(text: str)
        AF.request(Config.LOGIN, method: .post, parameters: dict, encoding: JSONEncoding.default ).responseJSON{ (response) in
            switch response.result {
            case .success(let res):
                if let obj = res as? NSDictionary {
                    let success = obj["success"] as? Int
                    
                    if success == 1 {
                        
                        if (obj["token"] as? String) != nil {
                            UserDefaults.standard.set(success, forKey: Common.TOKEN)
                            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let newViewController = storyBoard.instantiateViewController(withIdentifier: "MainNavigationVC") as! MainNavigationVC
                            newViewController.modalPresentationStyle = .fullScreen
                            self.present(newViewController, animated: true, completion: nil)
                        }
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
    
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.string(forKey:Common.TOKEN) != nil {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "MainNavigationVC") as! MainNavigationVC
            newViewController.modalPresentationStyle = .fullScreen
            self.present(newViewController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Helper.helper.navigationConfig(title: "Login", vc: self, barColor: Common.BASECOLOR, titleColor: .white)
    }
    
    
}

func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}
