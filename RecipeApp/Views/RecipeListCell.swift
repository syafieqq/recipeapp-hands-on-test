//
//  RecipeListCell.swift
//  RecipeApp
//
//  Created by Megat Syafiq on 17/07/2020.
//  Copyright © 2020 Megat Syafiq. All rights reserved.
//

import UIKit

class RecipeListCell: UITableViewCell {

    static let Identifier = "RecipeListCell"
    
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var foodTitle: UILabel!
    @IBOutlet weak var foodDescription: UILabel!
    
    func configureWithRecipe(recipe: RecipeList) {
        print ("recipe img:", recipe.image)
        if recipe.image != "" {
            foodImage.image = UIImage(named: recipe.image)
        } else {
            foodImage.image = UIImage(data: recipe.img as Data)
        }
        
        foodTitle.text = "\(recipe.name.uppercased())"
        foodDescription.text = recipe.description
    }

}
