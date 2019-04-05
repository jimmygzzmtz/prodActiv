//
//  CollectionViewCell.swift
//  prodActiv
//
//  Created by Jaime Alberto Gonzalez on 3/22/19.
//  Copyright © 2019 Jaime Alberto Gonzalez. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var btDelete: UIButton!
    @IBOutlet weak var btDone: UIButton!
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbTime: UILabel!
    
<<<<<<< HEAD
=======
    var swipeGesture: UIPanGestureRecognizer!
    var originalPoint: CGPoint!
    
    func setupSwipeGesture() {
        swipeGesture = UIPanGestureRecognizer(target: self, action:#selector(swiped))
        self.addGestureRecognizer(swipeGesture)
    }
    
    @objc func swiped(_ gestureRecognizer: UIPanGestureRecognizer) {
        if (btDone.isHidden == false){
            let xDistance:CGFloat = gestureRecognizer.translation(in: self).x
            
            switch(gestureRecognizer.state) {
            case UIGestureRecognizerState.began:
                self.originalPoint = self.center
            case UIGestureRecognizerState.changed:
                let translation: CGPoint = gestureRecognizer.translation(in: self)
                let displacement: CGPoint = CGPoint.init(x: translation.x, y: translation.y)
                
                if displacement.x + self.originalPoint.x < self.originalPoint.x {
                    self.transform = CGAffineTransform.init(translationX: displacement.x, y: 0)
                    self.center = CGPoint(x: self.originalPoint.x + xDistance, y: self.originalPoint.y)
                }
            case UIGestureRecognizerState.ended:
                let hasMovedToFarLeft = self.frame.maxX < UIScreen.main.bounds.width / 2
                if (hasMovedToFarLeft) {
                    btDone.sendActions(for: .touchUpInside)
                    self.center = self.originalPoint
                    self.transform = CGAffineTransform(rotationAngle: 0)
                } else {
                    UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: UIView.AnimationOptions(), animations: {
                        self.center = self.originalPoint
                        self.transform = CGAffineTransform(rotationAngle: 0)
                    }, completion: {success in })
                }
            default:
                break
            }
        }
        
    }
>>>>>>> 41cb1a0171efde19208aef60b18a0c27c6016bad
}
