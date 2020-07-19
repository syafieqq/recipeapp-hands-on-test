//
//  CustomImage.swift
//  tolc
//
//  Created by Megat Syafiq on 06/09/2018.
//  Copyright © 2018 Megat. All rights reserved.
//

import Foundation
import UIKit



@IBDesignable
class RoundableImageView: UIImageView {
    
    @IBInspectable var cornerRadius : CGFloat = 0.0{
        didSet{
            self.applyCornerRadius()
        }
    }
    
    @IBInspectable var borderColor3 : UIColor = UIColor.clear{
        didSet{
            self.applyCornerRadius()
        }
    }
    
    @IBInspectable var borderWidth : Double = 0{
        didSet{
            self.applyCornerRadius()
        }
    }
    
    @IBInspectable var circular : Bool = false{
        didSet{
            self.applyCornerRadius()
        }
    }
    
    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 1
    @IBInspectable var shadowColorr: UIColor? = UIColor.black
    @IBInspectable var shadowOpacity: Float = 0.1
    func applyCornerRadius()
    {
        if(self.circular) {
            self.layer.cornerRadius = self.bounds.size.height/2
            self.layer.masksToBounds = true
            self.layer.borderColor = self.borderColor3.cgColor
            self.layer.borderWidth = CGFloat(self.borderWidth)
            self.layer.shadowColor = UIColor.black.cgColor
             self.layer.shadowOffset = CGSize(width: 0, height: 0)
             self.layer.shadowOpacity = 0.5
             self.layer.shadowRadius = 5
             self.clipsToBounds = false

        }else {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
            self.layer.borderColor = self.borderColor3.cgColor
            self.layer.borderWidth = CGFloat(self.borderWidth)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyCornerRadius()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyCornerRadius()
    }
    
}

@IBDesignable class TintColoredImageView: UIImageView {
    
    override var image: UIImage? {
        didSet {
            let _tintColor = self.tintColor
            self.tintColor = nil
            self.tintColor = _tintColor
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        initialize()
    }
    
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        initialize()
    }
    
    func initialize() {
        let _tintColor = self.tintColor
        self.tintColor = nil
        self.tintColor = _tintColor
    }
    
}
