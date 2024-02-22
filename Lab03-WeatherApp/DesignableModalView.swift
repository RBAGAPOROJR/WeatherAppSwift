//
//  DesignableModalView.swift
//  Lab03-WeatherApp
//
//  Created by RNLD on 2023-11-13.
//

import UIKit

@IBDesignable class DesignableModalView: UIView {
    
    @IBInspectable var cornerRadius  :   CGFloat = 0 {
        
        didSet {
            
            self.layer.cornerRadius = cornerRadius
            
        }
    }

   
}
