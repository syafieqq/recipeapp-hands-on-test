//
//  SegueHandler.swift
//  RecipeApp
//
//  Created by Megat Syafiq on 16/07/2020.
//  Copyright © 2020 Megat Syafiq. All rights reserved.
//

import Foundation
import UIKit

protocol SegueHandler {
  associatedtype SegueIdentifier: RawRepresentable
}

extension SegueHandler //Default implementation...
    where Self: UIViewController, //for view controllers...
    SegueIdentifier.RawValue == String { //who have String segue identifiers.
  func performSegue(withIdentifier identifier: SegueIdentifier, sender: AnyObject? = nil) {
    performSegue(withIdentifier: identifier.rawValue, sender: sender)
  }
  
  func identifier(forSegue segue: UIStoryboardSegue) -> SegueIdentifier {
    guard
      let stringIdentifier = segue.identifier,
      let identifier = SegueIdentifier(rawValue: stringIdentifier)
      else {
        fatalError("Couldn't find identifier for segue!")
    }
    
    return identifier
  }
}
