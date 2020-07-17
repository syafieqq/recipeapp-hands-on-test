//
//  Model.swift
//  RecipeApp
//
//  Created by Megat Syafiq on 16/07/2020.
//  Copyright © 2020 Megat Syafiq. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
//protocol RecipeListPresentable {
//    var searchValue: Variable<String> { get }
//}

struct RecipeType {
    let id: String
    let name: String
    static var items = [RecipeType]()
}

struct RecipeList {
    
    let id: Int
    let catid: String
    let name: String
    let description: String
    let ingredient: String
    let step: String
    let image: String
    let img: NSData
    //static var dataSource = BehaviorRelay(value: [RecipeList]())
    static var items = [RecipeList]()
}

