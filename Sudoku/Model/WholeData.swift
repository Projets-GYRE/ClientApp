//
//  WholeData.swift
//  Sudoku
//
//  Created by David Kalajdzic
//  Copyright © 2018 David Kalajdzic. All rights reserved.
//

import Foundation
import UIKit

class WholeData:NSObject{
	var fullyResolvedImage: String?
	var knownNumbers:[Cell]?
	var unknownNumbers:[Cell]?
    var intelligentHint:Cell?
	
    init(fullyResolvedImage:String, defaultNumbers:[Cell], intelligentHint:Cell) {
		super.init()
		self.fullyResolvedImage = fullyResolvedImage
		self.knownNumbers = defaultNumbers
		self.unknownNumbers = []
        self.intelligentHint = intelligentHint
		
		initUnknownNumbers()
	}
	
	fileprivate func initUnknownNumbers() {
		for i in 0...80 {
			let row = i/9
			let col = i%9
			if !isKnown(row: row, col: col){
				unknownNumbers?.append(Cell(row: row, col: col))
			}
		}
	}
	
	func convertToKnown(cell: Cell){
		if unknownNumbers?.count == 0{
			return
		}
		for i in  0..<unknownNumbers!.count {
			let c = unknownNumbers![i]
			if c.col == cell.col && c.row == cell.row{
				unknownNumbers?.remove(at: i)
				knownNumbers?.append(cell)
				return
			}
		}
	}
	
	func isKnown(cell: Cell) -> Bool{
		return isKnown(row: cell.row, col: cell.col)
	}
	
	func isKnown(row:Int, col:Int) -> Bool{
		for cell in (self.knownNumbers!){
			if cell.row == row && cell.col == col{
				return true
			}
		}
		return false
	}
	
	func getUIImage() -> UIImage{
		let dataDecoded : Data = Data(base64Encoded: fullyResolvedImage!, options: .ignoreUnknownCharacters)!
		return UIImage(data: dataDecoded)!
	}
	
}


