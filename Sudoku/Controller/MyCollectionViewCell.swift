//
//  MyCollectionViewCell.swift
//  Sudoku
//
//  Created by David Kalajdzic
//  Copyright © 2018 David Kalajdzic. All rights reserved.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {
    
	@IBOutlet weak var imageDisplayed: UIImageView!
	
	var isDisplayed:Bool?
	var realImage:UIImage?
	var cell:Cell?
	
	func displayAnswer(){
		imageDisplayed.image = realImage
		isDisplayed = true
	}
	
	func hideAnswer(){
		imageDisplayed.image = nil
		imageDisplayed.backgroundColor = UIColor.lightGray
		isDisplayed = false
	}
	
}
