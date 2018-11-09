//
//  ResultViewController.swift
//  Sudoku
//
//  Created by David Kalajdzic
//  Copyright © 2018 David Kalajdzic. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
	
	
	
	@IBOutlet weak var myCollectionView: UICollectionView!
	
    @IBOutlet weak var intelliGenHintButton: UIButton!
    
    var answerImage: UIImage!
	static var wholeData:WholeData?
	
	@IBAction func exit(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func randomHintClicked(_ sender: Any) {
		if ResultViewController.wholeData?.unknownNumbers?.count != 0{
			let number = Int.random(in: 0 ..< (ResultViewController.wholeData?.unknownNumbers!.count)!)
			let cell:Cell = (ResultViewController.wholeData?.unknownNumbers![number])!
            programmaticallyClick(cell: cell)
		}
	}
	
	@IBAction func intelligentHintClicked(_ sender: Any) {
        let cell:Cell = (ResultViewController.wholeData?.intelligentHint)!
        programmaticallyClick(cell: cell)
        intelliGenHintButton.isEnabled = false
	}
	
    fileprivate func programmaticallyClick(cell: Cell){
        let indexPath: Int = cell.row*9+cell.col
        // the two next lines copied from https://stackoverflow.com/a/45412980
        myCollectionView.selectItem(at: IndexPath(index: indexPath), animated: true, scrollPosition: UICollectionView.ScrollPosition.top)
        self.collectionView(myCollectionView, didSelectItemAt: IndexPath(item: indexPath, section: 0))
        ResultViewController.wholeData?.convertToKnown(cell: cell)
    }
    
	override func viewDidLoad() {
		super.viewDidLoad()
		
		myCollectionView.isPrefetchingEnabled = false
		myCollectionView.delegate = self
		myCollectionView.dataSource = self
		
		answerImage = ResultViewController.wholeData?.getUIImage()
		
	}
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let collectionViewCell = collectionView.cellForItem(at: indexPath) as! MyCollectionViewCell
		if (!collectionViewCell.isDisplayed!){
			collectionViewCell.displayAnswer()
			ResultViewController.wholeData?.convertToKnown(cell: indexPathToCell(index: indexPath.item))
		}
	}
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 81
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let collectionViewCell:MyCollectionViewCell = myCollectionView.dequeueReusableCell(withReuseIdentifier: "cellidentifier", for: indexPath) as! MyCollectionViewCell
		let cell: Cell = indexPathToCell(index: indexPath.item)
		collectionViewCell.cell = cell
		collectionViewCell.realImage = self.answerImage.crop(rect: CGRect(x: cell.col*100, y: cell.row*100, width: 100, height: 100))
		if (ResultViewController.wholeData?.isKnown(cell: cell))! {
			collectionViewCell.displayAnswer()
		} else {
			collectionViewCell.hideAnswer()
		}
		return collectionViewCell
		
	}
	
	func indexPathToCell(index: Int) -> Cell {
		let row = index/9
		let col = index%9
		return Cell(row: row, col: col)
	}
}


extension UIImage { // PIECE OF CODE COPIED FROM "https://stackoverflow.com/a/30403863"
	func crop( rect: CGRect) -> UIImage {
		var rect = rect
		rect.origin.x *= self.scale
		rect.origin.y *= self.scale
		rect.size.width *= self.scale
		rect.size.height *= self.scale
		
		let imageRef = self.cgImage!.cropping(to: rect)
		let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
		return image
	}
}
