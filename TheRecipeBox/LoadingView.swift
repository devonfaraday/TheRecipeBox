//
//  LoadingView.swift
//  TheRecipeBox
//
//  Created by Christian McMullin on 4/3/17.
//  Copyright © 2017 Christian McMullin. All rights reserved.
//

import Foundation
import UIKit
class LoadingIndicatorView {
    
    static var currentOverlay : UIView?
    static var currentLoadingText: String?
    static var currentOverlayTarget: UIView?
    static func show(_ loadingText: String) {
        guard let currentMainWindow = UIApplication.shared.keyWindow else {
            print("No main window.")
            return
        }
        show(currentMainWindow, loadingText: loadingText)
    }
    
    static func show(_ overlayTarget : UIView, loadingText: String?) {
        // Clear it first in case it was already shown
        hide()
        
        // Create the overlay
        let overlay = UIView(frame: overlayTarget.frame)
        overlay.center = overlayTarget.center
        overlay.alpha = 0
        overlay.backgroundColor = UIColor.white
        overlayTarget.addSubview(overlay)
        overlayTarget.bringSubview(toFront: overlay)
        
        // Create and animate the activity indicator
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        indicator.center = overlay.center
        indicator.color = UIColor.black
        indicator.startAnimating()
        overlay.addSubview(indicator)
        
        // Create label
        if let textString = loadingText {
            let label = UILabel()
            label.text = textString
            label.textColor = UIColor.black
            label.sizeToFit()
            label.center = CGPoint(x: indicator.center.x, y: indicator.center.y + 30)
            overlay.addSubview(label)
        }
        
        // Animate the overlay to show
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.5)
        overlay.alpha = overlay.alpha > 0 ? 0 : 0.5
        UIView.commitAnimations()
        
        currentOverlay = overlay
        currentLoadingText = loadingText
        currentOverlayTarget = overlayTarget
    }
    
    static func hide() {
        if currentOverlay != nil {
            currentOverlay?.removeFromSuperview()
            currentOverlay =  nil
            currentLoadingText = nil
            currentOverlayTarget = nil
        }
    }
}
