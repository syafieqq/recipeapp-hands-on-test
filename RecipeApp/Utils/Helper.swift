//
//  Helper.swift
//  RecipeApp
//
//  Created by Megat Syafiq on 16/07/2020.
//  Copyright © 2020 Megat Syafiq. All rights reserved.
//

import Foundation
import UIKit
class Helper {
    
    
    static let helper = Helper()
    
    
    func navigationConfig(title: String, vc: UIViewController, barColor: UIColor, titleColor: UIColor) {
        vc.navigationItem.title = title
        vc.navigationController?.navigationBar.tintColor = .white
        vc.navigationController?.navigationBar.barTintColor = barColor
        // Navigation Bar Text:
        vc.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: titleColor]
    }
    
}
